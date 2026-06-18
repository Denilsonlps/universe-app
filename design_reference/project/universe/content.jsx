// content.jsx — content store, wikilink engine, rich section renderer, term sheet, media placeholder.

// ── Content store: holds editable docs + news, shared by app and admin.
function useContentStore() {
  const clone = (x) => JSON.parse(JSON.stringify(x));
  const [docs, setDocs] = React.useState(() => clone(window.CONTENT_DOCS));
  const [news, setNews] = React.useState(() => clone(window.NEWS_SEED));

  const api = React.useMemo(() => ({
    getDoc: (id) => docs.find(d => d.id === id),
    docsByKind: (kind) => docs.filter(d => d.kind === kind),
    saveDoc: (doc) => setDocs(ds => ds.map(d => d.id === doc.id ? { ...doc, updated: todayISO() } : d)),
    getNews: () => news,
    publishedNews: () => news.filter(n => n.published),
    getNewsItem: (id) => news.find(n => n.id === id),
    saveNews: (item) => setNews(ns => {
      const exists = ns.some(n => n.id === item.id);
      return exists ? ns.map(n => n.id === item.id ? item : n) : [{ ...item, id: 'n' + Date.now() }, ...ns];
    }),
    toggleNews: (id) => setNews(ns => ns.map(n => n.id === id ? { ...n, published: !n.published } : n)),
  }), [docs, news]);
  return api;
}

function todayISO() {
  const d = new Date('2026-06-15');
  return d.toISOString().slice(0, 10);
}
function fmtDate(iso) {
  if (!iso) return '';
  const M = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
  const [y, m, d] = iso.split('-');
  return `${parseInt(d)} de ${M[parseInt(m) - 1]}. de ${y}`;
}

// ── Resolve a glossary key → navigation target.
function resolveTerm(key, nav) {
  const g = window.GLOSSARY[key];
  if (!g) return;
  if (g.def) nav.go('termo', { key });
  else if (g.docId) nav.go('benefitDetail', { id: g.docId });
}

// ── WikiText: render a string, turning [[key]] / [[key|display]] into tappable links.
function WikiText({ text, nav, style = {} }) {
  const parts = [];
  const re = /\[\[([^\]]+)\]\]/g;
  let last = 0, m, k = 0;
  while ((m = re.exec(text)) !== null) {
    if (m.index > last) parts.push(text.slice(last, m.index));
    const inner = m[1];
    const [key, disp] = inner.includes('|') ? inner.split('|') : [inner, inner];
    const known = !!window.GLOSSARY[key];
    parts.push(
      <span key={k++} onClick={known ? (e) => { e.stopPropagation(); resolveTerm(key, nav); } : undefined}
        style={known ? {
          color: 'var(--green-700)', fontWeight: 700, cursor: 'pointer',
          borderBottom: '1.5px solid var(--green-100)', whiteSpace: 'nowrap',
        } : {}}>
        {disp}
      </span>
    );
    last = re.lastIndex;
  }
  if (last < text.length) parts.push(text.slice(last));
  // split paragraphs on \n\n
  return <span style={style}>{parts}</span>;
}

function WikiParagraphs({ text, nav, style = {} }) {
  const paras = text.split('\n\n');
  return (
    <div style={style}>
      {paras.map((p, i) => (
        <p key={i} style={{ margin: i ? '11px 0 0' : 0, fontSize: 13.5, lineHeight: 1.62, color: 'var(--ink-2)' }}>
          <WikiText text={p} nav={nav} />
        </p>
      ))}
    </div>
  );
}

// ── Parse a pasted video link → embeddable info.
function parseVideoUrl(url) {
  if (!url) return null;
  const u = url.trim();
  let m = u.match(/(?:youtube\.com\/(?:watch\?v=|embed\/|shorts\/)|youtu\.be\/)([\w-]{11})/);
  if (m) return { kind: 'youtube', id: m[1], watch: `https://www.youtube.com/watch?v=${m[1]}`, embed: `https://www.youtube-nocookie.com/embed/${m[1]}`, thumb: `https://img.youtube.com/vi/${m[1]}/hqdefault.jpg` };
  m = u.match(/vimeo\.com\/(\d+)/);
  if (m) return { kind: 'vimeo', id: m[1], watch: `https://vimeo.com/${m[1]}`, embed: `https://player.vimeo.com/video/${m[1]}`, thumb: null };
  if (/^https?:\/\//.test(u)) return { kind: 'link', watch: u, embed: u, thumb: null };
  return null;
}

// ── Read an uploaded File into a usable media object (object URL).
function readFileAsMedia(file) {
  return new Promise((resolve) => {
    const isVideo = file.type.startsWith('video');
    const src = URL.createObjectURL(file);
    resolve({ mediaType: isVideo ? 'video' : 'image', src, name: file.name, source: 'upload' });
  });
}

// ── Media view (student-facing): renders real image / uploaded video / embed, or placeholder.
function MediaView({ media, mediaType, caption, onClick, toast }) {
  const mt = (media && media.mediaType) || mediaType || 'image';
  const src = media && media.src;          // uploaded image/video (object/data URL)
  const link = media && media.url;          // external link
  const video = link ? parseVideoUrl(link) : null;
  const isVideo = mt === 'video';

  let inner;
  // Uploaded image
  if (!isVideo && src) {
    inner = <img src={src} alt={caption || ''} style={{ width: '100%', height: 190, objectFit: 'cover', display: 'block' }} />;
  }
  // Uploaded video file
  else if (isVideo && src) {
    inner = <video src={src} controls playsInline style={{ width: '100%', height: 200, background: '#000', display: 'block' }} />;
  }
  // External video link (YouTube/Vimeo/other) → thumbnail that opens the video in a new tab.
  else if (isVideo && video) {
    const label = video.kind === 'youtube' ? 'Assistir no YouTube' : video.kind === 'vimeo' ? 'Assistir no Vimeo' : 'Assistir vídeo';
    inner = (
      <a href={video.watch} target="_blank" rel="noopener noreferrer" className="u-press"
        style={{ display: 'block', position: 'relative', height: 190, textDecoration: 'none', cursor: 'pointer', background: video.thumb ? `center/cover url(${video.thumb})` : 'linear-gradient(135deg, var(--green-800), var(--green-900))' }}>
        <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(180deg, rgba(0,0,0,0.15), rgba(0,0,0,0.45))' }} />
        <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <div style={{ width: 60, height: 60, borderRadius: '50%', background: 'rgba(255,255,255,0.95)', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 6px 18px rgba(0,0,0,0.35)' }}>
            <div style={{ width: 0, height: 0, marginLeft: 5, borderTop: '12px solid transparent', borderBottom: '12px solid transparent', borderLeft: '19px solid var(--green-800)' }} />
          </div>
        </div>
        <span style={{ position: 'absolute', bottom: 11, left: 12, right: 12, display: 'flex', alignItems: 'center', gap: 6, fontSize: 12, fontWeight: 700, color: '#fff' }}>
          <Icon name="globe" size={15} color="#fff" strokeWidth={2} />{label}
          <span style={{ marginLeft: 'auto', fontSize: 16, lineHeight: 1 }}>↗</span>
        </span>
      </a>
    );
  }
  // Placeholder (no media set)
  else {
    inner = (
      <div style={{ height: 150, position: 'relative', display: 'flex', alignItems: 'center', justifyContent: 'center', background: isVideo ? 'linear-gradient(135deg, var(--green-800), var(--green-900))' : 'repeating-linear-gradient(135deg, var(--bg-2) 0 11px, var(--card) 11px 22px)' }}>
        {isVideo ? (
          <div style={{ width: 58, height: 58, borderRadius: '50%', background: 'rgba(255,255,255,0.92)', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 6px 18px rgba(0,0,0,0.3)' }}>
            <div style={{ width: 0, height: 0, marginLeft: 5, borderTop: '11px solid transparent', borderBottom: '11px solid transparent', borderLeft: '18px solid var(--green-800)' }} />
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 7, color: 'var(--ink-3)' }}>
            <Icon name="doc" size={30} color="var(--ink-3)" strokeWidth={1.6} />
            <span style={{ fontFamily: 'monospace', fontSize: 10.5 }}>imagem ilustrativa</span>
          </div>
        )}
      </div>
    );
  }

  return (
    <div style={{ borderRadius: 14, overflow: 'hidden', boxShadow: 'var(--shadow-sm)' }}>
      {inner}
      {caption && <div style={{ padding: '10px 14px', fontSize: 12, color: 'var(--ink-2)', background: 'var(--card)', fontWeight: 500 }}>{caption}</div>}
    </div>
  );
}
// Back-compat alias
const MediaPlaceholder = MediaView;

// ── Render one rich section.
function RichSection({ section: s, nav, toast }) {
  const Heading = ({ children }) => <h3 style={{ margin: '0 0 11px', fontSize: 16, fontWeight: 800, color: 'var(--ink)', letterSpacing: -0.2 }}>{children}</h3>;

  if (s.type === 'rich') return (
    <section>{s.heading && <Heading>{s.heading}</Heading>}<WikiParagraphs text={s.body} nav={nav} /></section>
  );

  if (s.type === 'steps') return (
    <section>
      {s.heading && <Heading>{s.heading}</Heading>}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 13 }}>
        {s.items.map((it, i) => (
          <div key={i} style={{ display: 'flex', gap: 13, alignItems: 'flex-start' }}>
            <div style={{ width: 27, height: 27, borderRadius: '50%', flexShrink: 0, background: 'var(--green-800)', color: '#fff', fontSize: 13, fontWeight: 800, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{i + 1}</div>
            <div style={{ flex: 1, paddingTop: 3, fontSize: 13.5, lineHeight: 1.5, color: 'var(--ink)' }}><WikiText text={it} nav={nav} /></div>
          </div>
        ))}
      </div>
    </section>
  );

  if (s.type === 'docs') return (
    <section>
      {s.heading && <Heading>{s.heading}</Heading>}
      <Card pad={6}>
        {s.items.map((it, i) => (
          <div key={i} style={{ display: 'flex', gap: 11, alignItems: 'flex-start', padding: '9px 10px' }}>
            <Icon name="checkCircle" size={18} color="var(--green-500)" strokeWidth={2} style={{ marginTop: 1, flexShrink: 0 }} />
            <span style={{ flex: 1, fontSize: 13.5, color: 'var(--ink)', lineHeight: 1.45 }}><WikiText text={it} nav={nav} /></span>
          </div>
        ))}
      </Card>
    </section>
  );

  if (s.type === 'media') return (
    <section>{s.heading && <Heading>{s.heading}</Heading>}<MediaView media={{ mediaType: s.mediaType, src: s.src, url: s.url }} mediaType={s.mediaType} caption={s.caption} toast={toast} /></section>
  );

  if (s.type === 'callout') {
    const warn = s.variant === 'warn';
    return (
      <div style={{ display: 'flex', gap: 12, padding: 15, borderRadius: 14, background: warn ? 'rgba(242,176,30,0.12)' : 'var(--green-050)', border: `1px solid ${warn ? 'rgba(242,176,30,0.3)' : 'var(--green-100)'}` }}>
        <Icon name={warn ? 'bell' : 'shield'} size={20} color={warn ? '#C98A0E' : 'var(--green-600)'} strokeWidth={2} style={{ flexShrink: 0, marginTop: 1 }} />
        <div style={{ flex: 1, fontSize: 12.5, lineHeight: 1.5, color: warn ? '#7A5A06' : 'var(--ink-2)', fontWeight: 500 }}><WikiText text={s.body} nav={nav} /></div>
      </div>
    );
  }

  if (s.type === 'faq') return (
    <section>
      {s.heading && <Heading>{s.heading}</Heading>}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 9 }}>
        {s.items.map((f, i) => <FaqRow key={i} f={f} nav={nav} />)}
      </div>
    </section>
  );

  if (s.type === 'sources') return (
    <section>
      {s.heading && <Heading>{s.heading}</Heading>}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 9 }}>
        {s.items.map((src, i) => (
          <div key={i} onClick={() => toast('Abrindo ' + src.url + '…', 'globe')} className="u-press" style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px', borderRadius: 12, background: 'var(--card)', boxShadow: 'var(--shadow-sm)', cursor: 'pointer' }}>
            <Icon name="globe" size={19} color="var(--green-700)" strokeWidth={1.9} />
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 13.5, fontWeight: 700, color: 'var(--ink)' }}>{src.label}</div>
              <div style={{ fontSize: 11.5, color: 'var(--green-700)' }}>{src.url}</div>
            </div>
            <Icon name="chevR" size={16} color="var(--ink-3)" strokeWidth={2} />
          </div>
        ))}
      </div>
    </section>
  );

  return null;
}

function FaqRow({ f, nav }) {
  const [open, setOpen] = React.useState(false);
  return (
    <div style={{ background: 'var(--card)', borderRadius: 12, boxShadow: 'var(--shadow-sm)', overflow: 'hidden' }}>
      <button onClick={() => setOpen(o => !o)} style={{ width: '100%', display: 'flex', alignItems: 'center', gap: 11, padding: '13px 14px', textAlign: 'left' }}>
        <span style={{ flex: 1, fontSize: 13.5, fontWeight: 600, color: 'var(--ink)', lineHeight: 1.35 }}>{f.q}</span>
        <div style={{ transform: open ? 'rotate(180deg)' : 'none', transition: 'transform .25s' }}><Icon name="chevD" size={17} color="var(--green-600)" strokeWidth={2.2} /></div>
      </button>
      <div style={{ maxHeight: open ? 260 : 0, transition: 'max-height .3s', overflow: 'hidden' }}>
        <div style={{ padding: '0 14px 14px', fontSize: 12.5, lineHeight: 1.55, color: 'var(--ink-2)' }}><WikiText text={f.a} nav={nav} /></div>
      </div>
    </div>
  );
}

// ── RichContent: render all sections with spacing.
function RichContent({ sections, nav, toast }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 24 }}>
      {sections.map((s, i) => <RichSection key={i} section={s} nav={nav} toast={toast} />)}
    </div>
  );
}

// ── "Atualizado em" pill
function UpdatedPill({ iso, style = {} }) {
  return (
    <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, fontSize: 11.5, color: 'var(--ink-3)', fontWeight: 600, ...style }}>
      <Icon name="clock" size={14} color="var(--ink-3)" strokeWidth={2} />
      Atualizado em {fmtDate(iso)}
    </div>
  );
}

// ── Term definition sheet (bottom sheet)
function TermSheet({ open, termKey, nav, onClose }) {
  const g = termKey ? window.GLOSSARY[termKey] : null;
  return (
    <div style={{ position: 'absolute', inset: 0, zIndex: 50, pointerEvents: open ? 'auto' : 'none' }}>
      <div onClick={onClose} style={{ position: 'absolute', inset: 0, background: 'rgba(13,40,28,0.45)', opacity: open ? 1 : 0, transition: 'opacity .28s', backdropFilter: open ? 'blur(2px)' : 'none' }} />
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0, background: 'var(--card)',
        borderRadius: '24px 24px 0 0', padding: '10px 22px 30px', boxShadow: '0 -10px 40px rgba(0,0,0,0.25)',
        transform: open ? 'none' : 'translateY(100%)', transition: 'transform .32s cubic-bezier(.3,.8,.3,1)',
      }}>
        <div style={{ width: 40, height: 5, borderRadius: 999, background: 'var(--line)', margin: '0 auto 18px' }} />
        {g && (
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 11, marginBottom: 12 }}>
              <div style={{ width: 42, height: 42, borderRadius: 12, background: 'var(--green-050)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Icon name="book" size={22} color="var(--green-700)" strokeWidth={1.9} />
              </div>
              <div style={{ fontSize: 19, fontWeight: 800, color: 'var(--ink)' }}>{g.term || termKey}</div>
            </div>
            <p style={{ margin: 0, fontSize: 13.5, lineHeight: 1.6, color: 'var(--ink-2)' }}>{g.def}</p>
            {g.docId && (
              <button onClick={() => { onClose(); nav.go('benefitDetail', { id: g.docId }); }} className="u-press" style={{ marginTop: 18, width: '100%', height: 48, borderRadius: 13, background: 'var(--green-800)', color: '#fff', fontSize: 14, fontWeight: 700, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8 }}>
                Ver página completa <Icon name="chevR" size={17} color="#fff" strokeWidth={2.2} />
              </button>
            )}
          </div>
        )}
      </div>
    </div>
  );
}

// ── MediaUploader (admin): choose source (device upload OR link), preview, remove.
function MediaUploader({ value, onChange, toast }) {
  // value: { mediaType:'video'|'image', src?, url?, name? }
  const v = value || {};
  const [mode, setMode] = React.useState(v.url ? 'link' : 'upload');
  const [linkDraft, setLinkDraft] = React.useState(v.url || '');
  const fileRef = React.useRef(null);

  const pick = (accept, capture) => {
    const el = fileRef.current;
    el.accept = accept;
    if (capture) el.setAttribute('capture', 'environment'); else el.removeAttribute('capture');
    el.click();
  };
  const onFile = async (e) => {
    const file = e.target.files && e.target.files[0];
    if (!file) return;
    const media = await readFileAsMedia(file);
    onChange({ mediaType: media.mediaType, src: media.src, name: media.name, url: undefined });
    toast && toast((media.mediaType === 'video' ? 'Vídeo' : 'Imagem') + ' adicionado: ' + media.name, 'checkCircle');
    e.target.value = '';
  };
  const applyLink = () => {
    const parsed = parseVideoUrl(linkDraft);
    if (!parsed) { toast && toast('Link inválido', 'bell'); return; }
    onChange({ mediaType: 'video', url: linkDraft.trim(), src: undefined, name: undefined });
    toast && toast('Vídeo por link adicionado', 'checkCircle');
  };
  const clear = () => { onChange({ mediaType: v.mediaType || 'image', src: undefined, url: undefined, name: undefined }); setLinkDraft(''); };

  const hasMedia = !!(v.src || v.url);

  return (
    <div>
      <input ref={fileRef} type="file" onChange={onFile} style={{ display: 'none' }} />

      {/* live preview */}
      {hasMedia && (
        <div style={{ marginBottom: 12, position: 'relative' }}>
          <MediaView media={v} mediaType={v.mediaType} toast={toast} />
          <button onClick={clear} className="u-press" style={{ position: 'absolute', top: 8, right: 8, width: 30, height: 30, borderRadius: '50%', background: 'rgba(13,40,28,0.7)', display: 'flex', alignItems: 'center', justifyContent: 'center', backdropFilter: 'blur(4px)' }}>
            <Icon name="plus" size={18} color="#fff" strokeWidth={2.4} style={{ transform: 'rotate(45deg)' }} />
          </button>
          <div style={{ fontSize: 11, color: 'var(--ink-3)', marginTop: 7, display: 'flex', alignItems: 'center', gap: 5 }}>
            <Icon name={v.url ? 'globe' : 'check'} size={13} color="var(--green-600)" strokeWidth={2.2} />
            {v.url ? 'Vídeo por link' : (v.name || 'Arquivo enviado')}
          </div>
        </div>
      )}

      {/* source tabs */}
      <div style={{ display: 'flex', background: 'var(--bg-2)', borderRadius: 11, padding: 3, marginBottom: 11 }}>
        {[['upload', 'Do dispositivo'], ['link', 'Colar link']].map(([k, lbl]) => (
          <button key={k} onClick={() => setMode(k)} className="u-press" style={{ flex: 1, height: 34, borderRadius: 9, fontSize: 12.5, fontWeight: 700, color: mode === k ? 'var(--green-800)' : 'var(--ink-3)', background: mode === k ? 'var(--card)' : 'transparent', boxShadow: mode === k ? 'var(--shadow-sm)' : 'none' }}>{lbl}</button>
        ))}
      </div>

      {mode === 'upload' ? (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          <div style={{ display: 'flex', gap: 8 }}>
            <button onClick={() => pick('image/*')} className="u-press" style={uploadBtn}>
              <Icon name="doc" size={18} color="var(--green-700)" strokeWidth={1.9} /> Imagem
            </button>
            <button onClick={() => pick('video/*')} className="u-press" style={uploadBtn}>
              <Icon name="globe" size={18} color="var(--green-700)" strokeWidth={1.9} /> Vídeo
            </button>
          </div>
          <button onClick={() => pick('image/*,video/*', true)} className="u-press" style={{ ...uploadBtn, background: 'var(--green-050)' }}>
            <Icon name="phone" size={18} color="var(--green-700)" strokeWidth={1.9} /> Gravar / tirar foto agora
          </button>
          <div style={{ fontSize: 10.5, color: 'var(--ink-3)', textAlign: 'center', marginTop: 2 }}>Envie do rolo da câmera ou grave na hora.</div>
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 9 }}>
          <Field icon="globe" value={linkDraft} onChange={setLinkDraft} placeholder="Cole o link do YouTube, Vimeo…" />
          <Button size="sm" icon="plus" onClick={applyLink} disabled={!linkDraft.trim()}>Adicionar vídeo do link</Button>
          <div style={{ fontSize: 10.5, color: 'var(--ink-3)', textAlign: 'center' }}>Ex.: youtube.com/watch?v=… ou youtu.be/…</div>
        </div>
      )}
    </div>
  );
}
const uploadBtn = { flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7, height: 44, borderRadius: 11, background: 'var(--bg-2)', fontSize: 13, fontWeight: 700, color: 'var(--ink)' };

Object.assign(window, { useContentStore, WikiText, WikiParagraphs, RichContent, RichSection, MediaView, MediaPlaceholder, MediaUploader, parseVideoUrl, readFileAsMedia, UpdatedPill, TermSheet, resolveTerm, fmtDate, todayISO });
