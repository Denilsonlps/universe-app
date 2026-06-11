// screens-main.jsx — Home, IFSP, Cursos, Course detail

function Greeting({ user }) {
  const h = new Date().getHours();
  const g = h < 12 ? 'Bom dia' : h < 18 ? 'Boa tarde' : 'Boa noite';
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 16 }}>
      <Avatar name={user.name} size={46} />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 12.5, color: 'var(--ink-3)', fontWeight: 600 }}>{g},</div>
        <div style={{ fontSize: 18, fontWeight: 800, color: 'var(--ink)', letterSpacing: -0.3 }}>{user.name.split(' ')[0]}</div>
      </div>
    </div>
  );
}

function SearchBar({ onClick }) {
  return (
    <div onClick={onClick} className="u-press" style={{ display: 'flex', alignItems: 'center', gap: 10, height: 46, padding: '0 16px', background: 'var(--card)', borderRadius: 14, boxShadow: 'var(--shadow-sm)', marginBottom: 18, cursor: 'pointer' }}>
      <Icon name="search" size={19} color="var(--ink-3)" />
      <span style={{ fontSize: 14, color: 'var(--ink-3)' }}>Buscar cursos, benefícios, dúvidas…</span>
    </div>
  );
}

function HighlightCard({ nav }) {
  return (
    <div onClick={() => nav.go('estagio')} className="u-press" style={{
      borderRadius: 'var(--radius)', padding: 18, marginBottom: 22, cursor: 'pointer',
      background: 'linear-gradient(150deg, var(--green-600), var(--green-900))', color: '#fff',
      boxShadow: '0 10px 24px rgba(0,87,58,0.25)', position: 'relative', overflow: 'hidden',
    }}>
      <div style={{ position: 'absolute', right: -28, top: -28, width: 120, height: 120, borderRadius: '50%', background: 'rgba(38,193,125,0.25)' }} />
      <div style={{ position: 'relative' }}>
        <span style={{ fontSize: 11, fontWeight: 700, letterSpacing: 0.4, background: 'rgba(255,255,255,0.16)', padding: '4px 10px', borderRadius: 999 }}>EM DESTAQUE</span>
        <h3 style={{ margin: '12px 0 4px', fontSize: 18, fontWeight: 800, letterSpacing: -0.3 }}>Estágio em Dev Web</h3>
        <p style={{ margin: 0, fontSize: 13, color: 'rgba(255,255,255,0.8)' }}>Prefeitura de SP · bolsa R$ 1.100 + VT</p>
        <div style={{ display: 'flex', alignItems: 'center', gap: 5, marginTop: 14, fontSize: 13, fontWeight: 700 }}>
          Ver vaga <Icon name="chevR" size={16} color="#fff" strokeWidth={2.4} />
        </div>
      </div>
    </div>
  );
}

function HomeScreen({ nav, t, user }) {
  const layout = t.homeLayout || 'list';
  const go = (it) => it.tab ? nav.tab(it.screen) : nav.go(it.screen);

  const grid = (
    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
      {DATA.home.map((it, i) => (
        <Card key={i} onClick={() => go(it)} pad={16} style={{ display: 'flex', flexDirection: 'column', gap: 12, minHeight: 128, animation: `u-fade-up .4s ${i * 0.04}s both` }}>
          <IconTile name={it.icon} size={48} icon={26} />
          <div>
            <div style={{ fontSize: 13.5, fontWeight: 700, color: 'var(--ink)', lineHeight: 1.25 }}>{it.title}</div>
            <div style={{ fontSize: 11, color: 'var(--ink-3)', marginTop: 3, lineHeight: 1.35 }}>{it.sub}</div>
          </div>
        </Card>
      ))}
    </div>
  );

  const list = (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 11 }}>
      {DATA.home.map((it, i) => (
        <div key={i} style={{ animation: `u-fade-up .4s ${i * 0.04}s both` }}>
          <ListRow icon={it.icon} title={it.title} subtitle={it.sub} onClick={() => go(it)} />
        </div>
      ))}
    </div>
  );
  const feature = (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 11 }}>
      <Card onClick={() => go(DATA.home[0])} pad={0} style={{ overflow: 'hidden', animation: 'u-fade-up .4s both' }}>
        <div style={{ background: 'linear-gradient(150deg, var(--green-500), var(--green-800))', padding: 20, color: '#fff', position: 'relative' }}>
          <UniverseBadge size={32} color="rgba(255,255,255,0.95)" ring="rgba(255,255,255,0.6)" style={{ position: 'absolute', right: 18, top: 18 }} />
          <div style={{ width: 48, height: 48, borderRadius: 13, background: 'rgba(255,255,255,0.16)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 40 }}>
            <Icon name={DATA.home[0].icon} size={26} color="#fff" strokeWidth={1.9} />
          </div>
          <div style={{ fontSize: 18, fontWeight: 800 }}>{DATA.home[0].title}</div>
          <div style={{ fontSize: 12.5, color: 'rgba(255,255,255,0.82)', marginTop: 3 }}>{DATA.home[0].sub}</div>
        </div>
      </Card>
      {DATA.home.slice(1).map((it, i) => (
        <div key={i} style={{ animation: `u-fade-up .4s ${(i + 1) * 0.04}s both` }}>
          <ListRow icon={it.icon} title={it.title} subtitle={it.sub} onClick={() => go(it)} />
        </div>
      ))}
    </div>
  );

  return (
    <PageShell tab="home" nav={nav} header={<HomeHeader nav={nav} />} animKey={'home-' + layout}>
      <Greeting user={user} />
      <SearchBar onClick={() => nav.go('search')} />

      {/* quick actions */}
      <div className="u-scroll" style={{ display: 'flex', gap: 9, overflowX: 'auto', margin: '0 -16px 20px', padding: '0 16px' }}>
        {DATA.quick.map((q, i) => (
          <Chip key={i} icon={q.icon} onClick={() => q.tab ? nav.tab(q.screen) : nav.go(q.screen)}>{q.label}</Chip>
        ))}
      </div>

      <HighlightCard nav={nav} />
      <SectionTitle>Explorar</SectionTitle>
      {layout === 'grid' ? grid : layout === 'feature' ? feature : list}
    </PageShell>
  );
}

function IfspScreen({ nav }) {
  return (
    <PageShell nav={nav} bodyPad={0} header={
      <GreenHero nav={nav} title="IFSP Pirituba" subtitle="Campus São Paulo Pirituba" icon="institution" tall>
        <div style={{ display: 'flex', gap: 10, marginTop: 18 }}>
          {[['Fundado', '1909'], ['Cursos', '10+'], ['Alunos', '1.2k']].map(([k, v], i) => (
            <div key={i} style={{ flex: 1, background: 'rgba(255,255,255,0.12)', borderRadius: 13, padding: '11px 8px', textAlign: 'center' }}>
              <div style={{ fontSize: 17, fontWeight: 800 }}>{v}</div>
              <div style={{ fontSize: 10.5, color: 'rgba(255,255,255,0.75)', marginTop: 2 }}>{k}</div>
            </div>
          ))}
        </div>
      </GreenHero>
    }>
      <div style={{ padding: 16 }}>
        <SectionTitle>Sobre o campus</SectionTitle>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {DATA.ifspInfo.map((it, i) => (
            <div key={i} style={{ animation: `u-fade-up .4s ${i * 0.04}s both` }}>
              <ListRow icon={it.icon} title={it.title} subtitle={it.sub} onClick={() => nav.go('ifspDetail', { key: it.key })} />
            </div>
          ))}
        </div>
        {/* map placeholder */}
        <div style={{ marginTop: 16, borderRadius: 'var(--radius)', overflow: 'hidden', boxShadow: 'var(--shadow-sm)', height: 150, background: 'repeating-linear-gradient(135deg, #E5EDE7 0 12px, #DCE7DE 12px 24px)', position: 'relative', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', flexDirection: 'column', gap: 6, color: 'var(--green-700)' }}>
            <Icon name="pin" size={30} color="var(--green-700)" strokeWidth={1.8} />
            <span style={{ fontFamily: 'monospace', fontSize: 11, color: 'var(--ink-3)' }}>mapa do campus</span>
          </div>
        </div>
      </div>
    </PageShell>
  );
}

function CursosScreen({ nav }) {
  const [cat, setCat] = React.useState('Todos');
  const [q, setQ] = React.useState('');
  const list = DATA.courses.filter(c => (cat === 'Todos' || c.cat === cat) && c.name.toLowerCase().includes(q.toLowerCase()));
  return (
    <PageShell tab="cursos" nav={nav} header={
      <div style={{ paddingTop: STATUS_H, padding: `${STATUS_H}px 16px 12px`, background: 'var(--bg)' }}>
        <h1 style={{ margin: '0 0 12px', fontSize: 26, fontWeight: 800, color: 'var(--ink)', letterSpacing: -0.4 }}>Cursos</h1>
        <Field icon="search" value={q} onChange={setQ} placeholder="Buscar curso…" />
      </div>
    } animKey={'cursos-' + cat}>
      <div className="u-scroll" style={{ display: 'flex', gap: 9, overflowX: 'auto', margin: '0 -16px 16px', padding: '0 16px' }}>
        {DATA.courseCats.map(c => <Chip key={c} active={cat === c} onClick={() => setCat(c)}>{c}</Chip>)}
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 11 }}>
        {list.map((c, i) => (
          <Card key={c.name} onClick={() => nav.go('courseDetail', c)} pad={15} style={{ display: 'flex', alignItems: 'center', gap: 14, animation: `u-fade-up .35s ${i * 0.03}s both` }}>
            <IconTile name={c.icon} size={48} icon={24} bg="var(--green-050)" />
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--ink)', lineHeight: 1.25 }}>{c.name}</div>
              <div style={{ display: 'flex', gap: 8, marginTop: 6, flexWrap: 'wrap' }}>
                <span style={{ fontSize: 10.5, fontWeight: 700, color: 'var(--green-700)', background: 'var(--green-050)', padding: '3px 8px', borderRadius: 999 }}>{c.cat}</span>
                <span style={{ fontSize: 11, color: 'var(--ink-3)' }}>{c.period} · {c.dur}</span>
              </div>
            </div>
            <Icon name="chevR" size={18} color="var(--ink-3)" strokeWidth={2} />
          </Card>
        ))}
        {list.length === 0 && <EmptyState icon="search" title="Nenhum curso encontrado" body="Tente outro termo ou categoria." action="Limpar filtros" onAction={() => { setCat('Todos'); setQ(''); }} />}
      </div>
    </PageShell>
  );
}

function courseShort(cat, name) {
  const map = { 'Análise e Desenvolvimento de Sistemas': 'ADS', 'Gestão Pública': 'Gestão Pública', 'Engenharia de Produção': 'Eng. de Produção', 'Redes de Computadores': 'Redes', 'Administração': 'Administração', 'Logística': 'Logística' };
  return map[name] || 'Todos';
}

function CourseDetailScreen({ nav, params, toast }) {
  const c = params;
  const meta = [['Tipo', c.type], ['Duração', c.dur], ['Período', c.period], ['Modalidade', 'Presencial']];
  return (
    <PageShell nav={nav} bodyPad={0} header={
      <GreenHero nav={nav} title={c.name} subtitle={c.cat + ' · ' + c.type} icon={c.icon} />
    }>
      <div style={{ padding: 16 }}>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, marginBottom: 18 }}>
          {meta.map(([k, v], i) => (
            <Card key={i} pad={14}>
              <div style={{ fontSize: 11, color: 'var(--ink-3)', fontWeight: 600 }}>{k}</div>
              <div style={{ fontSize: 14.5, fontWeight: 700, color: 'var(--ink)', marginTop: 3 }}>{v}</div>
            </Card>
          ))}
        </div>
        <SectionTitle>Sobre o curso</SectionTitle>
        <Card pad={16} style={{ marginBottom: 18 }}>
          <p style={{ margin: 0, fontSize: 13.5, lineHeight: 1.6, color: 'var(--ink-2)' }}>
            O curso de {c.name} forma profissionais com sólida base teórica e prática, preparados para o mercado de trabalho e para a continuidade dos estudos. As aulas acontecem no período {c.period.toLowerCase()}, no campus Pirituba.
          </p>
        </Card>
        <SectionTitle>Formas de ingresso</SectionTitle>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginBottom: 20 }}>
          {[['Vestibular IFSP', 'Prova realizada no fim do ano'], ['SiSU / Enem', 'Parte das vagas via nota do Enem'], ['Transferência', 'Para alunos de outras instituições']].map(([t2, s], i) => (
            <ListRow key={i} icon="flag" title={t2} subtitle={s} trailing={null} onClick={() => {}} iconColor="var(--green-700)" />
          ))}
        </div>
        <Button size="lg" full icon="briefcase" onClick={() => nav.go('estagio', { course: courseShort(c.cat, c.name) })}>Ver estágios para este curso</Button>
      </div>
    </PageShell>
  );
}

Object.assign(window, { HomeScreen, IfspScreen, CursosScreen, CourseDetailScreen });
