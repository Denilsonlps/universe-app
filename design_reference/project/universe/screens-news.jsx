// screens-news.jsx — News card, news list, news detail, term screen.

const NEWS_CAT_COLORS = {
  'SiSU': { bg: 'var(--green-050)', fg: 'var(--green-700)' },
  'Campus': { bg: 'rgba(45,66,95,0.1)', fg: 'var(--navy)' },
  'Enem': { bg: 'rgba(242,176,30,0.16)', fg: '#A9760B' },
  'Geral': { bg: 'var(--bg-2)', fg: 'var(--ink-2)' },
};

function NewsCard({ n, onClick, compact }) {
  const c = NEWS_CAT_COLORS[n.category] || NEWS_CAT_COLORS['Geral'];
  if (compact) {
    return (
      <Card onClick={onClick} pad={0} style={{ width: 270, flexShrink: 0, overflow: 'hidden' }}>
        <div style={{ height: 96, background: 'linear-gradient(135deg, var(--green-600), var(--green-900))', position: 'relative', display: 'flex', alignItems: 'flex-end', padding: 12 }}>
          <UniverseBadge size={26} color="rgba(255,255,255,0.9)" ring="rgba(255,255,255,0.5)" style={{ position: 'absolute', top: 11, right: 12 }} />
          {n.pinned && <span style={{ position: 'absolute', top: 11, left: 12, fontSize: 9.5, fontWeight: 800, letterSpacing: 0.4, color: '#fff', background: 'rgba(255,255,255,0.2)', padding: '3px 8px', borderRadius: 999 }}>DESTAQUE</span>}
          <span style={{ fontSize: 10.5, fontWeight: 700, color: '#fff', background: 'rgba(0,0,0,0.25)', padding: '4px 9px', borderRadius: 999 }}>{n.category}</span>
        </div>
        <div style={{ padding: 13 }}>
          <div style={{ fontSize: 13.5, fontWeight: 700, color: 'var(--ink)', lineHeight: 1.3, display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>{n.title}</div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 9, fontSize: 11, color: 'var(--ink-3)' }}>
            <span style={{ fontWeight: 600 }}>{n.source}</span><span>·</span><span>{fmtDate(n.date).replace(' de 2026', '')}</span>
          </div>
        </div>
      </Card>
    );
  }
  return (
    <Card onClick={onClick} pad={14} style={{ display: 'flex', gap: 13 }}>
      <div style={{ width: 64, height: 64, borderRadius: 13, flexShrink: 0, background: 'linear-gradient(140deg, var(--green-600), var(--green-900))', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Icon name={n.category === 'Campus' ? 'institution' : 'cap'} size={26} color="#fff" strokeWidth={1.8} />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginBottom: 5 }}>
          <span style={{ fontSize: 10, fontWeight: 700, color: c.fg, background: c.bg, padding: '3px 8px', borderRadius: 999 }}>{n.category}</span>
          {n.pinned && <Icon name="star" size={13} color="#F2B01E" fill="#F2B01E" strokeWidth={1.5} />}
        </div>
        <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--ink)', lineHeight: 1.3 }}>{n.title}</div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginTop: 7, fontSize: 11, color: 'var(--ink-3)' }}>
          <span style={{ fontWeight: 600 }}>{n.source}</span><span>·</span><span>{fmtDate(n.date).replace(' de 2026', '')}</span><span>·</span><span>{n.read}</span>
        </div>
      </div>
    </Card>
  );
}

function NewsListScreen({ nav, store }) {
  const [cat, setCat] = React.useState('Todas');
  const all = store.publishedNews();
  const cats = ['Todas', ...Array.from(new Set(all.map(n => n.category)))];
  const list = all.filter(n => cat === 'Todas' || n.category === cat);
  return (
    <PageShell nav={nav} bodyPad={0} animKey={'news' + cat} header={<GreenHero nav={nav} title="Notícias" subtitle="Avisos do campus e do mundo acadêmico" icon="bell" />}>
      <div style={{ padding: 16 }}>
        <div className="u-scroll" style={{ display: 'flex', gap: 9, overflowX: 'auto', margin: '0 -16px 16px', padding: '0 16px' }}>
          {cats.map(c => <Chip key={c} active={cat === c} onClick={() => setCat(c)}>{c}</Chip>)}
        </div>
        {list.length ? (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {list.map((n, i) => <div key={n.id} style={{ animation: `u-fade-up .4s ${i * 0.05}s both` }}><NewsCard n={n} onClick={() => nav.go('newsDetail', { id: n.id })} /></div>)}
          </div>
        ) : <EmptyState icon="bell" title="Nenhuma notícia" body="Não há notícias nesta categoria por enquanto." />}
      </div>
    </PageShell>
  );
}

function NewsDetailScreen({ nav, params, store, toast }) {
  const n = store.getNewsItem(params.id);
  if (!n) return null;
  const c = NEWS_CAT_COLORS[n.category] || NEWS_CAT_COLORS['Geral'];
  return (
    <PageShell nav={nav} bodyPad={0} header={<PageHeader nav={nav} title="Notícia" actionIcon="send" onAction={() => toast('Compartilhando…', 'send')} />}>
      <div>
        {/* hero media (uploaded/linked) or gradient fallback */}
        {n.media && (n.media.src || n.media.url) ? (
          <div style={{ position: 'relative' }}>
            <MediaView media={n.media} mediaType={n.media.mediaType} toast={toast} />
            <span style={{ position: 'absolute', top: 14, left: 16, fontSize: 11, fontWeight: 700, color: '#fff', background: 'rgba(0,0,0,0.4)', padding: '5px 11px', borderRadius: 999, backdropFilter: 'blur(4px)' }}>{n.category}</span>
          </div>
        ) : (
          <div style={{ height: 180, background: 'linear-gradient(140deg, var(--green-600), var(--green-900))', position: 'relative', display: 'flex', alignItems: 'flex-end', padding: 18 }}>
            <UniverseBadge size={34} color="rgba(255,255,255,0.9)" ring="rgba(255,255,255,0.5)" style={{ position: 'absolute', top: 16, right: 18 }} />
            <span style={{ fontSize: 11, fontWeight: 700, color: '#fff', background: 'rgba(0,0,0,0.28)', padding: '5px 11px', borderRadius: 999 }}>{n.category}</span>
          </div>
        )}
        <div style={{ padding: 18 }}>
          <h1 style={{ margin: 0, fontSize: 21, fontWeight: 800, color: 'var(--ink)', lineHeight: 1.25, letterSpacing: -0.3 }}>{n.title}</h1>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, margin: '12px 0 18px', fontSize: 12, color: 'var(--ink-3)' }}>
            <span style={{ fontWeight: 700, color: 'var(--green-700)' }}>{n.source}</span><span>·</span><span>{fmtDate(n.date)}</span><span>·</span><span>{n.read} de leitura</span>
          </div>

          {n.facts && (
            <div style={{ display: 'flex', gap: 10, margin: '0 0 20px', flexWrap: 'wrap' }}>
              {n.facts.map(([k, v], i) => (
                <div key={i} style={{ flex: '1 1 30%', minWidth: 92, background: 'var(--green-050)', borderRadius: 13, padding: '11px 12px' }}>
                  <div style={{ fontSize: 10.5, color: 'var(--green-700)', fontWeight: 700 }}>{k}</div>
                  <div style={{ fontSize: 13, fontWeight: 700, color: 'var(--ink)', marginTop: 3, lineHeight: 1.25 }}>{v}</div>
                </div>
              ))}
            </div>
          )}

          <div style={{ fontSize: 14, lineHeight: 1.65 }}>
            <WikiParagraphs text={n.body} nav={nav} />
          </div>

          <Card pad={14} style={{ marginTop: 22, display: 'flex', alignItems: 'center', gap: 12, background: 'var(--green-050)' }}>
            <Icon name="globe" size={20} color="var(--green-700)" strokeWidth={1.9} />
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 12.5, fontWeight: 700, color: 'var(--ink)' }}>Fonte oficial</div>
              <div style={{ fontSize: 11.5, color: 'var(--green-700)' }}>{n.sourceUrl}</div>
            </div>
            <Button size="sm" onClick={() => toast('Abrindo ' + n.sourceUrl + '…', 'globe')}>Abrir</Button>
          </Card>
        </div>
      </div>
    </PageShell>
  );
}

function TermScreen({ nav, params }) {
  // standalone fallback screen for a glossary term (when opened as a route)
  const g = window.GLOSSARY[params.key];
  if (!g) return null;
  return (
    <PageShell nav={nav} bodyPad={0} header={<PageHeader nav={nav} title="Glossário" />}>
      <div style={{ padding: 18 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 14 }}>
          <div style={{ width: 50, height: 50, borderRadius: 14, background: 'var(--green-050)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name="book" size={26} color="var(--green-700)" strokeWidth={1.9} />
          </div>
          <h1 style={{ margin: 0, fontSize: 24, fontWeight: 800, color: 'var(--ink)' }}>{g.term || params.key}</h1>
        </div>
        <Card pad={16}><p style={{ margin: 0, fontSize: 14, lineHeight: 1.6, color: 'var(--ink-2)' }}>{g.def}</p></Card>
        {g.docId && <Button size="lg" full icon="chevR" style={{ marginTop: 16 }} onClick={() => nav.go('benefitDetail', { id: g.docId })}>Ver página completa</Button>}
      </div>
    </PageShell>
  );
}

Object.assign(window, { NewsCard, NewsListScreen, NewsDetailScreen, TermScreen });
