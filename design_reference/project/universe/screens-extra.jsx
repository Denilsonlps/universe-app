// screens-extra.jsx — Splash, Busca global, IFSP detalhe, Carteirinha, Erro de conexão

function SplashScreen({ nav }) {
  React.useEffect(() => {
    const tm = setTimeout(() => nav.replace('onboarding'), 2000);
    return () => clearTimeout(tm);
  }, []);
  return (
    <div onClick={() => nav.replace('onboarding')} style={{ position: 'absolute', inset: 0, background: 'linear-gradient(170deg, #00573A 0%, #002A1B 100%)', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', color: '#fff' }}>
      <div style={{ animation: 'u-pop .7s cubic-bezier(.2,.8,.3,1) both' }}>
        <UniverseAppIcon size={104} />
      </div>
      <div style={{ marginTop: 24, animation: 'u-fade-up .6s .35s both' }}>
        <UniverseWordmark height={30} color="#fff" />
      </div>
      <div style={{ marginTop: 10, fontSize: 12.5, color: 'rgba(255,255,255,0.6)', letterSpacing: 1, animation: 'u-fade .6s .6s both' }}>IFSP PIRITUBA</div>
      <div style={{ position: 'absolute', bottom: 56, display: 'flex', gap: 6 }}>
        {[0, 1, 2].map(i => (
          <div key={i} style={{ width: 7, height: 7, borderRadius: '50%', background: 'rgba(255,255,255,0.5)', animation: `u-pop .6s ${0.8 + i * 0.15}s infinite alternate` }} />
        ))}
      </div>
    </div>
  );
}

// Global search — searches courses, benefits, vagas, concursos, faqs
function buildSearchIndex() {
  const idx = [];
  DATA.courses.forEach(c => idx.push({ type: 'Curso', icon: c.icon, title: c.name, sub: c.cat + ' · ' + c.period, screen: 'courseDetail', params: c }));
  DATA.benGov.forEach(b => idx.push({ type: 'Benefício', icon: b.icon, title: b.title, sub: 'Governamental · ' + b.tag, screen: 'benefitDetail', params: { ...b, kind: 'gov' } }));
  DATA.benInst.forEach(b => idx.push({ type: 'Benefício', icon: b.icon, title: b.title, sub: 'Institucional · ' + b.tag, screen: 'benefitDetail', params: { ...b, kind: 'inst' } }));
  DATA.estagios.forEach(e => idx.push({ type: 'Vaga', icon: 'briefcase', title: e.role, sub: e.org + ' · ' + e.grant, screen: 'vagaDetail', params: e }));
  DATA.concursos.forEach(c => idx.push({ type: 'Concurso', icon: 'doc', title: c.role, sub: c.org + ' · ' + c.vagas, screen: 'concursoDetail', params: c }));
  DATA.faqs.forEach(f => idx.push({ type: 'Dúvida', icon: 'question', title: f.q, sub: f.cat, screen: 'duvidas' }));
  return idx;
}

function SearchScreen({ nav, params }) {
  const [q, setQ] = React.useState((params && params.q) || '');
  const index = React.useMemo(buildSearchIndex, []);
  const term = q.trim().toLowerCase();
  const results = term.length < 2 ? [] : index.filter(it => (it.title + ' ' + it.sub + ' ' + it.type).toLowerCase().includes(term));
  const grouped = {};
  results.forEach(r => { (grouped[r.type] = grouped[r.type] || []).push(r); });
  const suggestions = ['ADS', 'ID Jovem', 'PAP', 'Estágio', 'Concurso', 'Moradia'];

  return (
    <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', background: 'var(--bg)' }}>
      <div style={{ paddingTop: STATUS_H, padding: `${STATUS_H}px 12px 12px`, background: 'var(--bg)', display: 'flex', alignItems: 'center', gap: 8, boxShadow: '0 1px 0 var(--line)' }}>
        <button onClick={() => nav.back()} className="u-press" style={{ width: 40, height: 40, borderRadius: 11, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
          <Icon name="chevL" size={24} color="var(--ink)" strokeWidth={2.2} />
        </button>
        <div style={{ flex: 1 }}>
          <Field icon="search" value={q} onChange={setQ} placeholder="Buscar no app…" />
        </div>
      </div>
      <div className="u-scroll" style={{ flex: 1, padding: 16 }}>
        {term.length < 2 ? (
          <div>
            <div style={{ fontSize: 12.5, fontWeight: 700, color: 'var(--ink-3)', margin: '4px 0 12px' }}>Sugestões</div>
            <div style={{ display: 'flex', gap: 9, flexWrap: 'wrap' }}>
              {suggestions.map(s => <Chip key={s} onClick={() => setQ(s)}>{s}</Chip>)}
            </div>
          </div>
        ) : results.length === 0 ? (
          <EmptyState icon="search" title="Nenhum resultado" body={`Não encontramos nada para “${q}”. Tente outro termo.`} />
        ) : (
          <div>
            <div style={{ fontSize: 12.5, color: 'var(--ink-3)', margin: '0 0 14px', fontWeight: 600 }}>{results.length} resultado(s) para “{q}”</div>
            {Object.entries(grouped).map(([type, items]) => (
              <div key={type} style={{ marginBottom: 18 }}>
                <div style={{ fontSize: 11.5, fontWeight: 800, letterSpacing: 0.5, textTransform: 'uppercase', color: 'var(--green-700)', margin: '0 0 9px 2px' }}>{type}</div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 9 }}>
                  {items.map((it, i) => (
                    <ListRow key={i} icon={it.icon} title={it.title} subtitle={it.sub} onClick={() => it.params ? nav.go(it.screen, it.params) : nav.tab ? nav.go(it.screen) : nav.go(it.screen)} />
                  ))}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

function IfspDetailScreen({ nav, params, toast }) {
  const d = DATA.ifspDetails[params.key];
  if (!d) return null;
  return (
    <PageShell nav={nav} bodyPad={0} header={<GreenHero nav={nav} title={d.title} subtitle="IFSP Pirituba" icon={d.icon} />}>
      <div style={{ padding: 16 }}>
        {d.kind === 'text' && (
          <Card pad={18}><p style={{ margin: 0, fontSize: 13.5, lineHeight: 1.65, color: 'var(--ink-2)', whiteSpace: 'pre-line' }}>{d.body}</p></Card>
        )}

        {d.kind === 'map' && (
          <div>
            <div style={{ borderRadius: 'var(--radius)', overflow: 'hidden', boxShadow: 'var(--shadow-sm)', height: 170, background: 'repeating-linear-gradient(135deg, #E5EDE7 0 12px, #DCE7DE 12px 24px)', position: 'relative', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 14 }}>
              <div style={{ position: 'absolute', width: 3, top: 0, bottom: 0, left: '40%', background: 'rgba(0,87,58,0.18)' }} />
              <div style={{ position: 'absolute', height: 3, left: 0, right: 0, top: '55%', background: 'rgba(0,87,58,0.18)' }} />
              <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4, zIndex: 1 }}>
                <div style={{ width: 44, height: 44, borderRadius: '50%', background: 'var(--green-700)', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 6px 14px rgba(0,87,58,0.35)' }}>
                  <Icon name="pin" size={24} color="#fff" strokeWidth={2} />
                </div>
                <span style={{ fontFamily: 'monospace', fontSize: 10.5, color: 'var(--ink-3)' }}>mapa do campus</span>
              </div>
            </div>
            <Card pad={16} style={{ marginBottom: 12 }}>
              <div style={{ fontSize: 12, color: 'var(--ink-3)', fontWeight: 600, marginBottom: 4 }}>Endereço</div>
              <div style={{ fontSize: 14.5, fontWeight: 600, color: 'var(--ink)', lineHeight: 1.45, whiteSpace: 'pre-line' }}>{d.address}</div>
            </Card>
            <div style={{ display: 'flex', gap: 10 }}>
              <Button variant="outline" size="md" full icon="doc" onClick={() => nav.copy(d.copy)}>Copiar</Button>
              <Button size="md" full icon="pin" onClick={() => toast('Abrindo no mapa…', 'pin')}>Como chegar</Button>
            </div>
          </div>
        )}

        {d.kind === 'hours' && (
          <div>
            <Card pad={0} style={{ overflow: 'hidden', marginBottom: 14 }}>
              {d.hours.map(([day, time], i) => (
                <div key={i} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '15px 16px', borderBottom: i < d.hours.length - 1 ? '1px solid var(--line)' : 'none' }}>
                  <span style={{ fontSize: 14, fontWeight: 600, color: 'var(--ink)' }}>{day}</span>
                  <span style={{ fontSize: 13.5, fontWeight: 700, color: time === 'Fechado' ? 'var(--ink-3)' : 'var(--green-700)' }}>{time}</span>
                </div>
              ))}
            </Card>
            <div style={{ fontSize: 12.5, color: 'var(--ink-3)', lineHeight: 1.5, padding: '0 4px' }}>{d.note}</div>
          </div>
        )}

        {d.kind === 'list' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {d.items.map(([t, ic], i) => (
              <Card key={i} pad={14} style={{ display: 'flex', alignItems: 'center', gap: 13 }}>
                <IconTile name={ic} size={44} icon={22} />
                <span style={{ fontSize: 14.5, fontWeight: 600, color: 'var(--ink)' }}>{t}</span>
              </Card>
            ))}
          </div>
        )}

        {d.kind === 'contacts' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 11 }}>
            {d.contacts.map((c, i) => (
              <Card key={i} pad={14} onClick={() => nav.copy(c.copy)} style={{ display: 'flex', alignItems: 'center', gap: 13 }}>
                <IconTile name={c.icon} size={46} icon={23} />
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 11.5, color: 'var(--ink-3)', fontWeight: 600 }}>{c.label}</div>
                  <div style={{ fontSize: 14.5, fontWeight: 700, color: 'var(--ink)', marginTop: 1 }}>{c.value}</div>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 4, color: 'var(--green-700)', fontSize: 12, fontWeight: 700 }}>
                  <Icon name="doc" size={16} color="var(--green-700)" strokeWidth={2} /> Copiar
                </div>
              </Card>
            ))}
          </div>
        )}

        {d.kind === 'site' && (
          <div>
            <Card pad={18} onClick={() => toast('Abrindo ' + d.url + '…', 'globe')} style={{ marginBottom: 14, display: 'flex', alignItems: 'center', gap: 14, background: 'linear-gradient(150deg, var(--green-050), #fff)' }}>
              <IconTile name="globe" size={50} icon={26} bg="var(--green-100)" />
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 15, fontWeight: 800, color: 'var(--ink)' }}>Abrir site oficial</div>
                <div style={{ fontSize: 12.5, color: 'var(--green-700)', fontWeight: 600 }}>{d.url}</div>
              </div>
              <Icon name="chevR" size={18} color="var(--ink-3)" strokeWidth={2} />
            </Card>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
              {d.links.map(([t, u], i) => (
                <ListRow key={i} icon="globe" title={t} subtitle={u} onClick={() => toast('Abrindo ' + u + '…', 'globe')} />
              ))}
            </div>
          </div>
        )}
      </div>
    </PageShell>
  );
}

function CarteirinhaScreen({ nav, user }) {
  return (
    <PageShell nav={nav} bodyPad={0} header={<PageHeader nav={nav} title="Carteirinha digital" />}>
      <div style={{ padding: 20 }}>
        <div style={{ borderRadius: 22, overflow: 'hidden', boxShadow: 'var(--shadow-lg)', background: 'linear-gradient(160deg, var(--hero-from), var(--hero-to))', color: '#fff', position: 'relative', animation: 'u-scale-in .5s cubic-bezier(.2,.8,.3,1) both' }}>
          <div style={{ position: 'absolute', right: -40, top: -40, width: 160, height: 160, borderRadius: '50%', background: 'rgba(38,193,125,0.18)' }} />
          <div style={{ padding: '20px 20px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between', position: 'relative' }}>
            <UniverseWordmark height={20} color="#fff" />
            <UniverseBadge size={30} color="rgba(255,255,255,0.95)" ring="rgba(255,255,255,0.55)" />
          </div>
          <div style={{ padding: '18px 20px', display: 'flex', gap: 16, alignItems: 'center', position: 'relative' }}>
            <Avatar name={user.name} size={72} style={{ boxShadow: '0 0 0 3px rgba(255,255,255,0.25)' }} />
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 11, color: 'rgba(255,255,255,0.65)', fontWeight: 600 }}>ALUNO(A)</div>
              <div style={{ fontSize: 18, fontWeight: 800, lineHeight: 1.2 }}>{user.name}</div>
              <div style={{ fontSize: 12, color: 'rgba(255,255,255,0.8)', marginTop: 4, lineHeight: 1.3 }}>{user.course}</div>
            </div>
          </div>
          <div style={{ padding: '0 20px 18px', display: 'flex', gap: 18, position: 'relative' }}>
            <div><div style={{ fontSize: 10, color: 'rgba(255,255,255,0.6)', fontWeight: 600 }}>MATRÍCULA</div><div style={{ fontSize: 14, fontWeight: 700 }}>{user.enroll}</div></div>
            <div><div style={{ fontSize: 10, color: 'rgba(255,255,255,0.6)', fontWeight: 600 }}>VALIDADE</div><div style={{ fontSize: 14, fontWeight: 700 }}>12/2026</div></div>
            <div><div style={{ fontSize: 10, color: 'rgba(255,255,255,0.6)', fontWeight: 600 }}>CAMPUS</div><div style={{ fontSize: 14, fontWeight: 700 }}>Pirituba</div></div>
          </div>
          <div style={{ background: '#fff', padding: '18px 20px', display: 'flex', alignItems: 'center', gap: 16 }}>
            <FakeQR size={96} seed={user.enroll} fg="#003D28" />
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 13, fontWeight: 800, color: 'var(--ink)' }}>Apresente na portaria</div>
              <div style={{ fontSize: 11.5, color: 'var(--ink-3)', marginTop: 4, lineHeight: 1.45 }}>Aproxime o QR code do leitor para validar o acesso e usar benefícios estudantis.</div>
            </div>
          </div>
        </div>
        <div style={{ display: 'flex', gap: 10, marginTop: 18 }}>
          <Button variant="outline" size="md" full icon="doc" onClick={() => nav.toast('Carteirinha salva')}>Salvar</Button>
          <Button size="md" full icon="send" onClick={() => nav.toast('Compartilhando…')}>Compartilhar</Button>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7, marginTop: 18, fontSize: 11.5, color: 'var(--ink-3)' }}>
          <Icon name="shield" size={15} color="var(--green-500)" strokeWidth={2} /> Documento digital verificado · IFSP
        </div>
      </div>
    </PageShell>
  );
}

function ConnectionErrorScreen({ onRetry, retrying }) {
  return (
    <div style={{ position: 'absolute', inset: 0, background: 'var(--bg)', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 36px', textAlign: 'center' }}>
      <div style={{ width: 96, height: 96, borderRadius: 30, background: 'var(--bg-2)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 24, position: 'relative' }}>
        <Icon name="globe" size={46} color="var(--ink-3)" strokeWidth={1.6} />
        <div style={{ position: 'absolute', width: 4, height: 76, background: '#E23B2E', borderRadius: 4, transform: 'rotate(45deg)', boxShadow: '0 0 0 3px var(--bg-2)' }} />
      </div>
      <h1 style={{ margin: 0, fontSize: 21, fontWeight: 800, color: 'var(--ink)' }}>Sem conexão</h1>
      <p style={{ margin: '10px 0 28px', fontSize: 13.5, color: 'var(--ink-2)', lineHeight: 1.55, maxWidth: 280 }}>Não foi possível conectar ao servidor. Verifique sua internet e tente novamente.</p>
      <Button size="lg" icon={retrying ? undefined : 'settings'} onClick={onRetry} disabled={retrying} style={{ minWidth: 200 }}>{retrying ? 'Reconectando…' : 'Tentar novamente'}</Button>
      <div style={{ fontSize: 11.5, color: 'var(--ink-3)', marginTop: 18 }}>UNIVERSE · IFSP Pirituba</div>
    </div>
  );
}

Object.assign(window, { SplashScreen, SearchScreen, IfspDetailScreen, CarteirinhaScreen, ConnectionErrorScreen });
