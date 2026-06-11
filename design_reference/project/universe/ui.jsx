// ui.jsx — UNIVERSE shared UI primitives. Exports to window.

function IconTile({ name, size = 46, icon = 24, bg = 'var(--green-050)', color = 'var(--green-700)', radius = 13, style = {} }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: radius, background: bg, color,
      display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, ...style,
    }}>
      <Icon name={name} size={icon} color={color} strokeWidth={1.9} />
    </div>
  );
}

function Button({ children, variant = 'primary', full, onClick, icon, iconRight, disabled, size = 'md', style = {}, type = 'button' }) {
  const sizes = {
    sm: { h: 38, fs: 13, px: 16, r: 11 },
    md: { h: 50, fs: 15, px: 20, r: 14 },
    lg: { h: 56, fs: 16, px: 24, r: 16 },
  }[size];
  const variants = {
    primary: { background: 'var(--green-800)', color: '#fff', boxShadow: '0 6px 16px rgba(0,87,58,0.26)' },
    accent: { background: 'var(--green-500)', color: '#fff', boxShadow: '0 6px 16px rgba(31,169,113,0.3)' },
    dark: { background: 'var(--ink)', color: '#fff', boxShadow: '0 6px 16px rgba(13,40,28,0.22)' },
    outline: { background: 'transparent', color: 'var(--green-800)', boxShadow: 'inset 0 0 0 1.5px var(--green-100)' },
    ghost: { background: 'var(--green-050)', color: 'var(--green-800)' },
    white: { background: '#fff', color: 'var(--green-800)', boxShadow: 'var(--shadow-sm)' },
  }[variant];
  return (
    <button type={type} onClick={disabled ? undefined : onClick} className="u-press" disabled={disabled}
      style={{
        height: sizes.h, padding: `0 ${sizes.px}px`, borderRadius: sizes.r,
        fontSize: sizes.fs, fontWeight: 700, letterSpacing: 0.2,
        width: full ? '100%' : undefined,
        display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 9,
        opacity: disabled ? 0.45 : 1, cursor: disabled ? 'default' : 'pointer',
        ...variants, ...style,
      }}>
      {icon && <Icon name={icon} size={sizes.fs + 4} color={variants.color} strokeWidth={2} />}
      {children}
      {iconRight && <Icon name={iconRight} size={sizes.fs + 4} color={variants.color} strokeWidth={2} />}
    </button>
  );
}

function Card({ children, onClick, style = {}, pad = 16, hover }) {
  return (
    <div onClick={onClick} className={onClick ? 'u-press' : ''}
      style={{
        background: 'var(--card)', borderRadius: 'var(--radius)', padding: pad,
        boxShadow: 'var(--shadow-sm)', cursor: onClick ? 'pointer' : 'default', ...style,
      }}>
      {children}
    </div>
  );
}

function SectionTitle({ children, action, onAction, style = {} }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', margin: '0 0 12px', ...style }}>
      <h3 style={{ margin: 0, fontSize: 16, fontWeight: 800, color: 'var(--ink)', letterSpacing: -0.2 }}>{children}</h3>
      {action && <button onClick={onAction} className="u-press" style={{ fontSize: 12.5, fontWeight: 700, color: 'var(--green-600)', display: 'flex', alignItems: 'center', gap: 2 }}>{action}<Icon name="chevR" size={14} color="var(--green-600)" strokeWidth={2.2} /></button>}
    </div>
  );
}

function Chip({ children, active, onClick, icon, style = {} }) {
  return (
    <button onClick={onClick} className="u-press" style={{
      height: 36, padding: '0 15px', borderRadius: 999, fontSize: 13, fontWeight: 600,
      display: 'inline-flex', alignItems: 'center', gap: 7, whiteSpace: 'nowrap',
      background: active ? 'var(--green-800)' : 'var(--card)',
      color: active ? '#fff' : 'var(--ink-2)',
      boxShadow: active ? '0 4px 12px rgba(0,87,58,0.22)' : 'inset 0 0 0 1px var(--line)',
      ...style,
    }}>
      {icon && <Icon name={icon} size={15} color={active ? '#fff' : 'var(--ink-3)'} strokeWidth={2} />}
      {children}
    </button>
  );
}

function Field({ label, icon, type = 'text', value, onChange, placeholder, trailing, error, onFocus, onBlur, valid, hint, multiline, maxLength, style = {} }) {
  const [focus, setFocus] = React.useState(false);
  const border = error ? '#E23B2E' : focus ? 'var(--green-500)' : valid ? 'var(--green-400)' : 'var(--line)';
  const InputTag = multiline ? 'textarea' : 'input';
  return (
    <div style={{ ...style }}>
      {label && <label style={{ display: 'block', fontSize: 12.5, fontWeight: 600, color: 'var(--ink-2)', margin: '0 0 7px 3px' }}>{label}</label>}
      <div style={{
        display: 'flex', alignItems: multiline ? 'flex-start' : 'center', gap: 10,
        background: 'var(--card)', borderRadius: 13, padding: multiline ? '13px 14px' : '0 14px',
        height: multiline ? undefined : 50, boxShadow: `inset 0 0 0 1.5px ${border}`,
        transition: 'box-shadow .18s ease',
      }}>
        {icon && <Icon name={icon} size={19} color={focus ? 'var(--green-600)' : 'var(--ink-3)'} style={{ marginTop: multiline ? 2 : 0 }} />}
        <InputTag
          type={type} value={value} placeholder={placeholder} maxLength={maxLength}
          rows={multiline ? 4 : undefined}
          onChange={e => onChange && onChange(e.target.value)}
          onFocus={() => { setFocus(true); onFocus && onFocus(); }}
          onBlur={() => { setFocus(false); onBlur && onBlur(); }}
          style={{
            flex: 1, border: 'none', outline: 'none', background: 'transparent',
            fontSize: 15, color: 'var(--ink)', fontWeight: 500, resize: 'none',
            fontFamily: 'inherit', padding: 0, width: '100%',
          }} />
        {valid && !trailing && <Icon name="check" size={18} color="var(--green-500)" strokeWidth={2.4} />}
        {trailing}
      </div>
      {error && <div style={{ fontSize: 11.5, color: '#E23B2E', margin: '6px 0 0 3px', fontWeight: 600 }}>{error}</div>}
      {hint && !error && <div style={{ fontSize: 11.5, color: 'var(--ink-3)', margin: '6px 0 0 3px' }}>{hint}</div>}
    </div>
  );
}

function PasswordField(props) {
  const [show, setShow] = React.useState(false);
  return <Field {...props} type={show ? 'text' : 'password'} trailing={
    <button onClick={() => setShow(s => !s)} className="u-press" style={{ display: 'flex', padding: 4 }}>
      <Icon name={show ? 'eyeOff' : 'eye'} size={19} color="var(--ink-3)" />
    </button>
  } />;
}

function Avatar({ name = 'A', size = 44, src, style = {} }) {
  const initials = name.split(' ').slice(0, 2).map(s => s[0]).join('').toUpperCase();
  return (
    <div style={{
      width: size, height: size, borderRadius: '50%', flexShrink: 0,
      background: src ? `center/cover url(${src})` : 'linear-gradient(150deg, var(--green-500), var(--green-800))',
      color: '#fff', fontWeight: 700, fontSize: size * 0.38,
      display: 'flex', alignItems: 'center', justifyContent: 'center', ...style,
    }}>{!src && initials}</div>
  );
}

function Toggle({ on, onChange }) {
  return (
    <button onClick={() => onChange(!on)} style={{
      width: 46, height: 28, borderRadius: 999, padding: 3, flexShrink: 0,
      background: on ? 'var(--green-500)' : '#D7DDD8', transition: 'background .2s ease',
      display: 'flex', justifyContent: on ? 'flex-end' : 'flex-start',
    }}>
      <div style={{ width: 22, height: 22, borderRadius: '50%', background: '#fff', boxShadow: '0 1px 3px rgba(0,0,0,0.2)', transition: 'all .2s ease' }} />
    </button>
  );
}

// Accordion item for FAQ
function Accordion({ q, a, open, onToggle }) {
  return (
    <div style={{ background: 'var(--card)', borderRadius: 14, boxShadow: 'var(--shadow-sm)', overflow: 'hidden' }}>
      <button onClick={onToggle} style={{ width: '100%', display: 'flex', alignItems: 'center', gap: 12, padding: '15px 16px', textAlign: 'left' }}>
        <span style={{ flex: 1, fontSize: 14, fontWeight: 600, color: 'var(--ink)', lineHeight: 1.35 }}>{q}</span>
        <div style={{ transform: open ? 'rotate(180deg)' : 'none', transition: 'transform .25s ease' }}>
          <Icon name="chevD" size={18} color="var(--green-600)" strokeWidth={2.2} />
        </div>
      </button>
      <div style={{ maxHeight: open ? 300 : 0, transition: 'max-height .3s ease', overflow: 'hidden' }}>
        <p style={{ margin: 0, padding: '0 16px 16px', fontSize: 13, lineHeight: 1.55, color: 'var(--ink-2)' }}>{a}</p>
      </div>
    </div>
  );
}

// Generic list row with icon + title + subtitle + chevron
function ListRow({ icon, iconBg, iconColor, title, subtitle, onClick, trailing, style = {} }) {
  return (
    <Card onClick={onClick} pad={14} style={{ display: 'flex', alignItems: 'center', gap: 14, ...style }}>
      {icon && <IconTile name={icon} bg={iconBg} color={iconColor} />}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 14.5, fontWeight: 700, color: 'var(--ink)' }}>{title}</div>
        {subtitle && <div style={{ fontSize: 12, color: 'var(--ink-3)', marginTop: 2, lineHeight: 1.4 }}>{subtitle}</div>}
      </div>
      {trailing !== undefined ? trailing : <Icon name="chevR" size={18} color="var(--ink-3)" strokeWidth={2} />}
    </Card>
  );
}

// Status badge — open / closed
function StatusBadge({ status, openLabel = 'Aberta', closedLabel = 'Encerrada', style = {} }) {
  const closed = status === 'closed';
  return (
    <span style={{
      fontSize: 10, fontWeight: 800, letterSpacing: 0.3, padding: '4px 10px', borderRadius: 999,
      color: closed ? '#C0392B' : 'var(--green-700)',
      background: closed ? 'rgba(226,59,46,0.1)' : 'var(--green-050)',
      display: 'inline-flex', alignItems: 'center', gap: 5, ...style,
    }}>
      <span style={{ width: 6, height: 6, borderRadius: '50%', background: closed ? '#E23B2E' : 'var(--green-500)' }} />
      {closed ? closedLabel : openLabel}
    </span>
  );
}

function Stars({ n = 5, size = 14, gap = 2 }) {
  return (
    <div style={{ display: 'inline-flex', gap }}>
      {[0, 1, 2, 3, 4].map(i => (
        <Icon key={i} name="star" size={size} color={i < n ? '#F2B01E' : 'var(--line)'} fill={i < n ? '#F2B01E' : 'none'} strokeWidth={1.6} />
      ))}
    </div>
  );
}

// Empty state
function EmptyState({ icon = 'search', title, body, action, onAction }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', padding: '48px 28px', animation: 'u-fade .4s both' }}>
      <div style={{ width: 76, height: 76, borderRadius: 24, background: 'var(--bg-2)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 18 }}>
        <Icon name={icon} size={34} color="var(--ink-3)" strokeWidth={1.7} />
      </div>
      <div style={{ fontSize: 16, fontWeight: 800, color: 'var(--ink)' }}>{title}</div>
      {body && <div style={{ fontSize: 13, color: 'var(--ink-3)', marginTop: 6, lineHeight: 1.5, maxWidth: 250 }}>{body}</div>}
      {action && <div style={{ marginTop: 18 }}><Button variant="outline" size="md" onClick={onAction}>{action}</Button></div>}
    </div>
  );
}

// Deterministic fake QR — pseudo-random module grid from a seed string
function FakeQR({ size = 132, seed = 'UNIVERSE', fg = 'var(--ink)' }) {
  const n = 21;
  let h = 0; for (let i = 0; i < seed.length; i++) h = (h * 31 + seed.charCodeAt(i)) >>> 0;
  const rng = () => { h = (h * 1103515245 + 12345) & 0x7fffffff; return h / 0x7fffffff; };
  const cell = size / n;
  const rects = [];
  const finder = (cx, cy) => Math.abs(cx - 3) < 4 && Math.abs(cy - 3) < 4 || (cx > n - 8 && cy < 7) || (cx < 7 && cy > n - 8);
  for (let y = 0; y < n; y++) for (let x = 0; x < n; x++) {
    if (finder(x, y)) continue;
    if (rng() > 0.52) rects.push(<rect key={x + '-' + y} x={x * cell} y={y * cell} width={cell} height={cell} fill={fg} />);
  }
  const Finder = ({ x, y }) => (
    <g transform={`translate(${x * cell} ${y * cell})`}>
      <rect width={cell * 7} height={cell * 7} fill={fg} />
      <rect x={cell} y={cell} width={cell * 5} height={cell * 5} fill="#fff" />
      <rect x={cell * 2} y={cell * 2} width={cell * 3} height={cell * 3} fill={fg} />
    </g>
  );
  return (
    <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} style={{ borderRadius: 8 }}>
      <rect width={size} height={size} fill="#fff" />
      {rects}
      <Finder x={0} y={0} /><Finder x={n - 7} y={0} /><Finder x={0} y={n - 7} />
    </svg>
  );
}

Object.assign(window, { IconTile, Button, Card, SectionTitle, Chip, Field, PasswordField, Avatar, Toggle, Accordion, ListRow, StatusBadge, Stars, EmptyState, FakeQR });
