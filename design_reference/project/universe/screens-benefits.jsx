// screens-benefits.jsx — Benefícios (gov + inst), Estágio/Concursos, Moradia, detail

function BenefitsScreen({ nav, t, kind }) {
  const isGov = kind === 'gov';
  const items = isGov ? DATA.benGov : DATA.benInst;
  const title = isGov ? 'Benefícios Governamentais' : 'Benefícios Institucionais';
  const sub = isGov ? 'Programas e auxílios do governo' : 'Auxílios e bolsas do IFSP';
  const icon = isGov ? 'benefits' : 'award';
  const layout = t.benefitLayout || 'cards';
  const open = (b) => nav.go('benefitDetail', { ...b, kind });

  const grid = (
    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
      {items.map((b, i) => (
        <Card key={i} onClick={() => open(b)} pad={16} style={{ display: 'flex', flexDirection: 'column', gap: 10, minHeight: 132, animation: `u-fade-up .4s ${i * 0.05}s both` }}>
          <IconTile name={b.icon} size={48} icon={26} />
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 14.5, fontWeight: 700, color: 'var(--ink)' }}>{b.title}</div>
            <span style={{ display: 'inline-block', marginTop: 6, fontSize: 10, fontWeight: 700, color: 'var(--green-700)', background: 'var(--green-050)', padding: '3px 8px', borderRadius: 999 }}>{b.tag}</span>
          </div>
        </Card>
      ))}
    </div>
  );

  const cards = (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
      {items.map((b, i) => (
        <Card key={i} onClick={() => open(b)} pad={16} style={{ animation: `u-fade-up .4s ${i * 0.05}s both` }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 13, marginBottom: 10 }}>
            <IconTile name={b.icon} size={46} icon={24} />
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 15, fontWeight: 700, color: 'var(--ink)' }}>{b.title}</div>
              <span style={{ display: 'inline-block', marginTop: 4, fontSize: 10, fontWeight: 700, color: 'var(--green-700)', background: 'var(--green-050)', padding: '3px 8px', borderRadius: 999 }}>{b.tag}</span>
            </div>
            <Icon name="chevR" size={18} color="var(--ink-3)" strokeWidth={2} />
          </div>
          <p style={{ margin: 0, fontSize: 12.5, lineHeight: 1.5, color: 'var(--ink-2)', display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>{b.desc}</p>
        </Card>
      ))}
    </div>
  );

  const compact = (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
      {items.map((b, i) => (
        <div key={i} style={{ animation: `u-fade-up .4s ${i * 0.05}s both` }}>
          <ListRow icon={b.icon} title={b.title} subtitle={b.tag} onClick={() => open(b)} />
        </div>
      ))}
    </div>
  );

  return (
    <PageShell nav={nav} bodyPad={0} header={<GreenHero nav={nav} title={title} subtitle={sub} icon={icon} />} animKey={kind + layout}>
      <div style={{ padding: 16 }}>
        <p style={{ margin: '0 0 16px', fontSize: 13, lineHeight: 1.55, color: 'var(--ink-2)' }}>
          {isGov ? 'Conheça os principais benefícios oferecidos pelo governo a estudantes. Toque para ver como solicitar.' : 'O IFSP oferece auxílios e bolsas para apoiar sua permanência e desenvolvimento acadêmico.'}
        </p>
        {layout === 'grid' ? grid : layout === 'list' ? compact : cards}
      </div>
    </PageShell>
  );
}

function BenefitDetailScreen({ nav, params, toast }) {
  const b = params;
  return (
    <PageShell nav={nav} bodyPad={0} header={
      <GreenHero nav={nav} title={b.title} subtitle={b.kind === 'gov' ? 'Benefício governamental' : 'Benefício institucional'} icon={b.icon}>
        <span style={{ display: 'inline-block', marginTop: 14, fontSize: 11, fontWeight: 700, color: '#fff', background: 'rgba(255,255,255,0.18)', padding: '5px 12px', borderRadius: 999 }}>{b.tag}</span>
      </GreenHero>
    }>
      <div style={{ padding: 16 }}>
        <SectionTitle>O que é</SectionTitle>
        <Card pad={16} style={{ marginBottom: 20 }}>
          <p style={{ margin: 0, fontSize: 13.5, lineHeight: 1.6, color: 'var(--ink-2)' }}>{b.desc}</p>
        </Card>
        <SectionTitle>Como solicitar</SectionTitle>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12, marginBottom: 22 }}>
          {b.steps.map((s, i) => (
            <div key={i} style={{ display: 'flex', gap: 13, alignItems: 'flex-start', animation: `u-fade-up .4s ${i * 0.06}s both` }}>
              <div style={{ width: 28, height: 28, borderRadius: '50%', flexShrink: 0, background: 'var(--green-800)', color: '#fff', fontSize: 13, fontWeight: 800, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{i + 1}</div>
              <div style={{ flex: 1, paddingTop: 4, fontSize: 13.5, lineHeight: 1.45, color: 'var(--ink)' }}>{s}</div>
            </div>
          ))}
        </div>
        <Button size="lg" full icon="globe" onClick={() => toast('Abrindo portal oficial…', 'globe')}>Acessar portal oficial</Button>
        <button onClick={() => nav.go('duvidas')} className="u-press" style={{ width: '100%', marginTop: 10, padding: 14, fontSize: 13.5, fontWeight: 700, color: 'var(--green-700)' }}>Tenho uma dúvida sobre isso</button>
      </div>
    </PageShell>
  );
}

function MoradiaScreen({ nav, toast }) {
  const tips = [
    { icon: 'pin', t: 'Procure perto da CPTM', d: 'A Linha 7-Rubi conecta Pirituba ao centro em ~25 min.' },
    { icon: 'benefits', t: 'Auxílio-moradia', d: 'Estudantes em vulnerabilidade podem solicitar pelo PAP.' },
    { icon: 'shield', t: 'Verifique contratos', d: 'Confira condições antes de assinar qualquer aluguel.' },
  ];
  return (
    <PageShell nav={nav} bodyPad={0} header={<GreenHero nav={nav} title="Moradia" subtitle="Onde morar perto do campus" icon="house" />}>
      <div style={{ padding: 16 }}>
        <Card pad={16} style={{ marginBottom: 20, background: 'linear-gradient(150deg, var(--green-050), #fff)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 13 }}>
            <IconTile name="benefits" size={48} icon={26} bg="var(--green-100)" />
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 15, fontWeight: 800, color: 'var(--ink)' }}>Auxílio-moradia</div>
              <div style={{ fontSize: 12, color: 'var(--ink-2)', marginTop: 2 }}>Apoio financeiro para quem precisa</div>
            </div>
          </div>
          <Button size="md" full style={{ marginTop: 14 }} onClick={() => nav.go('benInst')}>Ver pelo PAP</Button>
        </Card>
        <SectionTitle>Dicas para morar em Pirituba</SectionTitle>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 11 }}>
          {tips.map((tp, i) => (
            <Card key={i} pad={15} style={{ display: 'flex', gap: 13, animation: `u-fade-up .4s ${i * 0.05}s both` }}>
              <IconTile name={tp.icon} size={44} icon={22} />
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--ink)' }}>{tp.t}</div>
                <div style={{ fontSize: 12.5, color: 'var(--ink-2)', marginTop: 3, lineHeight: 1.45 }}>{tp.d}</div>
              </div>
            </Card>
          ))}
        </div>
        <div style={{ marginTop: 16 }}>
          <Button variant="outline" size="md" full icon="search" onClick={() => nav.go('republicas')}>Buscar repúblicas próximas</Button>
        </div>
      </div>
    </PageShell>
  );
}

Object.assign(window, { BenefitsScreen, BenefitDetailScreen, MoradiaScreen });
