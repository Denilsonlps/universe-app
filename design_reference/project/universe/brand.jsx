// brand.jsx — UNIVERSE logo system + icon set
// Exports to window: UniverseMark, UniverseAppIcon, UniverseWordmark, UniverseBadge, Icon

// ─────────────────────────────────────────────────────────────
// The UNIVERSE mark — derived from the "V" in the wordmark:
// a bold V (checkmark / graduation chevron) crowned with a dot
// that reads as a graduate's head. The brand's whole idea in one glyph.
// ─────────────────────────────────────────────────────────────
function UniverseMark({ size = 64, color = '#00573A', dotColor, style = {} }) {
  const dc = dotColor || color;
  return (
    <svg width={size} height={size} viewBox="0 0 64 64" fill="none" style={style}>
      <path d="M13 17 L32 51 L51 17" stroke={color} strokeWidth="11"
            strokeLinecap="round" strokeLinejoin="round" />
      <circle cx="32" cy="12.5" r="7" fill={dc} />
    </svg>
  );
}

// App icon — rounded squircle, deep-green, mark in white with a bright sweep
function UniverseAppIcon({ size = 96, radius, style = {} }) {
  const r = radius != null ? radius : Math.round(size * 0.235);
  return (
    <div style={{
      width: size, height: size, borderRadius: r, position: 'relative',
      overflow: 'hidden', flexShrink: 0,
      background: 'linear-gradient(150deg, #00734D 0%, #00573A 55%, #003D28 100%)',
      boxShadow: 'inset 0 1.5px 1px rgba(255,255,255,0.18), inset 0 -2px 6px rgba(0,0,0,0.25)',
      display: 'flex', alignItems: 'center', justifyContent: 'center', ...style,
    }}>
      {/* bright sweep */}
      <div style={{
        position: 'absolute', top: -size * 0.35, left: -size * 0.2,
        width: size * 0.9, height: size * 0.9, borderRadius: '50%',
        background: 'radial-gradient(circle, rgba(38,193,125,0.55), transparent 70%)',
      }} />
      <UniverseMark size={size * 0.62} color="#FFFFFF" dotColor="#26C17D"
        style={{ position: 'relative', marginTop: size * 0.02 }} />
    </div>
  );
}

// Full wordmark: UNI + mark + RSE, recreated in type so it scales crisply
function UniverseWordmark({ height = 28, color = '#00573A', style = {} }) {
  const fs = height;
  return (
    <div style={{
      display: 'inline-flex', alignItems: 'center', gap: height * 0.04,
      fontFamily: 'var(--font)', fontWeight: 800, fontSize: fs,
      letterSpacing: fs * 0.02, color, lineHeight: 1, ...style,
    }}>
      <span>UNI</span>
      <UniverseMark size={height * 1.18} color={color} dotColor={color}
        style={{ margin: `0 ${-height * 0.02}px` }} />
      <span>RSE</span>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// UNIVERSE badge — an original circular monogram of our own V-mark.
// Used as a small brand stamp in headers. Distinct from any
// institutional logo — purely our graduate chevron + dot.
// ─────────────────────────────────────────────────────────────
function UniverseBadge({ size = 44, color = '#1FA971', ring, style = {} }) {
  const rc = ring || color;
  return (
    <svg width={size} height={size} viewBox="0 0 44 44" fill="none" style={style}>
      <circle cx="22" cy="22" r="20" stroke={rc} strokeWidth="2.4" opacity="0.55" />
      <path d="M13 18 L22 34 L31 18" stroke={color} strokeWidth="4.4"
            strokeLinecap="round" strokeLinejoin="round" />
      <circle cx="22" cy="13.5" r="3.4" fill={color} />
    </svg>
  );
}

// ─────────────────────────────────────────────────────────────
// Line-icon set — single source of truth. 24×24, currentColor stroke.
// ─────────────────────────────────────────────────────────────
const ICON_PATHS = {
  home: <><path d="M3 10.5 12 3l9 7.5" /><path d="M5 9.5V20a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1V9.5" /><path d="M9.5 21v-6h5v6" /></>,
  cap: <><path d="M2.5 8.5 12 4l9.5 4.5L12 13 2.5 8.5Z" /><path d="M6 10.5V15c0 1.5 2.7 3 6 3s6-1.5 6-3v-4.5" /><path d="M21.5 8.5v5" /></>,
  benefits: <><circle cx="8" cy="8" r="3.2" /><path d="M6.4 8.2h2.2M7.5 6.6v3.2" /><circle cx="17" cy="7.5" r="2.6" /><path d="M17 6.2v2.6M15.7 7.5h2.6" transform="rotate(45 17 7.5)" /><path d="M5 21v-2a4 4 0 0 1 4-4h2" /><circle cx="16.5" cy="17" r="3.4" /><path d="M15.2 17h2.6M16.5 15.7v2.6" /></>,
  institution: <><path d="M3 21h18" /><path d="M5 21V9.5l7-4.5 7 4.5V21" /><path d="M9 21v-4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v4" /><path d="M8.5 11.5h0M15.5 11.5h0" /></>,
  briefcase: <><rect x="3" y="7.5" width="18" height="12.5" rx="2.2" /><path d="M8.5 7.5V6a2 2 0 0 1 2-2h3a2 2 0 0 1 2 2v1.5" /><path d="M3 13h18" /></>,
  edit: <><path d="M14 4.5 17.5 8 8 17.5l-4 1 1-4L14 4.5Z" /><path d="M12.5 6 16 9.5" /></>,
  bell: <><path d="M18 8.5a6 6 0 0 0-12 0c0 6-2.5 7.5-2.5 7.5h17S18 14.5 18 8.5Z" /><path d="M10.2 20a2 2 0 0 0 3.6 0" /></>,
  menu: <><path d="M3.5 6.5h17M3.5 12h17M3.5 17.5h17" /></>,
  user: <><circle cx="12" cy="8" r="4" /><path d="M4.5 20.5a7.5 7.5 0 0 1 15 0" /></>,
  search: <><circle cx="11" cy="11" r="6.5" /><path d="m16 16 4.5 4.5" /></>,
  chevR: <><path d="m9 5 7 7-7 7" /></>,
  chevL: <><path d="m15 5-7 7 7 7" /></>,
  chevD: <><path d="m5 9 7 7 7-7" /></>,
  lock: <><rect x="4.5" y="10.5" width="15" height="10" rx="2.4" /><path d="M8 10.5V7.5a4 4 0 0 1 8 0v3" /><circle cx="12" cy="15.5" r="1.4" /></>,
  mail: <><rect x="3" y="5.5" width="18" height="13" rx="2.4" /><path d="m4 7 8 6 8-6" /></>,
  eye: <><path d="M2.5 12S6 5.5 12 5.5 21.5 12 21.5 12 18 18.5 12 18.5 2.5 12 2.5 12Z" /><circle cx="12" cy="12" r="3" /></>,
  eyeOff: <><path d="M4 4.5 20 20.5" /><path d="M9.6 9.7A3 3 0 0 0 14.3 14M7 7.2C4.3 8.6 2.5 12 2.5 12s3.5 6.5 9.5 6.5a9.7 9.7 0 0 0 3.6-.7M11 5.6a9.6 9.6 0 0 1 1-.1c6 0 9.5 6.5 9.5 6.5a17 17 0 0 1-2 2.8" /></>,
  check: <><path d="m4 12.5 5 5 11-11" /></>,
  checkCircle: <><circle cx="12" cy="12" r="9" /><path d="m8 12 3 3 5-5.5" /></>,
  house: <><path d="M3 11 12 4l9 7" /><path d="M5.5 9.8V20h13V9.8" /><path d="M9.5 20v-5h5v5" /><circle cx="17.5" cy="16.5" r="3.2" fill="none" /><path d="m16.2 16.5 1 1 1.8-1.9" /></>,
  shield: <><path d="M12 3 5 5.5V11c0 4.5 3 7.7 7 9 4-1.3 7-4.5 7-9V5.5L12 3Z" /><path d="m9 11.5 2 2 4-4" /></>,
  question: <><circle cx="12" cy="12" r="9" /><path d="M9.5 9.2a2.6 2.6 0 0 1 5 .8c0 1.7-2.5 2-2.5 4" /><path d="M12 17.4h0" /></>,
  send: <><path d="M21 3 10.5 13.5" /><path d="M21 3 14.5 21l-4-7.5L3 9.5 21 3Z" /></>,
  phone: <><path d="M6.5 3.5h3l1.5 4-2 1.5a11 11 0 0 0 5 5l1.5-2 4 1.5v3a2 2 0 0 1-2.2 2A16 16 0 0 1 4.5 5.7 2 2 0 0 1 6.5 3.5Z" /></>,
  pin: <><path d="M12 21s7-5.5 7-11a7 7 0 1 0-14 0c0 5.5 7 11 7 11Z" /><circle cx="12" cy="10" r="2.6" /></>,
  clock: <><circle cx="12" cy="12" r="8.5" /><path d="M12 7.5V12l3 2" /></>,
  globe: <><circle cx="12" cy="12" r="8.5" /><path d="M3.5 12h17M12 3.5c2.4 2.3 3.6 5.3 3.6 8.5S14.4 18.2 12 20.5C9.6 18.2 8.4 15.2 8.4 12S9.6 5.8 12 3.5Z" /></>,
  doc: <><path d="M6 3h7l5 5v13a0 0 0 0 1 0 0H6a0 0 0 0 1 0 0V3Z" /><path d="M13 3v5h5" /><path d="M9 13h6M9 16.5h6" /></>,
  card: <><rect x="3" y="5.5" width="18" height="13" rx="2.4" /><path d="M3 9.5h18M6.5 14.5h4" /></>,
  bus: <><rect x="4" y="4" width="16" height="13" rx="2.4" /><path d="M4 11.5h16M8 4v7.5M16 4v7.5" /><path d="M6.5 21v-3M17.5 21v-3" /><circle cx="8" cy="14.3" r="0.9" fill="currentColor" stroke="none" /><circle cx="16" cy="14.3" r="0.9" fill="currentColor" stroke="none" /></>,
  star: <><path d="M12 4l2.4 5 5.6.6-4.2 3.8 1.2 5.6L12 16.6 7 19l1.2-5.6L4 9.6 9.6 9 12 4Z" /></>,
  logout: <><path d="M14 7V5a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2v-2" /><path d="M10 12h10m0 0-3-3m3 3-3 3" /></>,
  settings: <><circle cx="12" cy="12" r="3" /><path d="M12 2.5v2.5M12 19v2.5M21.5 12H19M5 12H2.5M18.7 5.3 17 7M7 17l-1.7 1.7M18.7 18.7 17 17M7 7 5.3 5.3" /></>,
  moon: <><path d="M20 13.5A8 8 0 1 1 10.5 4a6.2 6.2 0 0 0 9.5 9.5Z" /></>,
  sun: <><circle cx="12" cy="12" r="4.2" /><path d="M12 2.5v2M12 19.5v2M21.5 12h-2M4.5 12h-2M18.4 5.6 17 7M7 17l-1.4 1.4M18.4 18.4 17 17M7 7 5.6 5.6" /></>,
  plus: <><path d="M12 5v14M5 12h14" /></>,
  flag: <><path d="M5 21V4M5 4h11l-2 3.5L16 11H5" /></>,
  book: <><path d="M5 4.5A2 2 0 0 1 7 3h11v15H7a2 2 0 0 0-2 2V4.5Z" /><path d="M5 18.5A2 2 0 0 1 7 21h11" /></>,
  award: <><circle cx="12" cy="9" r="5.5" /><path d="m8.5 13.5-1.5 7 5-2.5 5 2.5-1.5-7" /></>,
};

function Icon({ name, size = 24, color = 'currentColor', strokeWidth = 1.8, style = {}, fill = 'none' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill={fill}
      stroke={color} strokeWidth={strokeWidth} strokeLinecap="round" strokeLinejoin="round"
      style={{ flexShrink: 0, ...style }}>
      {ICON_PATHS[name] || null}
    </svg>
  );
}

Object.assign(window, { UniverseMark, UniverseAppIcon, UniverseWordmark, UniverseBadge, Icon });
