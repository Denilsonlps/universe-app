// app.jsx — UNIVERSE router, state, transitions, tweaks

const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "homeLayout": "list",
  "benefitLayout": "cards",
  "accent": "#1FA971",
  "startScreen": "splash"
}/*EDITMODE-END*/;

const ACCENTS = {
  '#1FA971': { name: 'Verde IFSP', a400: '#26C17D', a500: '#1FA971' },
  '#0E8F6E': { name: 'Esmeralda', a400: '#1FB892', a500: '#0E8F6E' },
  '#2D7DD2': { name: 'Azul', a400: '#4F9CE8', a500: '#2D7DD2' },
  '#C9700E': { name: 'Âmbar', a400: '#E69327', a500: '#C9700E' },
};

function App() {
  const [t, setTweak] = useTweaks(TWEAK_DEFAULTS);
  const [authed, setAuthed] = React.useState(false);
  const [stack, setStack] = React.useState([{ screen: t.startScreen || 'onboarding' }]);
  const [tab, setTabState] = React.useState('home');
  const [menu, setMenu] = React.useState(false);
  const [toast, setToastState] = React.useState(null);
  const [dir, setDir] = React.useState(1);
  const [offline, setOffline] = React.useState(false);
  const [retrying, setRetrying] = React.useState(false);
  const [dark, setDark] = React.useState(() => {
    try { return localStorage.getItem('universe_theme') === 'dark'; } catch (e) { return false; }
  });
  const toastTimer = React.useRef(null);

  // apply theme
  React.useEffect(() => {
    document.documentElement.setAttribute('data-theme', dark ? 'dark' : 'light');
    try { localStorage.setItem('universe_theme', dark ? 'dark' : 'light'); } catch (e) {}
  }, [dark]);

  // apply accent to CSS vars
  React.useEffect(() => {
    const ac = ACCENTS[t.accent] || ACCENTS['#1FA971'];
    const r = document.documentElement.style;
    r.setProperty('--green-500', ac.a500);
    r.setProperty('--green-400', ac.a400);
  }, [t.accent]);

  const showToast = (msg, icon) => {
    setToastState({ msg, icon });
    clearTimeout(toastTimer.current);
    toastTimer.current = setTimeout(() => setToastState(null), 2200);
  };

  const copyText = (text) => {
    try { navigator.clipboard && navigator.clipboard.writeText(text); } catch (e) {}
    showToast('Copiado: ' + text, 'check');
  };

  const cur = stack[stack.length - 1];

  const nav = React.useMemo(() => ({
    go(screen, params) { setDir(1); setStack(s => [...s, { screen, params }]); },
    replace(screen, params) { setDir(1); setStack([{ screen, params }]); },
    back() { setDir(-1); setStack(s => s.length > 1 ? s.slice(0, -1) : s); },
    tab(key) {
      setDir(1); setTabState(key); setMenu(false);
      const map = { home: 'home', cursos: 'cursos', duvidas: 'duvidas', perfil: 'perfil' };
      setStack([{ screen: map[key] || 'home' }]);
    },
    login() { setAuthed(true); setTabState('home'); setStack([{ screen: 'home' }]); },
    logout() { setAuthed(false); setMenu(false); setStack([{ screen: 'login' }]); },
    openMenu() { setMenu(true); },
    closeMenu() { setMenu(false); },
    toast: showToast,
    copy: copyText,
    goOffline() { setOffline(true); },
    toggleDark() { setDark(d => !d); },
    setDark,
  }), []);

  const user = DATA.user;
  const props = { nav, t, user, toast: showToast, params: cur.params, dark };

  const SCREENS = {
    splash: () => <SplashScreen {...props} />,
    onboarding: () => <OnboardingScreen {...props} />,
    login: () => <LoginScreen {...props} />,
    register: () => <RegisterScreen {...props} />,
    home: () => <HomeScreen {...props} />,
    search: () => <SearchScreen {...props} />,
    ifsp: () => <IfspScreen {...props} />,
    ifspDetail: () => <IfspDetailScreen {...props} />,
    cursos: () => <CursosScreen {...props} />,
    courseDetail: () => <CourseDetailScreen {...props} />,
    benGov: () => <BenefitsScreen {...props} kind="gov" />,
    benInst: () => <BenefitsScreen {...props} kind="inst" />,
    benefitDetail: () => <BenefitDetailScreen {...props} />,
    estagio: () => <EstagioScreen {...props} />,
    depoimentos: () => <DepoimentosScreen {...props} />,
    vagaDetail: () => <VagaDetailScreen {...props} />,
    concursoDetail: () => <ConcursoDetailScreen {...props} />,
    adminLogin: () => <AdminLoginScreen {...props} />,
    adminPanel: () => <AdminPanelScreen {...props} />,
    moradia: () => <MoradiaScreen {...props} />,
    republicas: () => <RepublicasScreen {...props} />,
    duvidas: () => <DuvidasScreen {...props} />,
    perfil: () => <PerfilScreen {...props} />,
    carteirinha: () => <CarteirinhaScreen {...props} />,
    cadastrar: () => <CadastrarScreen {...props} />,
    notifications: () => <NotificationsScreen {...props} />,
  };
  const Render = SCREENS[cur.screen] || SCREENS.home;
  const isAuth = ['splash', 'onboarding', 'login', 'register', 'adminLogin'].includes(cur.screen);
  const showTab = ['home', 'cursos', 'duvidas', 'perfil'].includes(cur.screen);
  // screens whose top area is dark/green and always want a white status bar
  const coloredTop = ['splash', 'onboarding', 'login', 'adminLogin', 'adminPanel', 'ifsp', 'ifspDetail', 'courseDetail', 'benGov', 'benInst', 'benefitDetail', 'estagio', 'depoimentos', 'vagaDetail', 'concursoDetail', 'moradia', 'republicas', 'perfil'];
  const whiteStatus = dark || coloredTop.includes(cur.screen);

  return (
    <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#0C1410', padding: 20 }}>
      <IOSDevice dark={whiteStatus}>
        <div style={{ position: 'absolute', inset: 0, background: 'var(--bg)', overflow: 'hidden' }}>
          <div key={cur.screen + (cur.params ? JSON.stringify(cur.params).slice(0, 20) : '') + stack.length}
            data-screen-label={cur.screen}
            style={{ position: 'absolute', inset: 0, animation: `${dir > 0 ? 'u-slide-in' : 'u-fade'} .32s cubic-bezier(.2,.7,.3,1) both` }}>
            {Render()}
          </div>
          {!isAuth && <MenuDrawer open={menu} nav={nav} user={user} />}
          <Toast toast={toast} />
          {offline && <ConnectionErrorScreen retrying={retrying} onRetry={() => { setRetrying(true); setTimeout(() => { setRetrying(false); setOffline(false); showToast('Conexão restabelecida', 'checkCircle'); }, 1400); }} />}
        </div>
      </IOSDevice>

      <TweaksPanel>
        <TweakSection label="Tela inicial" />
        <TweakRadio label="Layout do Início" value={t.homeLayout} options={['list', 'grid', 'feature']} onChange={v => setTweak('homeLayout', v)} />
        <TweakSection label="Benefícios" />
        <TweakRadio label="Layout de benefícios" value={t.benefitLayout} options={['cards', 'grid', 'list']} onChange={v => setTweak('benefitLayout', v)} />
        <TweakSection label="Aparência" />
        <TweakToggle label="Modo escuro" value={dark} onChange={v => setDark(v)} />
        <TweakSection label="Marca" />
        <TweakColor label="Cor de destaque" value={t.accent} options={Object.keys(ACCENTS)} onChange={v => setTweak('accent', v)} />
        <TweakSection label="Protótipo" />
        <TweakSelect label="Tela inicial do app" value={t.startScreen} options={['splash', 'onboarding', 'login', 'home']} onChange={v => { setTweak('startScreen', v); if (v === 'home') nav.login(); else nav.replace(v); }} />
        <TweakButton label="Simular sem conexão" onClick={() => setOffline(true)}>Mostrar erro de conexão</TweakButton>
        <TweakButton label="Reiniciar fluxo" onClick={() => { setAuthed(false); nav.replace('splash'); }}>Voltar ao início</TweakButton>
      </TweaksPanel>
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
