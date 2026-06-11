// chrome.jsx — UNIVERSE app chrome: shells, headers, bottom nav, drawer, hero.
const STATUS_H = 50;   // clearance for status bar / dynamic island
const NAV_H = 64;      // bottom nav bar height

// ── Page shell: header (sticky) + scrollable body (animated) + optional bottom nav
function PageShell({ header, children, tab, nav, bg = 'var(--bg)', bodyPad = 16, animKey, scrollRef }) {
  return (
    <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', background: bg }}>
      {header}
      <div ref={scrollRef} className="u-scroll" style={{ flex: 1, position: 'relative' }}>
        <div key={animKey} style={{
          padding: bodyPad, paddingBottom: (tab ? NAV_H + 28 : 28),
          animation: 'u-fade-up .4s cubic-bezier(.2,.7,.3,1) both',
          minHeight: '100%',
        }}>
          {children}
        </div>
      </div>
      {tab && <BottomNav tab={tab} nav={nav} />}
    </div>
  );
}

// ── Home header: menu · wordmark · bell
function HomeHeader({ nav, unread = 2 }) {
  return (
    <div style={{
      paddingTop: STATUS_H, padding: `${STATUS_H}px 18px 14px`,
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      background: 'var(--bg)', position: 'relative', zIndex: 5,
    }}>
      <button onClick={() => nav.openMenu()} className="u-press" style={{ width: 42, height: 42, borderRadius: 12, display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'var(--card)', boxShadow: 'var(--shadow-sm)' }}>
        <Icon name="menu" size={22} color="var(--ink)" strokeWidth={2} />
      </button>
      <UniverseWordmark height={24} />
      <button onClick={() => nav.go('notifications')} className="u-press" style={{ width: 42, height: 42, borderRadius: 12, display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'var(--card)', boxShadow: 'var(--shadow-sm)', position: 'relative' }}>
        <Icon name="bell" size={21} color="var(--ink)" strokeWidth={2} />
        {unread > 0 && <span style={{ position: 'absolute', top: 9, right: 10, width: 8, height: 8, borderRadius: '50%', background: '#E23B2E', boxShadow: '0 0 0 2px var(--card)' }} />}
      </button>
    </div>
  );
}

// ── Plain page header: back · title · optional action
function PageHeader({ title, nav, action, onAction, actionIcon }) {
  return (
    <div style={{
      paddingTop: STATUS_H, padding: `${STATUS_H}px 12px 12px`,
      display: 'flex', alignItems: 'center', gap: 6,
      background: 'var(--bg)', position: 'relative', zIndex: 5,
      boxShadow: '0 1px 0 var(--line)',
    }}>
      <button onClick={() => nav.back()} className="u-press" style={{ width: 40, height: 40, borderRadius: 11, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Icon name="chevL" size={24} color="var(--ink)" strokeWidth={2.2} />
      </button>
      <div style={{ flex: 1, fontSize: 17, fontWeight: 800, color: 'var(--ink)', letterSpacing: -0.2 }}>{title}</div>
      {(action || actionIcon) && (
        <button onClick={onAction} className="u-press" style={{ width: 40, height: 40, borderRadius: 11, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          {actionIcon ? <Icon name={actionIcon} size={22} color="var(--green-700)" strokeWidth={2} /> : <span style={{ fontSize: 13, fontWeight: 700, color: 'var(--green-700)' }}>{action}</span>}
        </button>
      )}
    </div>
  );
}

// ── Green hero header for detail pages — curved, deep green
function GreenHero({ title, subtitle, icon, nav, children, tall, action }) {
  return (
    <div style={{
      background: 'linear-gradient(160deg, var(--hero-from), var(--hero-to))',
      borderRadius: '0 0 28px 28px', position: 'relative', zIndex: 5,
      padding: `${STATUS_H}px 20px ${tall ? 26 : 22}px`, color: '#fff',
      boxShadow: '0 10px 24px rgba(0,61,40,0.22)',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 4, marginBottom: tall ? 16 : 12 }}>
        <button onClick={() => nav.back()} className="u-press" style={{ width: 38, height: 38, marginLeft: -8, borderRadius: 11, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Icon name="chevL" size={24} color="#fff" strokeWidth={2.2} />
        </button>
        <div style={{ flex: 1 }} />
        {action || <UniverseBadge size={32} color="rgba(255,255,255,0.95)" ring="rgba(255,255,255,0.6)" />}
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
        {icon && (
          <div style={{ width: 54, height: 54, borderRadius: 15, background: 'rgba(255,255,255,0.14)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, backdropFilter: 'blur(4px)' }}>
            <Icon name={icon} size={28} color="#fff" strokeWidth={1.9} />
          </div>
        )}
        <div style={{ flex: 1 }}>
          <h1 style={{ margin: 0, fontSize: 23, fontWeight: 800, letterSpacing: -0.3 }}>{title}</h1>
          {subtitle && <p style={{ margin: '5px 0 0', fontSize: 13, color: 'rgba(255,255,255,0.78)', lineHeight: 1.4 }}>{subtitle}</p>}
        </div>
      </div>
      {children}
    </div>
  );
}

// ── Bottom navigation
const TABS = [
  { key: 'home', icon: 'home', label: 'Início' },
  { key: 'cursos', icon: 'cap', label: 'Cursos' },
  { key: 'duvidas', icon: 'question', label: 'Dúvidas' },
  { key: 'perfil', icon: 'user', label: 'Perfil' },
];
function BottomNav({ tab, nav }) {
  return (
    <div style={{
      height: NAV_H + 22, paddingBottom: 22, flexShrink: 0,
      background: 'var(--nav-bg)', backdropFilter: 'blur(16px) saturate(180%)',
      WebkitBackdropFilter: 'blur(16px) saturate(180%)',
      boxShadow: '0 -1px 0 var(--line), 0 -8px 24px rgba(13,40,28,0.05)',
      display: 'flex', alignItems: 'stretch', position: 'relative', zIndex: 5,
    }}>
      {TABS.map(t => {
        const active = tab === t.key;
        return (
          <button key={t.key} onClick={() => nav.tab(t.key)} className="u-press"
            style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 4, paddingTop: 8 }}>
            <div style={{ position: 'relative' }}>
              <Icon name={t.icon} size={23} color={active ? 'var(--green-700)' : 'var(--ink-3)'} strokeWidth={active ? 2.2 : 1.8} fill={active ? 'rgba(31,169,113,0.12)' : 'none'} />
            </div>
            <span style={{ fontSize: 10.5, fontWeight: active ? 700 : 600, color: active ? 'var(--green-700)' : 'var(--ink-3)' }}>{t.label}</span>
          </button>
        );
      })}
    </div>
  );
}

// ── Slide-in menu drawer
const MENU_ITEMS = [
  { screen: 'home', tab: true, icon: 'home', label: 'Início' },
  { screen: 'ifsp', icon: 'institution', label: 'IFSP Pirituba' },
  { screen: 'cursos', tab: true, icon: 'cap', label: 'Cursos' },
  { screen: 'benGov', icon: 'benefits', label: 'Benefícios Governamentais' },
  { screen: 'benInst', icon: 'award', label: 'Benefícios Institucionais' },
  { screen: 'estagio', icon: 'briefcase', label: 'Estágio e Concursos' },
  { screen: 'moradia', icon: 'house', label: 'Moradia' },
  { screen: 'duvidas', tab: true, icon: 'question', label: 'Dúvidas' },
  { screen: 'cadastrar', icon: 'edit', label: 'Cadastrar informações' },
];
function MenuDrawer({ open, nav, user }) {
  return (
    <div style={{ position: 'absolute', inset: 0, zIndex: 40, pointerEvents: open ? 'auto' : 'none' }}>
      <div onClick={() => nav.closeMenu()} style={{
        position: 'absolute', inset: 0, background: 'rgba(13,40,28,0.45)',
        opacity: open ? 1 : 0, transition: 'opacity .3s ease', backdropFilter: open ? 'blur(2px)' : 'none',
      }} />
      <div style={{
        position: 'absolute', top: 0, bottom: 0, left: 0, width: '82%', maxWidth: 320,
        background: 'var(--bg)', boxShadow: '8px 0 40px rgba(0,0,0,0.25)',
        transform: open ? 'none' : 'translateX(-100%)', transition: 'transform .32s cubic-bezier(.3,.8,.3,1)',
        display: 'flex', flexDirection: 'column',
      }}>
        <div style={{ background: 'linear-gradient(155deg, var(--hero-from), var(--hero-to))', padding: `${STATUS_H + 6}px 22px 22px`, color: '#fff' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 18 }}>
            <UniverseAppIcon size={44} radius={12} />
            <UniverseWordmark height={20} color="#fff" />
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <Avatar name={user.name} size={46} />
            <div style={{ minWidth: 0 }}>
              <div style={{ fontSize: 15, fontWeight: 700 }}>{user.name}</div>
              <div style={{ fontSize: 12, color: 'rgba(255,255,255,0.7)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{user.email}</div>
            </div>
          </div>
        </div>
        <div className="u-scroll" style={{ flex: 1, padding: '14px 14px' }}>
          {MENU_ITEMS.map(m => (
            <button key={m.screen} onClick={() => { nav.closeMenu(); m.tab ? nav.tab(m.screen) : nav.go(m.screen); }}
              className="u-press" style={{ width: '100%', display: 'flex', alignItems: 'center', gap: 14, padding: '11px 12px', borderRadius: 12, textAlign: 'left' }}>
              <Icon name={m.icon} size={21} color="var(--green-700)" strokeWidth={1.9} />
              <span style={{ flex: 1, fontSize: 14, fontWeight: 600, color: 'var(--ink)' }}>{m.label}</span>
              <Icon name="chevR" size={16} color="var(--ink-3)" strokeWidth={2} />
            </button>
          ))}
          <div style={{ height: 1, background: 'var(--line)', margin: '10px 12px' }} />
          <button onClick={() => { nav.closeMenu(); nav.go('perfil'); }} className="u-press" style={{ width: '100%', display: 'flex', alignItems: 'center', gap: 14, padding: '11px 12px', borderRadius: 12, textAlign: 'left' }}>
            <Icon name="settings" size={21} color="var(--ink-2)" strokeWidth={1.9} />
            <span style={{ flex: 1, fontSize: 14, fontWeight: 600, color: 'var(--ink)' }}>Configurações</span>
          </button>
          <button onClick={() => { nav.closeMenu(); nav.logout(); }} className="u-press" style={{ width: '100%', display: 'flex', alignItems: 'center', gap: 14, padding: '11px 12px', borderRadius: 12, textAlign: 'left' }}>
            <Icon name="logout" size={21} color="#E23B2E" strokeWidth={1.9} />
            <span style={{ flex: 1, fontSize: 14, fontWeight: 600, color: '#E23B2E' }}>Sair</span>
          </button>
        </div>
      </div>
    </div>
  );
}

// ── Toast
function Toast({ toast }) {
  if (!toast) return null;
  return (
    <div style={{ position: 'absolute', top: STATUS_H + 6, left: 0, right: 0, display: 'flex', justifyContent: 'center', zIndex: 60, pointerEvents: 'none' }}>
      <div style={{
        display: 'flex', alignItems: 'center', gap: 9, padding: '11px 16px', borderRadius: 14,
        background: 'var(--toast-bg)', color: '#fff', boxShadow: 'var(--shadow-lg)', maxWidth: '88%',
        animation: 'u-pop .4s cubic-bezier(.2,.8,.3,1) both', fontSize: 13.5, fontWeight: 600,
      }}>
        <Icon name={toast.icon || 'checkCircle'} size={19} color="var(--green-400)" strokeWidth={2.2} />
        {toast.msg}
      </div>
    </div>
  );
}

Object.assign(window, { PageShell, HomeHeader, PageHeader, GreenHero, BottomNav, MenuDrawer, Toast, STATUS_H, NAV_H });
