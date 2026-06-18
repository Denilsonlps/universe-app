// screens-admin.jsx — Admin hub + content editor + news manager.
// (Vagas manager lives in screens-estagio.jsx as AdminPanelScreen / route 'adminVagas'.)

function AdminHeader({ nav, title, sub, onBack, right }) {
  return (
    <div style={{ paddingTop: STATUS_H, padding: `${STATUS_H}px 16px 16px`, background: 'linear-gradient(160deg, #1B2A3F, #0E1A2B)', color: '#fff', borderRadius: '0 0 24px 24px', boxShadow: '0 8px 22px rgba(8,16,28,0.4)' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 12 }}>
        <button onClick={onBack || (() => nav.back())} className="u-press" style={{ width: 38, height: 38, marginLeft: -8, borderRadius: 11, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Icon name="chevL" size={23} color="#fff" strokeWidth={2.2} />
        </button>
        <div style={{ flex: 1 }} />
        {right || <Icon name="shield" size={22} color="#4F9CE8" strokeWidth={1.9} />}
      </div>
      <h1 style={{ margin: 0, fontSize: 22, fontWeight: 800 }}>{title}</h1>
      {sub && <p style={{ margin: '4px 0 0', fontSize: 12.5, color: 'rgba(255,255,255,0.6)' }}>{sub}</p>}
    </div>
  );
}

function AdminHubScreen({ nav, store, user }) {
  const docs = [...store.docsByKind('gov'), ...store.docsByKind('inst')];
  const newsCount = store.getNews().filter(n => n.published).length;
  const cards = [
    { icon: 'briefcase', title: 'Vagas e concursos', sub: 'Estágios, jovem aprendiz e concursos', screen: 'adminVagas', tint: '#4F9CE8' },
    { icon: 'book', title: 'Páginas de conteúdo', sub: `${docs.length} páginas de benefícios`, screen: 'adminContent', tint: '#34C089' },
    { icon: 'bell', title: 'Notícias', sub: `${newsCount} publicadas`, screen: 'adminNews', tint: '#F2B01E' },
  ];
  return (
    <PageShell nav={nav} bodyPad={0} bg="var(--bg)" header={
      <AdminHeader nav={nav} title="Painel administrativo" sub="Setor de Estágios e Comunicação"
        onBack={() => nav.tab('home')}
        right={<button onClick={() => nav.tab('home')} className="u-press" style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 12.5, fontWeight: 700, color: 'rgba(255,255,255,0.85)' }}><Icon name="logout" size={18} color="#fff" strokeWidth={2} />Sair</button>} />
    }>
      <div style={{ padding: 16 }}>
        <Card pad={14} style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 16, background: 'linear-gradient(150deg, rgba(79,156,232,0.1), var(--card))' }}>
          <div style={{ width: 44, height: 44, borderRadius: 12, background: 'rgba(79,156,232,0.15)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name="shield" size={22} color="#2D7DD2" strokeWidth={1.9} />
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 13.5, fontWeight: 700, color: 'var(--ink)' }}>Acesso administrativo</div>
            <div style={{ fontSize: 11.5, color: 'var(--ink-3)' }}>O que você publica aparece para os alunos na hora.</div>
          </div>
        </Card>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 11 }}>
          {cards.map((c, i) => (
            <Card key={i} onClick={() => nav.go(c.screen)} pad={16} style={{ display: 'flex', alignItems: 'center', gap: 14, animation: `u-fade-up .4s ${i * 0.05}s both` }}>
              <div style={{ width: 50, height: 50, borderRadius: 14, background: c.tint + '22', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                <Icon name={c.icon} size={25} color={c.tint} strokeWidth={1.9} />
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 15, fontWeight: 700, color: 'var(--ink)' }}>{c.title}</div>
                <div style={{ fontSize: 12, color: 'var(--ink-3)', marginTop: 2 }}>{c.sub}</div>
              </div>
              <Icon name="chevR" size={18} color="var(--ink-3)" strokeWidth={2} />
            </Card>
          ))}
        </div>
      </div>
    </PageShell>
  );
}

// ── Content pages list
function AdminContentListScreen({ nav, store }) {
  const gov = store.docsByKind('gov');
  const inst = store.docsByKind('inst');
  const Group = ({ label, items }) => (
    <div style={{ marginBottom: 18 }}>
      <div style={{ fontSize: 11.5, fontWeight: 800, letterSpacing: 0.5, textTransform: 'uppercase', color: 'var(--ink-3)', margin: '0 0 9px 2px' }}>{label}</div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {items.map(d => (
          <Card key={d.id} onClick={() => nav.go('adminContentEdit', { id: d.id })} pad={14} style={{ display: 'flex', alignItems: 'center', gap: 13 }}>
            <IconTile name={d.icon} size={44} icon={22} />
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--ink)' }}>{d.title}</div>
              <div style={{ fontSize: 11, color: 'var(--ink-3)', marginTop: 2 }}>{d.sections.length} seções · atualizado {fmtDate(d.updated).replace(' de 2026', '')}</div>
            </div>
            <Icon name="edit" size={19} color="var(--green-700)" strokeWidth={1.9} />
          </Card>
        ))}
      </div>
    </div>
  );
  return (
    <PageShell nav={nav} bodyPad={0} header={<AdminHeader nav={nav} title="Páginas de conteúdo" sub="Edite o que os alunos veem em cada benefício" />}>
      <div style={{ padding: 16 }}>
        <Card pad={13} style={{ display: 'flex', gap: 11, marginBottom: 18, background: 'var(--green-050)' }}>
          <Icon name="book" size={19} color="var(--green-700)" strokeWidth={1.9} style={{ marginTop: 1 }} />
          <div style={{ fontSize: 12, lineHeight: 1.5, color: 'var(--ink-2)' }}>Use <b>[[colchetes duplos]]</b> no texto para criar links internos. Ex.: <span style={{ color: 'var(--green-700)', fontWeight: 700 }}>[[PIBIC]]</span> vira um link para a página de Iniciação Científica.</div>
        </Card>
        <Group label="Governamentais" items={gov} />
        <Group label="Institucionais" items={inst} />
      </div>
    </PageShell>
  );
}

const SECTION_META = {
  rich: { label: 'Texto', icon: 'doc' }, steps: { label: 'Passo a passo', icon: 'check' },
  docs: { label: 'Lista / documentos', icon: 'checkCircle' }, media: { label: 'Vídeo / imagem', icon: 'globe' },
  callout: { label: 'Destaque', icon: 'bell' }, faq: { label: 'Dúvidas', icon: 'question' }, sources: { label: 'Fontes oficiais', icon: 'globe' },
};
function newSection(type) {
  switch (type) {
    case 'rich': return { type, heading: 'Novo título', body: 'Escreva aqui. Use [[termos]] para links internos.' };
    case 'steps': return { type, heading: 'Como solicitar', items: ['Primeiro passo', 'Segundo passo'] };
    case 'docs': return { type, heading: 'Documentos necessários', items: ['Documento 1'] };
    case 'media': return { type, mediaType: 'video', heading: 'Tutorial em vídeo', caption: 'Descrição do vídeo' };
    case 'callout': return { type, variant: 'info', body: 'Aviso importante.' };
    case 'faq': return { type, heading: 'Dúvidas frequentes', items: [{ q: 'Pergunta?', a: 'Resposta.' }] };
    case 'sources': return { type, heading: 'Canais oficiais', items: [{ label: 'Site oficial', url: 'gov.br' }] };
    default: return { type: 'rich', heading: '', body: '' };
  }
}

// ── Content editor
function AdminContentEditScreen({ nav, params, store, toast }) {
  const orig = store.getDoc(params.id);
  const [draft, setDraft] = React.useState(() => JSON.parse(JSON.stringify(orig)));
  const [adding, setAdding] = React.useState(false);
  const upd = (fn) => setDraft(d => { const c = JSON.parse(JSON.stringify(d)); fn(c); return c; });
  const setSec = (i, fn) => upd(d => fn(d.sections[i]));
  const move = (i, dir) => upd(d => { const j = i + dir; if (j < 0 || j >= d.sections.length) return; [d.sections[i], d.sections[j]] = [d.sections[j], d.sections[i]]; });
  const del = (i) => upd(d => d.sections.splice(i, 1));
  const add = (type) => { upd(d => d.sections.push(newSection(type))); setAdding(false); };
  const publish = () => { store.saveDoc(draft); toast('Conteúdo publicado e atualizado!', 'checkCircle'); setTimeout(() => nav.back(), 600); };

  const linesField = (label, value, onChange) => (
    <Field multiline label={label} value={value} onChange={onChange} />
  );

  return (
    <PageShell nav={nav} bodyPad={0} header={
      <AdminHeader nav={nav} title="Editar página" sub={draft.title}
        right={<button onClick={publish} className="u-press" style={{ fontSize: 13, fontWeight: 800, color: '#fff', background: 'var(--green-600)', padding: '8px 14px', borderRadius: 10 }}>Publicar</button>} />
    }>
      <div style={{ padding: 16 }}>
        <Card pad={14} style={{ marginBottom: 14, display: 'flex', flexDirection: 'column', gap: 12 }}>
          <Field label="Título" icon="edit" value={draft.title} onChange={v => upd(d => d.title = v)} />
          <Field label="Etiqueta (tag)" value={draft.tag} onChange={v => upd(d => d.tag = v)} />
          <Field label="Resumo (aparece na lista)" multiline value={draft.summary} onChange={v => upd(d => d.summary = v)} />
        </Card>

        {draft.sections.map((s, i) => (
          <Card key={i} pad={14} style={{ marginBottom: 12 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 9, marginBottom: 12 }}>
              <Icon name={(SECTION_META[s.type] || {}).icon || 'doc'} size={16} color="var(--green-700)" strokeWidth={2} />
              <span style={{ flex: 1, fontSize: 12, fontWeight: 800, letterSpacing: 0.3, textTransform: 'uppercase', color: 'var(--ink-3)' }}>{(SECTION_META[s.type] || {}).label || s.type}</span>
              <button onClick={() => move(i, -1)} className="u-press" style={{ padding: 4, opacity: i === 0 ? 0.3 : 1 }}><Icon name="chevD" size={17} color="var(--ink-3)" strokeWidth={2.2} style={{ transform: 'rotate(180deg)' }} /></button>
              <button onClick={() => move(i, 1)} className="u-press" style={{ padding: 4, opacity: i === draft.sections.length - 1 ? 0.3 : 1 }}><Icon name="chevD" size={17} color="var(--ink-3)" strokeWidth={2.2} /></button>
              <button onClick={() => del(i)} className="u-press" style={{ padding: 4 }}><Icon name="logout" size={16} color="#E23B2E" strokeWidth={2} /></button>
            </div>

            {('heading' in s) && <Field value={s.heading} onChange={v => setSec(i, x => x.heading = v)} placeholder="Título da seção" style={{ marginBottom: 10 }} />}

            {(s.type === 'rich' || s.type === 'callout') &&
              linesField(s.type === 'callout' ? 'Texto do destaque' : 'Texto', s.body, v => setSec(i, x => x.body = v))}

            {(s.type === 'steps' || s.type === 'docs') &&
              linesField('Itens (um por linha)', s.items.join('\n'), v => setSec(i, x => x.items = v.split('\n').filter(Boolean)))}

            {s.type === 'media' && (
              <div>
                <MediaUploader value={{ mediaType: s.mediaType, src: s.src, url: s.url, name: s.name }} toast={toast}
                  onChange={(mv) => setSec(i, x => { x.mediaType = mv.mediaType; x.src = mv.src; x.url = mv.url; x.name = mv.name; })} />
                <Field value={s.caption} onChange={v => setSec(i, x => x.caption = v)} placeholder="Legenda (opcional)" style={{ marginTop: 11 }} />
              </div>
            )}

            {s.type === 'callout' && (
              <div style={{ display: 'flex', gap: 8, marginTop: 10 }}>
                {[['info', 'Informação'], ['warn', 'Atenção']].map(([v, lbl]) => (
                  <button key={v} onClick={() => setSec(i, x => x.variant = v)} className="u-press" style={{ flex: 1, padding: '9px 0', borderRadius: 10, fontSize: 12.5, fontWeight: 700, background: s.variant === v ? 'var(--green-800)' : 'var(--bg-2)', color: s.variant === v ? '#fff' : 'var(--ink-2)' }}>{lbl}</button>
                ))}
              </div>
            )}

            {s.type === 'faq' && s.items.map((f, j) => (
              <div key={j} style={{ display: 'flex', flexDirection: 'column', gap: 8, marginBottom: 10, paddingBottom: 10, borderBottom: j < s.items.length - 1 ? '1px solid var(--line)' : 'none' }}>
                <Field value={f.q} onChange={v => setSec(i, x => x.items[j].q = v)} placeholder="Pergunta" />
                <Field multiline value={f.a} onChange={v => setSec(i, x => x.items[j].a = v)} placeholder="Resposta" />
              </div>
            ))}
            {s.type === 'faq' && <button onClick={() => setSec(i, x => x.items.push({ q: 'Pergunta?', a: 'Resposta.' }))} className="u-press" style={{ fontSize: 12.5, fontWeight: 700, color: 'var(--green-700)', display: 'flex', alignItems: 'center', gap: 5 }}><Icon name="plus" size={15} color="var(--green-700)" strokeWidth={2.4} />Adicionar pergunta</button>}

            {s.type === 'sources' && s.items.map((src, j) => (
              <div key={j} style={{ display: 'flex', flexDirection: 'column', gap: 8, marginBottom: 10 }}>
                <Field value={src.label} onChange={v => setSec(i, x => x.items[j].label = v)} placeholder="Nome" />
                <Field value={src.url} onChange={v => setSec(i, x => x.items[j].url = v)} placeholder="endereço.gov.br" />
              </div>
            ))}
          </Card>
        ))}

        {!adding ? (
          <Button full variant="outline" size="md" icon="plus" onClick={() => setAdding(true)}>Adicionar seção</Button>
        ) : (
          <Card pad={12}>
            <div style={{ fontSize: 12, fontWeight: 800, color: 'var(--ink-3)', textTransform: 'uppercase', letterSpacing: 0.3, margin: '2px 2px 10px' }}>Tipo de seção</div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
              {Object.entries(SECTION_META).map(([type, m]) => (
                <button key={type} onClick={() => add(type)} className="u-press" style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '11px 12px', borderRadius: 11, background: 'var(--bg-2)', textAlign: 'left' }}>
                  <Icon name={m.icon} size={17} color="var(--green-700)" strokeWidth={2} />
                  <span style={{ fontSize: 12.5, fontWeight: 600, color: 'var(--ink)' }}>{m.label}</span>
                </button>
              ))}
            </div>
            <button onClick={() => setAdding(false)} className="u-press" style={{ width: '100%', marginTop: 10, padding: 10, fontSize: 13, fontWeight: 700, color: 'var(--ink-3)' }}>Cancelar</button>
          </Card>
        )}

        <Button full size="lg" icon="check" style={{ marginTop: 18 }} onClick={publish}>Publicar alterações</Button>
        <div style={{ textAlign: 'center', fontSize: 11, color: 'var(--ink-3)', marginTop: 10 }}>A data de atualização será definida para hoje.</div>
      </div>
    </PageShell>
  );
}

// ── News manager
function AdminNewsListScreen({ nav, store, toast }) {
  const news = store.getNews();
  return (
    <PageShell nav={nav} bodyPad={0} header={<AdminHeader nav={nav} title="Notícias" sub="Publique avisos e novidades" />}>
      <div style={{ padding: 16 }}>
        <Button full size="md" icon="plus" style={{ marginBottom: 16 }} onClick={() => nav.go('adminNewsEdit', { id: null })}>Nova notícia</Button>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {news.map((n, i) => (
            <Card key={n.id} pad={14} style={{ display: 'flex', alignItems: 'center', gap: 12, opacity: n.published ? 1 : 0.6, animation: `u-fade-up .35s ${i * 0.03}s both` }}>
              <div onClick={() => nav.go('adminNewsEdit', { id: n.id })} style={{ flex: 1, minWidth: 0, cursor: 'pointer' }}>
                <div style={{ fontSize: 13.5, fontWeight: 700, color: 'var(--ink)', lineHeight: 1.3 }}>{n.title}</div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginTop: 5 }}>
                  <span style={{ fontSize: 10, fontWeight: 700, color: 'var(--green-700)', background: 'var(--green-050)', padding: '2px 7px', borderRadius: 999 }}>{n.category}</span>
                  <span style={{ fontSize: 11, color: 'var(--ink-3)' }}>{n.source}</span>
                  <StatusBadge status={n.published ? 'open' : 'closed'} openLabel="Publicada" closedLabel="Rascunho" />
                </div>
              </div>
              <Toggle on={n.published} onChange={() => { store.toggleNews(n.id); toast(n.published ? 'Despublicada' : 'Publicada', n.published ? 'bell' : 'checkCircle'); }} />
            </Card>
          ))}
        </div>
      </div>
    </PageShell>
  );
}

function AdminNewsEditScreen({ nav, params, store, toast }) {
  const existing = params.id ? store.getNewsItem(params.id) : null;
  const [d, setD] = React.useState(() => existing ? JSON.parse(JSON.stringify(existing)) : { id: null, published: true, pinned: false, category: 'Campus', source: 'IFSP Pirituba', date: todayISO(), read: '2 min', title: '', summary: '', body: '', facts: [], sourceUrl: '' });
  const set = (k, v) => setD(s => ({ ...s, [k]: v }));
  const valid = d.title.trim().length > 5 && d.body.trim().length > 20;
  const save = () => { store.saveNews(d); toast(existing ? 'Notícia atualizada!' : 'Notícia publicada!', 'checkCircle'); setTimeout(() => nav.back(), 600); };
  return (
    <PageShell nav={nav} bodyPad={0} header={<AdminHeader nav={nav} title={existing ? 'Editar notícia' : 'Nova notícia'} />}>
      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 13 }}>
        <Field label="Título" icon="edit" value={d.title} onChange={v => set('title', v)} placeholder="Título da notícia" />
        <div>
          <label style={{ display: 'block', fontSize: 12.5, fontWeight: 600, color: 'var(--ink-2)', margin: '0 0 7px 3px' }}>Categoria</label>
          <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
            {['Campus', 'SiSU', 'Enem', 'Geral'].map(c => (
              <button key={c} onClick={() => set('category', c)} className="u-press" style={{ fontSize: 12, fontWeight: 600, padding: '7px 13px', borderRadius: 999, background: d.category === c ? 'var(--green-800)' : 'var(--chip-bg)', color: d.category === c ? '#fff' : 'var(--ink-2)', boxShadow: d.category === c ? 'none' : 'inset 0 0 0 1px var(--line)' }}>{c}</button>
            ))}
          </div>
        </div>
        <Field label="Fonte" icon="institution" value={d.source} onChange={v => set('source', v)} placeholder="Ex: MEC, G1, IFSP" />
        <Field label="Resumo (aparece no card)" multiline value={d.summary} onChange={v => set('summary', v)} placeholder="Uma frase de chamada" />
        <Field label="Texto completo" multiline value={d.body} onChange={v => set('body', v)} placeholder="Use [[termos]] para links internos." />
        <Card pad={14}>
          <div style={{ fontSize: 12.5, fontWeight: 700, color: 'var(--ink)', marginBottom: 4 }}>Imagem ou vídeo de capa</div>
          <div style={{ fontSize: 11.5, color: 'var(--ink-3)', marginBottom: 11 }}>Aparece no topo da notícia. Opcional.</div>
          <MediaUploader value={d.media} toast={toast} onChange={mv => set('media', mv)} />
        </Card>
        <Field label="Link da fonte oficial" icon="globe" value={d.sourceUrl} onChange={v => set('sourceUrl', v)} placeholder="gov.br/..." />
        <Card pad={14} style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--ink)' }}>Destaque na home</div>
            <div style={{ fontSize: 11.5, color: 'var(--ink-3)' }}>Marca a notícia como prioritária</div>
          </div>
          <Toggle on={d.pinned} onChange={v => set('pinned', v)} />
        </Card>
        <Card pad={14} style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--ink)' }}>Publicar</div>
            <div style={{ fontSize: 11.5, color: 'var(--ink-3)' }}>{d.published ? 'Visível para os alunos' : 'Salva como rascunho'}</div>
          </div>
          <Toggle on={d.published} onChange={v => set('published', v)} />
        </Card>
        <Button full size="lg" icon="check" disabled={!valid} onClick={save}>{existing ? 'Salvar alterações' : 'Publicar notícia'}</Button>
      </div>
    </PageShell>
  );
}

Object.assign(window, { AdminHubScreen, AdminContentListScreen, AdminContentEditScreen, AdminNewsListScreen, AdminNewsEditScreen });
