// screens-auth.jsx — onboarding, login, register

const ONB_SLIDES = [
  { icon: 'institution', title: 'Tudo do seu campus,\nem um só lugar', body: 'Encontre informações sobre o IFSP Pirituba, cursos, estrutura e contatos — sem complicação.' },
  { icon: 'benefits', title: 'Benefícios que\nfazem a diferença', body: 'Descubra auxílios governamentais e institucionais: Cadastro Único, PAP, monitoria, transporte e muito mais.' },
  { icon: 'briefcase', title: 'Estágios, concursos\ne sua jornada', body: 'Acompanhe vagas, editais e tire suas dúvidas direto com o campus. Sua vida acadêmica organizada.' },
];

function OnboardingScreen({ nav }) {
  const [i, setI] = React.useState(0);
  const last = i === ONB_SLIDES.length - 1;
  const s = ONB_SLIDES[i];
  return (
    <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(165deg, #00734D, #003D28)', display: 'flex', flexDirection: 'column', color: '#fff' }}>
      <div style={{ display: 'flex', justifyContent: 'flex-end', padding: `${STATUS_H}px 22px 0` }}>
        {!last && <button onClick={() => nav.replace('login')} className="u-press" style={{ fontSize: 13, fontWeight: 700, color: 'rgba(255,255,255,0.75)' }}>Pular</button>}
      </div>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 32px', textAlign: 'center' }}>
        <div key={i} style={{ animation: 'u-scale-in .45s cubic-bezier(.2,.8,.3,1) both' }}>
          <div style={{ width: 120, height: 120, borderRadius: 34, background: 'rgba(255,255,255,0.12)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 36px', backdropFilter: 'blur(6px)', boxShadow: 'inset 0 1px 1px rgba(255,255,255,0.2)' }}>
            <Icon name={s.icon} size={58} color="#fff" strokeWidth={1.6} />
          </div>
          <h1 style={{ margin: 0, fontSize: 27, fontWeight: 800, lineHeight: 1.2, whiteSpace: 'pre-line', letterSpacing: -0.4 }}>{s.title}</h1>
          <p style={{ margin: '16px 0 0', fontSize: 14.5, lineHeight: 1.55, color: 'rgba(255,255,255,0.78)', maxWidth: 300 }}>{s.body}</p>
        </div>
      </div>
      <div style={{ padding: '0 28px 44px' }}>
        <div style={{ display: 'flex', justifyContent: 'center', gap: 8, marginBottom: 28 }}>
          {ONB_SLIDES.map((_, k) => (
            <div key={k} onClick={() => setI(k)} style={{ height: 8, width: k === i ? 26 : 8, borderRadius: 999, background: k === i ? '#26C17D' : 'rgba(255,255,255,0.3)', transition: 'all .3s ease', cursor: 'pointer' }} />
          ))}
        </div>
        <Button variant="white" size="lg" full iconRight="chevR" onClick={() => last ? nav.replace('login') : setI(i + 1)}>
          {last ? 'Começar' : 'Próximo'}
        </Button>
      </div>
    </div>
  );
}

function LoginScreen({ nav, toast }) {
  const [email, setEmail] = React.useState('ana.silva@aluno.ifsp.edu.br');
  const [pw, setPw] = React.useState('Universe@2026');
  const [remember, setRemember] = React.useState(true);
  const [err, setErr] = React.useState({});
  const [loading, setLoading] = React.useState(false);

  const submit = () => {
    const e = {};
    if (!/^\S+@\S+\.\S+$/.test(email)) e.email = 'Informe um e-mail válido';
    if (pw.length < 6) e.pw = 'Senha muito curta';
    setErr(e);
    if (Object.keys(e).length) return;
    setLoading(true);
    setTimeout(() => { nav.login(); toast('Bem-vinda de volta, Ana!', 'checkCircle'); }, 850);
  };

  return (
    <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(168deg, #00734D 0%, #003D28 60%)', display: 'flex', flexDirection: 'column', color: '#fff' }}>
      <div style={{ flex: '0 0 auto', display: 'flex', flexDirection: 'column', alignItems: 'center', paddingTop: STATUS_H + 26, paddingBottom: 26 }}>
        <UniverseAppIcon size={72} />
        <div style={{ marginTop: 18 }}><UniverseWordmark height={26} color="#fff" /></div>
        <p style={{ margin: '10px 0 0', fontSize: 13, color: 'rgba(255,255,255,0.72)' }}>Guia do estudante · IFSP Pirituba</p>
      </div>
      <div style={{ flex: 1, background: 'var(--bg)', borderRadius: '30px 30px 0 0', padding: '28px 24px', display: 'flex', flexDirection: 'column' }}>
        <h2 style={{ margin: '0 0 4px', fontSize: 22, fontWeight: 800, color: 'var(--ink)' }}>Entrar</h2>
        <p style={{ margin: '0 0 22px', fontSize: 13.5, color: 'var(--ink-3)' }}>Acesse com sua conta institucional</p>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          <Field label="E-mail" icon="mail" value={email} onChange={v => { setEmail(v); setErr({ ...err, email: null }); }} placeholder="seu@aluno.ifsp.edu.br" error={err.email} />
          <PasswordField label="Senha" icon="lock" value={pw} onChange={v => { setPw(v); setErr({ ...err, pw: null }); }} placeholder="Sua senha" error={err.pw} />
        </div>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', margin: '16px 0 22px' }}>
          <button onClick={() => setRemember(r => !r)} className="u-press" style={{ display: 'flex', alignItems: 'center', gap: 9 }}>
            <div style={{ width: 22, height: 22, borderRadius: 7, background: remember ? 'var(--green-600)' : '#fff', boxShadow: remember ? 'none' : 'inset 0 0 0 1.5px var(--line)', display: 'flex', alignItems: 'center', justifyContent: 'center', transition: 'all .15s' }}>
              {remember && <Icon name="check" size={14} color="#fff" strokeWidth={3} />}
            </div>
            <span style={{ fontSize: 13, fontWeight: 600, color: 'var(--ink-2)' }}>Lembre-me</span>
          </button>
          <button className="u-press" style={{ fontSize: 13, fontWeight: 700, color: 'var(--green-600)' }}>Esqueci minha senha</button>
        </div>
        <Button size="lg" full onClick={submit} disabled={loading}>{loading ? 'Entrando…' : 'ENTRAR'}</Button>
        <div style={{ flex: 1 }} />
        <div style={{ textAlign: 'center', fontSize: 13.5, color: 'var(--ink-2)', paddingTop: 18 }}>
          Não tem uma conta?{' '}
          <button onClick={() => nav.go('register')} className="u-press" style={{ fontSize: 13.5, fontWeight: 800, color: 'var(--green-700)' }}>Cadastre-se</button>
        </div>
      </div>
    </div>
  );
}

function RegisterScreen({ nav, toast }) {
  const [f, setF] = React.useState({ name: '', email: '', pw: '', pw2: '' });
  const set = (k, v) => setF(s => ({ ...s, [k]: v }));
  const rules = [
    { label: '1 letra maiúscula', ok: /[A-Z]/.test(f.pw) },
    { label: '1 letra minúscula', ok: /[a-z]/.test(f.pw) },
    { label: '1 número', ok: /[0-9]/.test(f.pw) },
    { label: '1 caractere especial', ok: /[^A-Za-z0-9]/.test(f.pw) },
  ];
  const pwOk = rules.every(r => r.ok) && f.pw.length >= 8;
  const emailOk = /^\S+@\S+\.\S+$/.test(f.email);
  const matchOk = f.pw2.length > 0 && f.pw === f.pw2;
  const canSubmit = f.name.trim().length > 2 && emailOk && pwOk && matchOk;

  return (
    <div style={{ position: 'absolute', inset: 0, background: 'var(--green-050)', display: 'flex', flexDirection: 'column' }}>
      <div style={{ paddingTop: STATUS_H, padding: `${STATUS_H}px 12px 8px`, display: 'flex', alignItems: 'center' }}>
        <button onClick={() => nav.back()} className="u-press" style={{ width: 40, height: 40, borderRadius: 11, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Icon name="chevL" size={24} color="var(--ink)" strokeWidth={2.2} />
        </button>
      </div>
      <div className="u-scroll" style={{ flex: 1, padding: '4px 24px 28px' }}>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', marginBottom: 22 }}>
          <UniverseAppIcon size={60} />
          <h2 style={{ margin: '16px 0 4px', fontSize: 22, fontWeight: 800, color: 'var(--ink)' }}>Criar conta</h2>
          <p style={{ margin: 0, fontSize: 13, color: 'var(--ink-3)' }}>Leva menos de um minuto</p>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 13 }}>
          <Field label="Nome completo" icon="user" value={f.name} onChange={v => set('name', v)} placeholder="Seu nome" valid={f.name.trim().length > 2} />
          <Field label="E-mail institucional" icon="mail" value={f.email} onChange={v => set('email', v)} placeholder="seu@aluno.ifsp.edu.br" valid={emailOk} error={f.email.length > 4 && !emailOk ? 'E-mail inválido' : null} />
          <PasswordField label="Senha" icon="lock" value={f.pw} onChange={v => set('pw', v)} placeholder="Crie uma senha forte" valid={pwOk} />
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '6px 10px', margin: '2px 2px 0' }}>
            {rules.map((r, k) => (
              <div key={k} style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 11.5, fontWeight: 600, color: r.ok ? 'var(--green-600)' : 'var(--ink-3)', transition: 'color .2s' }}>
                <Icon name={r.ok ? 'checkCircle' : 'plus'} size={14} color={r.ok ? 'var(--green-500)' : 'var(--ink-3)'} strokeWidth={2.2} />
                {r.label}
              </div>
            ))}
          </div>
          <PasswordField label="Repetir senha" icon="lock" value={f.pw2} onChange={v => set('pw2', v)} placeholder="Repita a senha" valid={matchOk} error={f.pw2.length > 0 && !matchOk ? 'As senhas não coincidem' : null} />
        </div>
        <div style={{ marginTop: 24 }}>
          <Button size="lg" full onClick={() => { nav.login(); toast('Conta criada com sucesso!', 'checkCircle'); }} disabled={!canSubmit}>CRIAR CONTA</Button>
        </div>
        <p style={{ fontSize: 11, color: 'var(--ink-3)', textAlign: 'center', margin: '14px 0 0', lineHeight: 1.5 }}>Ao criar a conta você concorda com os Termos de Uso e a Política de Privacidade do IFSP.</p>
      </div>
    </div>
  );
}

Object.assign(window, { OnboardingScreen, LoginScreen, RegisterScreen });
