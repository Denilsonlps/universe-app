// screens-misc.jsx — Dúvidas, Perfil, Cadastrar informações, Notificações

function DuvidasScreen({ nav, toast }) {
  const [cat, setCat] = React.useState('Todas');
  const [openIdx, setOpenIdx] = React.useState(0);
  const [q, setQ] = React.useState('');
  const [msg, setMsg] = React.useState('');
  const [formCat, setFormCat] = React.useState('Dúvidas gerais');
  const list = DATA.faqs.filter(f => (cat === 'Todas' || f.cat === cat) && (f.q.toLowerCase().includes(q.toLowerCase())));
  return (
    <PageShell tab="duvidas" nav={nav} header={
      <div style={{ paddingTop: STATUS_H, padding: `${STATUS_H}px 16px 12px`, background: 'var(--bg)' }}>
        <h1 style={{ margin: '0 0 12px', fontSize: 26, fontWeight: 800, color: 'var(--ink)', letterSpacing: -0.4 }}>Dúvidas</h1>
        <Field icon="search" value={q} onChange={setQ} placeholder="Pesquisar dúvidas…" />
      </div>
    } animKey={'duv-' + cat}>
      <div className="u-scroll" style={{ display: 'flex', gap: 9, overflowX: 'auto', margin: '0 -16px 16px', padding: '0 16px' }}>
        {DATA.faqCats.map(c => <Chip key={c} active={cat === c} onClick={() => setCat(c)}>{c}</Chip>)}
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginBottom: 26 }}>
        {list.map((f, i) => (
          <div key={f.q} style={{ animation: `u-fade-up .35s ${i * 0.03}s both` }}>
            <Accordion q={f.q} a={f.a} open={openIdx === i} onToggle={() => setOpenIdx(openIdx === i ? -1 : i)} />
          </div>
        ))}
        {list.length === 0 && <EmptyState icon="question" title="Nenhuma dúvida encontrada" body="Não achamos resultados. Encaminhe sua pergunta abaixo." />}
      </div>

      {/* Encaminhe sua dúvida */}
      <Card pad={18} style={{ background: 'linear-gradient(160deg, var(--green-050), #fff)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 14 }}>
          <IconTile name="send" size={42} icon={20} bg="var(--green-100)" />
          <div>
            <div style={{ fontSize: 15, fontWeight: 800, color: 'var(--ink)' }}>Não achou sua dúvida?</div>
            <div style={{ fontSize: 12, color: 'var(--ink-2)' }}>Encaminhe direto para o campus</div>
          </div>
        </div>
        <div style={{ marginBottom: 12 }}>
          <label style={{ display: 'block', fontSize: 12.5, fontWeight: 600, color: 'var(--ink-2)', margin: '0 0 7px 3px' }}>Categoria</label>
          <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
            {['Dúvidas gerais', 'Campus', 'Enem'].map(c => (
              <button key={c} onClick={() => setFormCat(c)} className="u-press" style={{ fontSize: 12, fontWeight: 600, padding: '7px 13px', borderRadius: 999, background: formCat === c ? 'var(--green-800)' : 'var(--chip-bg)', color: formCat === c ? '#fff' : 'var(--ink-2)', boxShadow: formCat === c ? 'none' : 'inset 0 0 0 1px var(--line)' }}>{c}</button>
            ))}
          </div>
        </div>
        <Field multiline value={msg} onChange={setMsg} placeholder="Digite sua mensagem…" maxLength={500} />
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: 12 }}>
          <span style={{ fontSize: 11.5, color: 'var(--ink-3)' }}>{msg.length}/500 caracteres</span>
          <Button size="sm" icon="send" disabled={msg.trim().length < 5} onClick={() => { setMsg(''); toast('Dúvida enviada ao campus!', 'send'); }}>Enviar</Button>
        </div>
      </Card>
    </PageShell>
  );
}

function PerfilScreen({ nav, user, toast, dark }) {
  const [notif, setNotif] = React.useState(true);
  const rows1 = [
    { icon: 'edit', label: 'Editar perfil', action: () => nav.go('cadastrar') },
    { icon: 'card', label: 'Carteirinha digital', action: () => nav.go('carteirinha') },
    { icon: 'lock', label: 'Alterar senha', action: () => toast('Em breve') },
  ];
  const rows2 = [
    { icon: 'question', label: 'Central de dúvidas', action: () => nav.tab('duvidas') },
    { icon: 'institution', label: 'Sobre o IFSP Pirituba', action: () => nav.go('ifsp') },
    { icon: 'doc', label: 'Termos e privacidade', action: () => toast('Em breve') },
  ];
  const Group = ({ rows }) => (
    <Card pad={0} style={{ overflow: 'hidden', marginBottom: 14 }}>
      {rows.map((r, i) => (
        <button key={i} onClick={r.action} className="u-press" style={{ width: '100%', display: 'flex', alignItems: 'center', gap: 14, padding: '15px 16px', textAlign: 'left', borderBottom: i < rows.length - 1 ? '1px solid var(--line)' : 'none' }}>
          <Icon name={r.icon} size={21} color="var(--green-700)" strokeWidth={1.9} />
          <span style={{ flex: 1, fontSize: 14.5, fontWeight: 600, color: 'var(--ink)' }}>{r.label}</span>
          <Icon name="chevR" size={17} color="var(--ink-3)" strokeWidth={2} />
        </button>
      ))}
    </Card>
  );
  return (
    <PageShell tab="perfil" nav={nav} bodyPad={0} header={
      <div style={{ background: 'linear-gradient(160deg, var(--hero-from), var(--hero-to))', borderRadius: '0 0 28px 28px', padding: `${STATUS_H}px 20px 24px`, color: '#fff', boxShadow: '0 10px 24px rgba(0,61,40,0.22)' }}>
        <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: 6 }}>
          <button onClick={() => nav.toggleDark()} className="u-press" style={{ width: 36, height: 36, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name={dark ? 'sun' : 'moon'} size={22} color="#fff" strokeWidth={1.9} />
          </button>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
          <Avatar name={user.name} size={84} style={{ boxShadow: '0 0 0 4px rgba(255,255,255,0.18)' }} />
          <div style={{ fontSize: 20, fontWeight: 800, marginTop: 12 }}>{user.name}</div>
          <div style={{ fontSize: 12.5, color: 'rgba(255,255,255,0.78)', marginTop: 2 }}>{user.email}</div>
        </div>
        <div style={{ display: 'flex', gap: 10, marginTop: 18 }}>
          {[['Curso', user.course.split(' ')[0]], ['Matrícula', user.enroll], ['Semestre', '4º']].map(([k, v], i) => (
            <div key={i} style={{ flex: 1, background: 'rgba(255,255,255,0.12)', borderRadius: 13, padding: '11px 6px', textAlign: 'center' }}>
              <div style={{ fontSize: 13, fontWeight: 800, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{v}</div>
              <div style={{ fontSize: 10, color: 'rgba(255,255,255,0.72)', marginTop: 3 }}>{k}</div>
            </div>
          ))}
        </div>
      </div>
    }>
      <div style={{ padding: 16 }}>
        <Card pad={0} style={{ marginBottom: 14 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 14, padding: '15px 16px', borderBottom: '1px solid var(--line)' }}>
            <Icon name="bell" size={21} color="var(--green-700)" strokeWidth={1.9} />
            <span style={{ flex: 1, fontSize: 14.5, fontWeight: 600, color: 'var(--ink)' }}>Notificações</span>
            <Toggle on={notif} onChange={setNotif} />
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 14, padding: '15px 16px' }}>
            <Icon name={dark ? 'moon' : 'sun'} size={21} color="var(--green-700)" strokeWidth={1.9} />
            <span style={{ flex: 1, fontSize: 14.5, fontWeight: 600, color: 'var(--ink)' }}>Modo escuro</span>
            <Toggle on={dark} onChange={v => nav.setDark(v)} />
          </div>
        </Card>
        <Group rows={rows1} />
        <Group rows={rows2} />
        <button onClick={() => nav.logout()} className="u-press" style={{ width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9, padding: 15, borderRadius: 14, background: 'var(--card)', color: '#E23B2E', fontSize: 14.5, fontWeight: 700, boxShadow: 'var(--shadow-sm)' }}>
          <Icon name="logout" size={20} color="#E23B2E" strokeWidth={2} /> Sair da conta
        </button>
        <div style={{ textAlign: 'center', fontSize: 11, color: 'var(--ink-3)', marginTop: 18 }}>UNIVERSE · v1.0 · IFSP Pirituba</div>
      </div>
    </PageShell>
  );
}

function CadastrarScreen({ nav, user, toast }) {
  const [f, setF] = React.useState({ name: user.name, phone: '', course: user.course, enroll: user.enroll, city: 'São Paulo' });
  const set = (k, v) => setF(s => ({ ...s, [k]: v }));
  return (
    <PageShell nav={nav} bodyPad={0} header={<PageHeader nav={nav} title="Cadastrar informações" />}>
      <div style={{ padding: 16 }}>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', marginBottom: 22 }}>
          <div style={{ position: 'relative' }}>
            <Avatar name={user.name} size={88} />
            <button onClick={() => toast('Selecionar foto…')} className="u-press" style={{ position: 'absolute', bottom: -2, right: -2, width: 32, height: 32, borderRadius: '50%', background: 'var(--green-700)', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 2px 6px rgba(0,0,0,0.2)', border: '2px solid var(--bg)' }}>
              <Icon name="edit" size={15} color="#fff" strokeWidth={2} />
            </button>
          </div>
          <div style={{ fontSize: 12.5, color: 'var(--ink-3)', marginTop: 10 }}>Toque para alterar a foto</div>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          <Field label="Nome completo" icon="user" value={f.name} onChange={v => set('name', v)} />
          <Field label="Telefone" icon="phone" value={f.phone} onChange={v => set('phone', v)} placeholder="(11) 90000-0000" />
          <Field label="Curso" icon="cap" value={f.course} onChange={v => set('course', v)} />
          <Field label="Nº de matrícula" icon="card" value={f.enroll} onChange={v => set('enroll', v)} />
          <Field label="Cidade" icon="pin" value={f.city} onChange={v => set('city', v)} />
        </div>
        <div style={{ marginTop: 24, display: 'flex', flexDirection: 'column', gap: 10 }}>
          <Button size="lg" full icon="check" onClick={() => { toast('Informações salvas!', 'checkCircle'); setTimeout(() => nav.back(), 700); }}>Salvar alterações</Button>
          <Button variant="ghost" size="md" full onClick={() => nav.back()}>Cancelar</Button>
        </div>
      </div>
    </PageShell>
  );
}

function NotificationsScreen({ nav, toast }) {
  const [list, setList] = React.useState(() => DATA.notifications.map(n => ({ ...n })));
  const unreadCount = list.filter(n => n.unread).length;

  const open = (idx) => {
    const n = list[idx];
    setList(l => l.map((x, i) => i === idx ? { ...x, unread: false } : x));
    if (n.go) { n.tab ? nav.tab(n.go) : nav.go(n.go); }
  };
  const clearAll = () => {
    if (!unreadCount) { toast('Nenhuma notificação nova'); return; }
    setList(l => l.map(n => ({ ...n, unread: false })));
    toast('Tudo marcado como lido', 'check');
  };

  return (
    <PageShell nav={nav} bodyPad={0} header={<PageHeader nav={nav} title="Notificações" action={unreadCount ? 'Limpar' : undefined} onAction={clearAll} />}>
      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 11 }}>
        {list.map((n, i) => (
          <Card key={i} pad={15} onClick={() => open(i)} style={{ display: 'flex', gap: 13, background: n.unread ? 'var(--green-050)' : 'var(--card)', animation: `u-fade-up .4s ${i * 0.05}s both` }}>
            <IconTile name={n.icon} size={44} icon={22} bg="var(--card)" color={n.color} />
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', gap: 8 }}>
                <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--ink)' }}>{n.title}</div>
                <span style={{ fontSize: 11, color: 'var(--ink-3)', flexShrink: 0 }}>{n.time}</span>
              </div>
              <div style={{ fontSize: 12.5, color: 'var(--ink-2)', marginTop: 3, lineHeight: 1.45 }}>{n.body}</div>
            </div>
            {n.unread && <div style={{ width: 8, height: 8, borderRadius: '50%', background: 'var(--green-500)', flexShrink: 0, marginTop: 4 }} />}
          </Card>
        ))}
        {list.length === 0 && <EmptyState icon="bell" title="Sem notificações" body="Você está em dia! Novidades aparecerão aqui." />}
      </div>
    </PageShell>
  );
}

Object.assign(window, { DuvidasScreen, PerfilScreen, CadastrarScreen, NotificationsScreen });
