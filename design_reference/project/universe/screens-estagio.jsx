// screens-estagio.jsx — Estágios/Concursos list, details, depoimentos, repúblicas, admin

function VagaCard({ e, onClick, i }) {
  const closed = e.status === 'closed';
  return (
    <Card onClick={onClick} pad={16} style={{ animation: `u-fade-up .4s ${i * 0.05}s both`, opacity: closed ? 0.82 : 1 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 8 }}>
        <div style={{ fontSize: 15, fontWeight: 700, color: 'var(--ink)', lineHeight: 1.3 }}>{e.role}</div>
        {closed ? <StatusBadge status="closed" /> : e.tag ? <span style={{ fontSize: 10, fontWeight: 800, color: '#fff', background: 'var(--green-500)', padding: '4px 9px', borderRadius: 999, flexShrink: 0 }}>{e.tag}</span> : <StatusBadge status="open" />}
      </div>
      <div style={{ fontSize: 12.5, color: 'var(--ink-2)', marginTop: 6, display: 'flex', alignItems: 'center', gap: 6 }}>
        <Icon name="institution" size={14} color="var(--ink-3)" /> {e.org}
      </div>
      <div style={{ display: 'flex', gap: 8, marginTop: 12, flexWrap: 'wrap' }}>
        <span style={{ fontSize: 11, fontWeight: 600, color: 'var(--ink-2)', background: 'var(--bg-2)', padding: '5px 10px', borderRadius: 999 }}>{e.mode}</span>
        <span style={{ fontSize: 11, fontWeight: 700, color: 'var(--green-700)', background: 'var(--green-050)', padding: '5px 10px', borderRadius: 999 }}>{e.grant}/mês</span>
        <span style={{ fontSize: 11, fontWeight: 600, color: 'var(--ink-2)', background: 'var(--bg-2)', padding: '5px 10px', borderRadius: 999 }}>{e.course}</span>
      </div>
    </Card>
  );
}

function EstagioScreen({ nav, toast, params }) {
  const [tab, setTab] = React.useState(params && params.tab === 'Concursos' ? 'Concursos' : 'Estágios');
  const [course, setCourse] = React.useState((params && params.course) || 'Todos');
  const isEst = tab === 'Estágios';
  const estList = DATA.estagios.filter(e => course === 'Todos' || e.course === course);

  return (
    <PageShell nav={nav} bodyPad={0} animKey={tab + course} header={
      <GreenHero nav={nav} title="Estágio e Concursos" subtitle="Vagas, editais e oportunidades" icon="briefcase"
        action={<button onClick={() => nav.go('adminLogin')} className="u-press" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', width: 38, height: 38, borderRadius: 11, background: 'rgba(255,255,255,0.14)' }}><Icon name="shield" size={20} color="#fff" strokeWidth={1.9} /></button>} />
    }>
      <div style={{ padding: 16 }}>
        <div style={{ display: 'flex', background: 'var(--bg-2)', borderRadius: 13, padding: 4, marginBottom: 16 }}>
          {DATA.estagioTabs.map(tb => (
            <button key={tb} onClick={() => setTab(tb)} className="u-press" style={{ flex: 1, height: 38, borderRadius: 10, fontSize: 13.5, fontWeight: 700, color: tab === tb ? 'var(--green-800)' : 'var(--ink-3)', background: tab === tb ? 'var(--card)' : 'transparent', boxShadow: tab === tb ? 'var(--shadow-sm)' : 'none', transition: 'all .2s' }}>{tb}</button>
          ))}
        </div>

        {isEst && (
          <div className="u-scroll" style={{ display: 'flex', gap: 9, overflowX: 'auto', margin: '0 -16px 16px', padding: '0 16px' }}>
            {DATA.estagioCourses.map(c => <Chip key={c} active={course === c} onClick={() => setCourse(c)}>{c}</Chip>)}
          </div>
        )}

        {isEst ? (
          estList.length ? (
            <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
              {estList.map((e, i) => <VagaCard key={e.id} e={e} i={i} onClick={() => nav.go('vagaDetail', e)} />)}
            </div>
          ) : <EmptyState icon="briefcase" title="Nenhuma vaga para este curso" body="Ainda não há estágios abertos para o filtro selecionado. Tente outro curso." action="Ver todos" onAction={() => setCourse('Todos')} />
        ) : (
          DATA.concursos.length ? (
            <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
              {DATA.concursos.map((c, i) => {
                const closed = c.status === 'closed';
                return (
                  <Card key={c.id} onClick={() => nav.go('concursoDetail', c)} pad={16} style={{ animation: `u-fade-up .4s ${i * 0.05}s both`, opacity: closed ? 0.82 : 1 }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 8 }}>
                      <div style={{ fontSize: 15, fontWeight: 700, color: 'var(--ink)', lineHeight: 1.3 }}>{c.role}</div>
                      <StatusBadge status={c.status} openLabel="Abertas" closedLabel="Encerradas" />
                    </div>
                    <div style={{ fontSize: 12.5, color: 'var(--ink-2)', marginTop: 6 }}>{c.org}</div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 12, fontSize: 12, fontWeight: 600, flexWrap: 'wrap' }}>
                      <span style={{ color: 'var(--green-700)' }}>{c.vagas}</span>
                      <span style={{ color: 'var(--ink-2)' }}>{c.salary}</span>
                      <span style={{ color: 'var(--ink-3)', display: 'flex', alignItems: 'center', gap: 4 }}><Icon name="clock" size={13} color="var(--ink-3)" /> {c.period.replace('até ', '').replace('encerrado em ', '')}</span>
                    </div>
                  </Card>
                );
              })}
            </div>
          ) : <EmptyState icon="doc" title="Nenhum concurso aberto" body="No momento não há concursos com inscrições abertas. Volte em breve." />
        )}

        {/* Depoimentos */}
        {isEst && (
          <div style={{ marginTop: 26 }}>
            <SectionTitle action="Ver todos" onAction={() => nav.go('depoimentos')}>Depoimentos</SectionTitle>
            <div className="u-scroll" style={{ display: 'flex', gap: 12, overflowX: 'auto', margin: '0 -16px', padding: '0 16px 4px' }}>
              {DATA.testimonials.map((t, i) => <DepoCard key={i} t={t} compact />)}
            </div>
          </div>
        )}
      </div>
    </PageShell>
  );
}

function DepoCard({ t, compact }) {
  return (
    <Card pad={16} style={{ width: compact ? 250 : 'auto', flexShrink: 0 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 11, marginBottom: 11 }}>
        <Avatar name={t.name} size={40} />
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: 13.5, fontWeight: 700, color: 'var(--ink)' }}>{t.name}</div>
          <div style={{ fontSize: 11, color: 'var(--ink-3)' }}>{t.course} · {t.org}</div>
        </div>
      </div>
      <Stars n={t.stars} />
      <p style={{ margin: '9px 0 0', fontSize: 12.5, lineHeight: 1.5, color: 'var(--ink-2)' }}>“{t.text}”</p>
    </Card>
  );
}

function DepoimentosScreen({ nav, user, toast }) {
  const [adding, setAdding] = React.useState(false);
  const [draft, setDraft] = React.useState({ org: '', text: '', stars: 5 });
  const [extra, setExtra] = React.useState([]);
  const all = [...extra, ...DATA.testimonials];
  const submit = () => {
    setExtra([{ name: user.name, course: user.course.split(' ')[0], org: draft.org, stars: draft.stars, text: draft.text }, ...extra]);
    setAdding(false); setDraft({ org: '', text: '', stars: 5 });
    toast('Depoimento publicado!', 'checkCircle');
  };
  return (
    <PageShell nav={nav} bodyPad={0} header={<GreenHero nav={nav} title="Depoimentos" subtitle="Quem já estagiou conta como foi" icon="star" />}>
      <div style={{ padding: 16 }}>
        {!adding ? (
          <Button full size="md" icon="plus" style={{ marginBottom: 16 }} onClick={() => setAdding(true)}>Adicionar meu depoimento</Button>
        ) : (
          <Card pad={16} style={{ marginBottom: 16 }}>
            <div style={{ fontSize: 14.5, fontWeight: 800, color: 'var(--ink)', marginBottom: 12 }}>Seu depoimento</div>
            <Field label="Onde você estagiou?" icon="institution" value={draft.org} onChange={v => setDraft({ ...draft, org: v })} placeholder="Empresa / órgão" style={{ marginBottom: 12 }} />
            <label style={{ display: 'block', fontSize: 12.5, fontWeight: 600, color: 'var(--ink-2)', margin: '0 0 7px 3px' }}>Sua nota</label>
            <div style={{ display: 'flex', gap: 6, marginBottom: 12 }}>
              {[1, 2, 3, 4, 5].map(s => (
                <button key={s} onClick={() => setDraft({ ...draft, stars: s })} className="u-press">
                  <Icon name="star" size={28} color={s <= draft.stars ? '#F2B01E' : 'var(--line)'} fill={s <= draft.stars ? '#F2B01E' : 'none'} strokeWidth={1.6} />
                </button>
              ))}
            </div>
            <Field multiline label="Como foi a experiência?" value={draft.text} onChange={v => setDraft({ ...draft, text: v })} placeholder="Conte para os colegas…" maxLength={280} />
            <div style={{ display: 'flex', gap: 10, marginTop: 14 }}>
              <Button variant="ghost" size="md" full onClick={() => setAdding(false)}>Cancelar</Button>
              <Button size="md" full icon="send" disabled={draft.org.trim().length < 2 || draft.text.trim().length < 10} onClick={submit}>Publicar</Button>
            </div>
          </Card>
        )}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          {all.map((t, i) => <DepoCard key={i} t={t} />)}
        </div>
      </div>
    </PageShell>
  );
}

function VagaDetailScreen({ nav, params, toast }) {
  const e = params;
  const closed = e.status === 'closed';
  const meta = [['Modalidade', e.mode], ['Bolsa', e.grant + '/mês'], ['Carga horária', e.dur.split(' · ')[0]], ['Duração', e.dur.split(' · ')[1] || e.dur]];
  return (
    <PageShell nav={nav} bodyPad={0} header={
      <GreenHero nav={nav} title={e.role} subtitle={e.org + ' · ' + e.area} icon="briefcase">
        <div style={{ marginTop: 14 }}>{closed ? <StatusBadge status="closed" style={{ background: 'rgba(255,255,255,0.16)', color: '#fff' }} /> : <StatusBadge status="open" style={{ background: 'rgba(255,255,255,0.16)', color: '#fff' }} />}</div>
      </GreenHero>
    }>
      <div style={{ padding: 16 }}>
        {closed && (
          <Card pad={14} style={{ marginBottom: 16, background: 'rgba(226,59,46,0.07)', display: 'flex', gap: 11, alignItems: 'center' }}>
            <Icon name="clock" size={20} color="#C0392B" strokeWidth={2} />
            <div style={{ fontSize: 12.5, color: '#9B2C20', fontWeight: 600, lineHeight: 1.4 }}>Esta vaga está encerrada. Mantemos visível por 1 mês como referência.</div>
          </Card>
        )}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, marginBottom: 18 }}>
          {meta.map(([k, v], i) => (
            <Card key={i} pad={14}>
              <div style={{ fontSize: 11, color: 'var(--ink-3)', fontWeight: 600 }}>{k}</div>
              <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--ink)', marginTop: 3 }}>{v}</div>
            </Card>
          ))}
        </div>

        <SectionTitle>Benefícios</SectionTitle>
        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 20 }}>
          {e.benefits.map((b, i) => (
            <span key={i} style={{ fontSize: 12, fontWeight: 600, color: 'var(--green-700)', background: 'var(--green-050)', padding: '8px 13px', borderRadius: 999, display: 'inline-flex', alignItems: 'center', gap: 6 }}>
              <Icon name="check" size={14} color="var(--green-600)" strokeWidth={2.4} /> {b}
            </span>
          ))}
        </div>

        <SectionTitle>Pré-requisitos</SectionTitle>
        <Card pad={16} style={{ marginBottom: 16 }}>
          {e.reqs.map((r, i) => (
            <div key={i} style={{ display: 'flex', gap: 11, alignItems: 'flex-start', padding: '7px 0' }}>
              <Icon name="checkCircle" size={18} color="var(--green-500)" strokeWidth={2} style={{ marginTop: 1 }} />
              <span style={{ flex: 1, fontSize: 13.5, color: 'var(--ink)', lineHeight: 1.45 }}>{r}</span>
            </div>
          ))}
        </Card>

        <SectionTitle>Diferenciais desejáveis</SectionTitle>
        <Card pad={16} style={{ marginBottom: 16 }}>
          {e.nice.map((r, i) => (
            <div key={i} style={{ display: 'flex', gap: 11, alignItems: 'flex-start', padding: '7px 0' }}>
              <Icon name="plus" size={18} color="var(--ink-3)" strokeWidth={2.2} style={{ marginTop: 1 }} />
              <span style={{ flex: 1, fontSize: 13.5, color: 'var(--ink-2)', lineHeight: 1.45 }}>{r}</span>
            </div>
          ))}
        </Card>

        <SectionTitle>Sobre a empresa</SectionTitle>
        <Card pad={16} style={{ marginBottom: 22 }}>
          <p style={{ margin: 0, fontSize: 13.5, lineHeight: 1.6, color: 'var(--ink-2)' }}>{e.about}</p>
        </Card>

        {closed
          ? <Button size="lg" full disabled>Vaga encerrada</Button>
          : <Button size="lg" full icon="send" onClick={() => toast('Abrindo ' + e.link + '…', 'globe')}>Quero me candidatar</Button>}
        <div style={{ textAlign: 'center', fontSize: 11.5, color: 'var(--ink-3)', marginTop: 10 }}>Você será direcionado para {e.link}</div>
      </div>
    </PageShell>
  );
}

function ConcursoDetailScreen({ nav, params, toast }) {
  const c = params;
  const closed = c.status === 'closed';
  const meta = [['Vagas', c.vagas], ['Salário', c.salary], ['Escolaridade', c.level], ['Inscrições', c.period]];
  return (
    <PageShell nav={nav} bodyPad={0} header={
      <GreenHero nav={nav} title={c.role} subtitle={c.org} icon="doc">
        <div style={{ marginTop: 14 }}><StatusBadge status={c.status} openLabel="Inscrições abertas" closedLabel="Inscrições encerradas" style={{ background: 'rgba(255,255,255,0.16)', color: '#fff' }} /></div>
      </GreenHero>
    }>
      <div style={{ padding: 16 }}>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, marginBottom: 18 }}>
          {meta.map(([k, v], i) => (
            <Card key={i} pad={14}>
              <div style={{ fontSize: 11, color: 'var(--ink-3)', fontWeight: 600 }}>{k}</div>
              <div style={{ fontSize: 13.5, fontWeight: 700, color: 'var(--ink)', marginTop: 3 }}>{v}</div>
            </Card>
          ))}
        </div>
        <SectionTitle>Sobre o concurso</SectionTitle>
        <Card pad={16} style={{ marginBottom: 22 }}>
          <p style={{ margin: 0, fontSize: 13.5, lineHeight: 1.6, color: 'var(--ink-2)' }}>{c.about}</p>
        </Card>
        {closed
          ? <Button size="lg" full disabled>Inscrições encerradas</Button>
          : <Button size="lg" full icon="doc" onClick={() => toast('Abrindo edital…', 'globe')}>Acessar edital</Button>}
        <div style={{ textAlign: 'center', fontSize: 11.5, color: 'var(--ink-3)', marginTop: 10 }}>{c.link}</div>
      </div>
    </PageShell>
  );
}

function RepublicasScreen({ nav, toast }) {
  return (
    <PageShell nav={nav} bodyPad={0} header={<GreenHero nav={nav} title="Repúblicas próximas" subtitle="Dicas e links úteis para morar perto" icon="house" />}>
      <div style={{ padding: 16 }}>
        <SectionTitle>O que considerar</SectionTitle>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 11, marginBottom: 22 }}>
          {DATA.republicas.map((r, i) => (
            <Card key={i} pad={15} style={{ display: 'flex', gap: 13, animation: `u-fade-up .4s ${i * 0.05}s both` }}>
              <IconTile name={r.icon} size={46} icon={23} />
              <div style={{ flex: 1 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                  <span style={{ fontSize: 14, fontWeight: 700, color: 'var(--ink)' }}>{r.t}</span>
                </div>
                <div style={{ fontSize: 12.5, color: 'var(--ink-2)', marginTop: 3, lineHeight: 1.45 }}>{r.d}</div>
                <span style={{ display: 'inline-block', marginTop: 8, fontSize: 10.5, fontWeight: 700, color: 'var(--green-700)', background: 'var(--green-050)', padding: '3px 9px', borderRadius: 999 }}>{r.tag}</span>
              </div>
            </Card>
          ))}
        </div>
        <SectionTitle>Links úteis</SectionTitle>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {DATA.republicaLinks.map((l, i) => (
            <ListRow key={i} icon={l.icon} title={l.t} subtitle={l.d}
              trailing={<Icon name={l.copy ? 'doc' : 'chevR'} size={17} color="var(--ink-3)" strokeWidth={2} />}
              onClick={() => l.screen ? nav.go(l.screen) : l.copy ? nav.copy(l.copy) : toast('Abrindo ' + l.url + '…', 'globe')} />
          ))}
        </div>
      </div>
    </PageShell>
  );
}

// ── Admin (Setor de Estágios) — login + painel
function AdminLoginScreen({ nav, toast }) {
  const [email, setEmail] = React.useState('estagios@ifsp.edu.br');
  const [pw, setPw] = React.useState('');
  const [err, setErr] = React.useState(null);
  const submit = () => {
    if (pw.length < 4) { setErr('Senha obrigatória'); return; }
    nav.go('adminPanel'); toast('Acesso administrativo concedido', 'shield');
  };
  return (
    <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(168deg, #1B2A3F 0%, #0E1A2B 70%)', display: 'flex', flexDirection: 'column', color: '#fff' }}>
      <div style={{ paddingTop: STATUS_H, padding: `${STATUS_H}px 12px 0` }}>
        <button onClick={() => nav.back()} className="u-press" style={{ width: 40, height: 40, borderRadius: 11, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Icon name="chevL" size={24} color="#fff" strokeWidth={2.2} />
        </button>
      </div>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', padding: '0 26px' }}>
        <div style={{ width: 64, height: 64, borderRadius: 18, background: 'rgba(255,255,255,0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 20 }}>
          <Icon name="shield" size={32} color="#4F9CE8" strokeWidth={1.8} />
        </div>
        <h1 style={{ margin: 0, fontSize: 24, fontWeight: 800 }}>Painel do Setor de Estágios</h1>
        <p style={{ margin: '8px 0 26px', fontSize: 13.5, color: 'rgba(255,255,255,0.6)', lineHeight: 1.5 }}>Acesso restrito à equipe responsável pelo cadastro de vagas.</p>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 13 }}>
          <Field icon="mail" value={email} onChange={setEmail} placeholder="E-mail institucional" />
          <PasswordField icon="lock" value={pw} onChange={v => { setPw(v); setErr(null); }} placeholder="Senha de administrador" error={err} />
        </div>
        <div style={{ marginTop: 22 }}>
          <Button size="lg" full variant="white" icon="lock" onClick={submit}>Entrar no painel</Button>
        </div>
        <div style={{ textAlign: 'center', fontSize: 11.5, color: 'rgba(255,255,255,0.45)', marginTop: 16 }}>Login diferenciado · não use sua conta de aluno</div>
      </div>
    </div>
  );
}

function AdminPanelScreen({ nav, toast }) {
  const [vagas, setVagas] = React.useState(() => DATA.estagios.map(e => ({ id: e.id, role: e.role, org: e.org, active: e.status === 'open' })));
  const [form, setForm] = React.useState(null); // null | {} for new/edit
  const blank = { role: '', org: '', area: '', course: 'ADS', mode: 'Híbrido', grant: '', active: true, expires: '' };

  const save = () => {
    setVagas(v => [{ id: 'n' + Date.now(), role: form.role, org: form.org, active: form.active }, ...v]);
    setForm(null); toast('Vaga cadastrada com sucesso!', 'checkCircle');
  };
  const toggle = id => setVagas(v => v.map(x => x.id === id ? { ...x, active: !x.active } : x));

  if (form) {
    const valid = form.role.trim().length > 3 && form.org.trim().length > 1 && form.grant.trim().length > 0;
    return (
      <PageShell nav={nav} bodyPad={0} bg="#0E1A2B" header={
        <div style={{ paddingTop: STATUS_H, padding: `${STATUS_H}px 12px 12px`, display: 'flex', alignItems: 'center', gap: 6, background: '#0E1A2B', color: '#fff' }}>
          <button onClick={() => setForm(null)} className="u-press" style={{ width: 40, height: 40, borderRadius: 11, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="chevL" size={24} color="#fff" strokeWidth={2.2} /></button>
          <div style={{ flex: 1, fontSize: 17, fontWeight: 800 }}>Nova vaga</div>
        </div>
      }>
        <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 13 }}>
          <Field label="Cargo / título" icon="briefcase" value={form.role} onChange={v => setForm({ ...form, role: v })} placeholder="Ex: Estágio em Dev Web" />
          <Field label="Empresa / órgão" icon="institution" value={form.org} onChange={v => setForm({ ...form, org: v })} placeholder="Nome da organização" />
          <Field label="Área de atuação" icon="doc" value={form.area} onChange={v => setForm({ ...form, area: v })} placeholder="Ex: Tecnologia da Informação" />
          <div>
            <label style={{ display: 'block', fontSize: 12.5, fontWeight: 600, color: 'var(--ink-2)', margin: '0 0 7px 3px' }}>Curso-alvo</label>
            <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
              {DATA.estagioCourses.filter(c => c !== 'Todos').map(c => (
                <button key={c} onClick={() => setForm({ ...form, course: c })} className="u-press" style={{ fontSize: 12, fontWeight: 600, padding: '7px 13px', borderRadius: 999, background: form.course === c ? 'var(--green-800)' : '#fff', color: form.course === c ? '#fff' : 'var(--ink-2)', boxShadow: form.course === c ? 'none' : 'inset 0 0 0 1px var(--line)' }}>{c}</button>
              ))}
            </div>
          </div>
          <div>
            <label style={{ display: 'block', fontSize: 12.5, fontWeight: 600, color: 'var(--ink-2)', margin: '0 0 7px 3px' }}>Modalidade</label>
            <div style={{ display: 'flex', gap: 8 }}>
              {['Presencial', 'Híbrido', 'Remoto'].map(m => (
                <button key={m} onClick={() => setForm({ ...form, mode: m })} className="u-press" style={{ flex: 1, fontSize: 12.5, fontWeight: 600, padding: '9px 0', borderRadius: 10, background: form.mode === m ? 'var(--green-800)' : '#fff', color: form.mode === m ? '#fff' : 'var(--ink-2)', boxShadow: form.mode === m ? 'none' : 'inset 0 0 0 1px var(--line)' }}>{m}</button>
              ))}
            </div>
          </div>
          <Field label="Bolsa-auxílio" icon="card" value={form.grant} onChange={v => setForm({ ...form, grant: v })} placeholder="Ex: R$ 1.100" />
          <Field label="Data de expiração" icon="clock" value={form.expires} onChange={v => setForm({ ...form, expires: v })} placeholder="DD/MM/AAAA" />
          <Card pad={14} style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--ink)' }}>Vaga ativa</div>
              <div style={{ fontSize: 11.5, color: 'var(--ink-3)' }}>{form.active ? 'Visível para os alunos' : 'Marcada como encerrada'}</div>
            </div>
            <Toggle on={form.active} onChange={v => setForm({ ...form, active: v })} />
          </Card>
          <Button size="lg" full icon="check" disabled={!valid} onClick={save} style={{ marginTop: 6 }}>Publicar vaga</Button>
        </div>
      </PageShell>
    );
  }

  return (
    <PageShell nav={nav} bodyPad={0} bg="#0E1A2B" header={
      <div style={{ paddingTop: STATUS_H, padding: `${STATUS_H}px 16px 16px`, background: 'linear-gradient(160deg, #1B2A3F, #0E1A2B)', color: '#fff', borderRadius: '0 0 24px 24px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 12 }}>
          <button onClick={() => nav.tab('home')} className="u-press" style={{ width: 38, height: 38, marginLeft: -8, borderRadius: 11, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="logout" size={20} color="#fff" strokeWidth={2} /></button>
          <div style={{ flex: 1 }} />
          <Icon name="shield" size={24} color="#4F9CE8" strokeWidth={1.9} />
        </div>
        <h1 style={{ margin: 0, fontSize: 22, fontWeight: 800 }}>Gerenciar vagas</h1>
        <p style={{ margin: '4px 0 0', fontSize: 12.5, color: 'rgba(255,255,255,0.6)' }}>Setor de Estágios · {vagas.filter(v => v.active).length} ativas de {vagas.length}</p>
      </div>
    }>
      <div style={{ padding: 16 }}>
        <Button full size="md" icon="plus" style={{ marginBottom: 16 }} onClick={() => setForm({ ...blank })}>Cadastrar nova vaga</Button>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {vagas.map((v, i) => (
            <Card key={v.id} pad={14} style={{ display: 'flex', alignItems: 'center', gap: 12, animation: `u-fade-up .35s ${i * 0.03}s both` }}>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 13.5, fontWeight: 700, color: 'var(--ink)', lineHeight: 1.3 }}>{v.role}</div>
                <div style={{ fontSize: 11.5, color: 'var(--ink-3)', marginTop: 2 }}>{v.org}</div>
                <div style={{ marginTop: 7 }}><StatusBadge status={v.active ? 'open' : 'closed'} openLabel="Ativa" /></div>
              </div>
              <Toggle on={v.active} onChange={() => toggle(v.id)} />
            </Card>
          ))}
        </div>
      </div>
    </PageShell>
  );
}

Object.assign(window, { EstagioScreen, DepoimentosScreen, VagaDetailScreen, ConcursoDetailScreen, RepublicasScreen, AdminLoginScreen, AdminPanelScreen });
