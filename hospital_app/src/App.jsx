import { useState, useEffect, useRef } from "react";
import { io } from "socket.io-client";

const API_BASE = import.meta.env.VITE_API_URL || "http://localhost:8000/api";
const SOCKET_URL = import.meta.env.VITE_SOCKET_URL || "http://localhost:8000";

// ── Hospital ID (for demo; in production, come from auth) ──
const HOSPITAL_ID = import.meta.env.VITE_HOSPITAL_ID || "1";
const HOSPITAL_ID_NUM = parseInt(HOSPITAL_ID, 10) || 1;

const G = () => (
  <style>{`
    @import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500&display=swap');

    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    :root {
      --font:       'Plus Jakarta Sans', sans-serif;
      --mono:       'IBM Plex Mono', monospace;

      --navy:       #0f172a;
      --navy2:      #1e293b;
      --blue:       #1e4d8c;
      --blue2:      #2563eb;
      --blue3:      #3b82f6;
      --blue-light: #eff6ff;
      --blue-mid:   #bfdbfe;
      --blue-pale:  #dbeafe;

      --bg:         #f8fafc;
      --card:       #ffffff;
      --divider:    #e2e8f0;
      --muted:      #64748b;
      --text:       #0f172a;

      --danger:     #be123c;
      --danger-bg:  #fff1f2;
      --danger-bdr: #fecdd3;

      --warn:       #92400e;
      --warn-bg:    #fffbeb;
      --warn-bdr:   #fde68a;

      --green:      #065f46;
      --green-bg:   #ecfdf5;
      --green-bdr:  #a7f3d0;
      --green-mid:  #10b981;

      --shadow-sm:  0 1px 3px rgba(15,23,42,0.06), 0 2px 8px rgba(15,23,42,0.04);
      --shadow-md:  0 4px 16px rgba(15,23,42,0.09), 0 2px 4px rgba(15,23,42,0.04);

      --r-sm: 8px;
      --r-md: 12px;
    }

    html, body {
      background: var(--bg);
      font-family: var(--font);
      color: var(--text);
      min-height: 100vh;
      -webkit-font-smoothing: antialiased;
    }

    ::-webkit-scrollbar { width: 4px; }
    ::-webkit-scrollbar-track { background: transparent; }
    ::-webkit-scrollbar-thumb { background: var(--blue-mid); border-radius: 4px; }

    @keyframes pulse-ring {
      0%   { transform: scale(0.85); opacity: 0.7; }
      100% { transform: scale(2.2);  opacity: 0; }
    }
    @keyframes slide-down {
      from { opacity: 0; transform: translateY(-8px); }
      to   { opacity: 1; transform: translateY(0); }
    }
    @keyframes soft-blink {
      0%,100% { opacity: 1; } 50% { opacity: 0.3; }
    }
    @keyframes bar-in { from { width: 0; } }
    @keyframes breathe { 0%,100%{opacity:1} 50%{opacity:0.35} }

    .card-enter { animation: slide-down 0.28s cubic-bezier(.16,1,.3,1) both; }

    button { font-family: var(--font); cursor: pointer; outline: none; }

    .chip {
      display: inline-flex; align-items: center; gap: 4px;
      padding: 3px 10px; border-radius: 99px;
      font-size: 11px; font-weight: 600;
      font-family: var(--mono);
    }

    .sb-btn {
      width: 40px; height: 40px; border-radius: 8px;
      background: transparent; border: none;
      display: flex; align-items: center; justify-content: center;
      color: rgba(255,255,255,0.45);
      transition: all 0.18s; cursor: pointer;
    }
    .sb-btn:hover { background: rgba(255,255,255,0.08); color: rgba(255,255,255,0.85); }
    .sb-btn.active { background: rgba(255,255,255,0.12); color: #fff; }

    .btn-accept {
      display: inline-flex; align-items: center; gap: 6px;
      background: var(--blue);
      color: #fff; border: none;
      padding: 9px 22px; border-radius: 8px;
      font-weight: 600; font-size: 13px;
      transition: all 0.18s;
      box-shadow: 0 2px 8px rgba(30,77,140,0.25);
    }
    .btn-accept:hover { background: #163a6e; transform: translateY(-1px); box-shadow: 0 4px 14px rgba(30,77,140,0.32); }

    .btn-reject {
      background: var(--card); color: var(--muted);
      border: 1px solid var(--divider);
      padding: 9px 22px; border-radius: 8px;
      font-weight: 500; font-size: 13px;
      transition: all 0.18s;
    }
    .btn-reject:hover { border-color: var(--danger); color: var(--danger); background: var(--danger-bg); }

    .btn-dismiss {
      background: transparent; border: none;
      color: var(--muted); font-size: 14px;
      width: 26px; height: 26px; border-radius: 6px;
      display: flex; align-items: center; justify-content: center;
      transition: all 0.15s;
    }
    .btn-dismiss:hover { background: var(--divider); color: var(--navy); }
  `}</style>
);

// ── Icons ─────────────────────────────────────────────────────────────────────
const IcnHome = () => (
  <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M3 10.5L12 3l9 7.5V20a1 1 0 01-1 1H4a1 1 0 01-1-1v-9.5z"/>
    <path d="M9 21V13h6v8"/>
  </svg>
);
const IcnSettings = () => (
  <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <circle cx="12" cy="12" r="3"/>
    <path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z"/>
  </svg>
);
const IcnLogout = () => (
  <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/>
    <polyline points="16 17 21 12 16 7"/>
    <line x1="21" y1="12" x2="9" y2="12"/>
  </svg>
);
const IcnBed = () => (
  <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M3 7v11M21 7v11M3 12h18M3 7h4a2 2 0 012 2v3H5V9a2 2 0 00-2-2zM13 7h4a2 2 0 012 2v3h-6V9a2 2 0 00-2-2z"/>
  </svg>
);
const IcnHeart = () => (
  <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 000-7.78z"/>
  </svg>
);
const IcnWind = () => (
  <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M9.59 4.59A2 2 0 1111 8H2M12.59 19.41A2 2 0 1014 16H2M17.73 7.73A2.5 2.5 0 1119.5 12H2"/>
  </svg>
);

// ── Sidebar ───────────────────────────────────────────────────────────────────
function Sidebar() {
  return (
    <div style={{
      width: 210,
      background: "linear-gradient(180deg, #0c1f40 0%, #0a1628 60%, #070e1c 100%)",
      display: "flex", flexDirection: "column",
      position: "fixed", left: 0, top: 0, bottom: 0,
      zIndex: 50,
      borderRight: "1px solid rgba(255,255,255,0.06)",
    }}>

      {/* Brand */}
      <div style={{ padding: "22px 18px 18px", borderBottom: "1px solid rgba(255,255,255,0.06)" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
          <div style={{
            width: 38, height: 38, borderRadius: 10, flexShrink: 0,
            background: "linear-gradient(135deg, #1d4ed8 0%, #3b82f6 100%)",
            display: "flex", alignItems: "center", justifyContent: "center",
            fontWeight: 700, fontSize: 14, color: "#fff",
            boxShadow: "0 4px 16px rgba(37,99,235,0.45)",
            userSelect: "none", fontFamily: "var(--mono)",
          }}>H+</div>
          <div>
            <div style={{ fontSize: 13, fontWeight: 700, color: "#fff", letterSpacing: "-0.01em", lineHeight: 1.2 }}>Dashboard</div>
            <div style={{ fontSize: 10, color: "rgba(255,255,255,0.32)", marginTop: 2, letterSpacing: "0.03em" }}>Emergency Command</div>
          </div>
        </div>
      </div>

      {/* System Status */}
      <div style={{ margin: "14px 12px 0", background: "rgba(16,185,129,0.07)", border: "1px solid rgba(16,185,129,0.16)", borderRadius: 9, padding: "9px 12px", display: "flex", alignItems: "center", gap: 8 }}>
        <div style={{ position: "relative", width: 7, height: 7, flexShrink: 0 }}>
          <div style={{ width: 7, height: 7, borderRadius: "50%", background: "#10b981", position: "absolute" }} />
          <div style={{ width: 7, height: 7, borderRadius: "50%", background: "#10b981", position: "absolute", animation: "pulse-ring 2.2s ease-out infinite" }} />
        </div>
        <div>
          <div style={{ fontSize: 11, fontWeight: 600, color: "#34d399" }}>System Online</div>
          <div style={{ fontSize: 10, color: "rgba(255,255,255,0.28)", marginTop: 1 }}>Live · Connected</div>
        </div>
      </div>

      {/* Nav label */}
      <div style={{ padding: "18px 18px 6px" }}>
        <span style={{ fontSize: 9, fontWeight: 700, color: "rgba(255,255,255,0.18)", textTransform: "uppercase", letterSpacing: "0.12em" }}>Menu</span>
      </div>

      {/* Nav items */}
      <div style={{ display: "flex", flexDirection: "column", gap: 2, padding: "0 8px" }}>
        {[
          { label: "Dashboard", active: true,  SbIco: IcnHome     },
          { label: "Settings",  active: false, SbIco: IcnSettings },
        ].map(({ label, active, SbIco }) => (
          <button key={label} style={{
            display: "flex", alignItems: "center", gap: 10,
            padding: "9px 12px", borderRadius: 8, border: "none",
            background: active ? "rgba(37,99,235,0.16)" : "transparent",
            color: active ? "#fff" : "rgba(255,255,255,0.4)",
            fontSize: 13, fontWeight: active ? 600 : 400,
            cursor: "pointer", width: "100%", textAlign: "left",
            transition: "all 0.18s", position: "relative",
          }}
            onMouseEnter={e => { if (!active) { e.currentTarget.style.background = "rgba(255,255,255,0.06)"; e.currentTarget.style.color = "rgba(255,255,255,0.75)"; }}}
            onMouseLeave={e => { if (!active) { e.currentTarget.style.background = "transparent"; e.currentTarget.style.color = "rgba(255,255,255,0.4)"; }}}
          >
            {active && <div style={{ position: "absolute", left: 0, top: "50%", transform: "translateY(-50%)", width: 3, height: 20, background: "#60a5fa", borderRadius: "0 3px 3px 0" }} />}
            <SbIco />
            <span>{label}</span>
          </button>
        ))}
      </div>

      {/* Divider */}
      <div style={{ margin: "16px 12px", height: 1, background: "rgba(255,255,255,0.06)" }} />



      {/* Sign Out */}
      <div style={{ marginTop: "auto", padding: "12px 8px", borderTop: "1px solid rgba(255,255,255,0.06)" }}>
        <button style={{
          display: "flex", alignItems: "center", gap: 10,
          padding: "9px 12px", borderRadius: 8, border: "none",
          background: "transparent", color: "rgba(252,165,165,0.4)",
          fontSize: 13, fontWeight: 400, cursor: "pointer", width: "100%",
          transition: "all 0.18s",
        }}
          onMouseEnter={e => { e.currentTarget.style.background = "rgba(239,68,68,0.08)"; e.currentTarget.style.color = "rgba(252,165,165,0.8)"; }}
          onMouseLeave={e => { e.currentTarget.style.background = "transparent"; e.currentTarget.style.color = "rgba(252,165,165,0.4)"; }}
        >
          <IcnLogout />
          <span>Sign Out</span>
        </button>
      </div>
    </div>
  );
}

// ── Live Clock

// ── Live Clock ────────────────────────────────────────────────────────────────
function LiveClock() {
  const [t, setT] = useState(new Date());
  useEffect(() => { const id = setInterval(() => setT(new Date()), 1000); return () => clearInterval(id); }, []);
  return (
    <span style={{ fontSize: 13, fontWeight: 500, color: "var(--navy2)", letterSpacing: "0.05em", fontFamily: "var(--mono)" }}>
      {t.toLocaleTimeString("en-IN", { hour12: false })}
    </span>
  );
}

// ── Bed Gauge ─────────────────────────────────────────────────────────────────
function BedGauge({ label, value, max, IcnCmp }) {
  const pct   = max > 0 ? Math.round((value / max) * 100) : 0;
  const isLow = pct <= 15;
  const isMid = pct > 15 && pct <= 35;

  const barColor = isLow ? "#e11d48" : isMid ? "#d97706" : "var(--blue2)";
  const numColor = isLow ? "var(--danger)" : isMid ? "var(--warn)" : "var(--blue)";
  const badge = isLow
    ? { bg: "var(--danger-bg)", bdr: "var(--danger-bdr)", c: "var(--danger)", lbl: "Critical" }
    : isMid
    ? { bg: "var(--warn-bg)",   bdr: "var(--warn-bdr)",   c: "var(--warn)",   lbl: "Low"      }
    : { bg: "var(--green-bg)",  bdr: "var(--green-bdr)",  c: "var(--green)",  lbl: "Normal"   };

  return (
    <div style={{
      flex: 1, background: "var(--card)", borderRadius: "var(--r-md)",
      padding: "18px 20px", boxShadow: "var(--shadow-sm)",
      border: "1px solid var(--divider)",
      transition: "box-shadow 0.2s, transform 0.2s",
    }}
      onMouseEnter={e => { e.currentTarget.style.boxShadow = "var(--shadow-md)"; e.currentTarget.style.transform = "translateY(-1px)"; }}
      onMouseLeave={e => { e.currentTarget.style.boxShadow = "var(--shadow-sm)"; e.currentTarget.style.transform = ""; }}
    >
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 14 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 6, color: "var(--muted)" }}>
          <IcnCmp />
          <span style={{ fontSize: 11, fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.08em" }}>{label}</span>
        </div>
        <span style={{
          fontSize: 10, fontWeight: 600, padding: "2px 8px", borderRadius: 6,
          background: badge.bg, border: `1px solid ${badge.bdr}`, color: badge.c,
          fontFamily: "var(--mono)",
        }}>{badge.lbl}</span>
      </div>

      <div style={{ display: "flex", alignItems: "baseline", gap: 5, marginBottom: 14 }}>
        <span style={{ fontSize: 36, fontWeight: 700, color: numColor, lineHeight: 1, fontFamily: "var(--mono)" }}>{value}</span>
        <span style={{ fontSize: 13, color: "var(--muted)" }}>/ {max}</span>
      </div>

      <div style={{ height: 4, background: "var(--blue-pale)", borderRadius: 99, overflow: "hidden", marginBottom: 8 }}>
        <div style={{
          height: "100%", width: `${pct}%`, background: barColor, borderRadius: 99,
          transition: "width 0.9s cubic-bezier(.16,1,.3,1)",
          animation: "bar-in 0.9s ease",
        }} />
      </div>
      <div style={{ display: "flex", justifyContent: "space-between" }}>
        <span style={{ fontSize: 11, color: "var(--muted)", fontFamily: "var(--mono)" }}>{pct}% available</span>
        <span style={{ fontSize: 11, color: "var(--muted)", fontFamily: "var(--mono)" }}>of {max}</span>
      </div>
    </div>
  );
}

// ── Alert Banner ──────────────────────────────────────────────────────────────
function AlertBanner({ alerts, onDismiss }) {
  if (!alerts.length) return null;
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 8, marginBottom: 18 }}>
      {alerts.map(a => {
        const isCrit = a.level === "critical";
        return (
          <div key={a.id} className="card-enter" style={{
            background: isCrit ? "var(--danger-bg)" : "var(--warn-bg)",
            border: `1px solid ${isCrit ? "var(--danger-bdr)" : "var(--warn-bdr)"}`,
            borderLeft: `3px solid ${isCrit ? "var(--danger)" : "var(--warn)"}`,
            borderRadius: "var(--r-sm)",
            padding: "12px 16px",
            display: "flex", alignItems: "center", gap: 12,
            boxShadow: "var(--shadow-sm)",
          }}>
            <span style={{ fontSize: 15, flexShrink: 0 }}>{isCrit ? "🚨" : "⚠️"}</span>
            <div style={{ flex: 1 }}>
              <div style={{ fontWeight: 700, fontSize: 13, color: isCrit ? "var(--danger)" : "var(--warn)", marginBottom: 2 }}>{a.title}</div>
              <div style={{ fontSize: 12, color: "var(--navy2)", fontWeight: 400 }}>{a.message}</div>
            </div>
            <span style={{ fontSize: 11, color: "var(--muted)", fontFamily: "var(--mono)", marginRight: 4 }}>{a.time}</span>
            <button className="btn-dismiss" onClick={() => onDismiss(a.id)}>✕</button>
          </div>
        );
      })}
    </div>
  );
}

// ── Request Card ──────────────────────────────────────────────────────────────
function RequestCard({ req, onAccept, onReject }) {
  const isCrit = req.severity === "CRITICAL";
  const ac   = isCrit ? "var(--danger)" : "var(--warn)";
  const abg  = isCrit ? "var(--danger-bg)" : "var(--warn-bg)";
  const abdr = isCrit ? "var(--danger-bdr)" : "var(--warn-bdr)";
  const dotC = isCrit ? "#e11d48" : "#d97706";

  return (
    <div className="card-enter" style={{
      background: "var(--card)", borderRadius: "var(--r-md)", marginBottom: 12,
      boxShadow: "var(--shadow-sm)", border: "1px solid var(--divider)",
      overflow: "hidden",
      transition: "transform 0.2s, box-shadow 0.2s",
    }}
      onMouseEnter={e => { e.currentTarget.style.transform = "translateY(-1px)"; e.currentTarget.style.boxShadow = "var(--shadow-md)"; }}
      onMouseLeave={e => { e.currentTarget.style.transform = "translateY(0)";    e.currentTarget.style.boxShadow = "var(--shadow-sm)"; }}
    >
      <div style={{ padding: "10px 16px", background: abg, borderBottom: `1px solid ${abdr}`, display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
          <div style={{ position: "relative", width: 8, height: 8, flexShrink: 0 }}>
            <div style={{ width: 8, height: 8, borderRadius: "50%", background: dotC, position: "absolute" }} />
            <div style={{ width: 8, height: 8, borderRadius: "50%", background: dotC, position: "absolute", animation: "pulse-ring 2s ease-out infinite" }} />
          </div>
          <span style={{ fontSize: 11, fontWeight: 700, color: ac, letterSpacing: "0.06em", textTransform: "uppercase" }}>Incoming Request</span>
        </div>
        <span className="chip" style={{ background: abg, color: ac, border: `1px solid ${abdr}` }}>{req.severity}</span>
      </div>

      <div style={{ padding: "16px" }}>
        <div style={{ fontSize: 15, fontWeight: 700, color: "var(--navy)", marginBottom: 14, letterSpacing: "-0.01em" }}>Emergency #{req.id}</div>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(3, 1fr)", gap: 10, marginBottom: 16, paddingBottom: 14, borderBottom: "1px solid var(--divider)" }}>
          {[["Condition", req.description], ["Location", req.location], ["Ambulance", req.ambulance]].map(([lbl, val]) => (
            <div key={lbl}>
              <div style={{ fontSize: 10, color: "var(--muted)", fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.07em", marginBottom: 4 }}>{lbl}</div>
              <div style={{ fontSize: 13, fontWeight: 600, color: "var(--navy2)" }}>{val}</div>
            </div>
          ))}
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
          <button className="btn-accept" onClick={() => onAccept(req.id)}>Accept</button>
          <button className="btn-reject" onClick={() => onReject(req.id)}>Reject</button>
          {req.timeAgo && <span style={{ fontSize: 11, color: "var(--muted)", fontFamily: "var(--mono)", marginLeft: 4 }}>{req.timeAgo}</span>}
        </div>
      </div>
    </div>
  );
}

// ── Accepted Card ─────────────────────────────────────────────────────────────
function AcceptedCard({ req }) {
  return (
    <div className="card-enter" style={{
      background: "var(--card)", borderRadius: "var(--r-md)", marginBottom: 12,
      boxShadow: "var(--shadow-sm)", border: "1px solid var(--divider)",
      overflow: "hidden",
      transition: "transform 0.2s, box-shadow 0.2s",
    }}
      onMouseEnter={e => { e.currentTarget.style.transform = "translateY(-1px)"; e.currentTarget.style.boxShadow = "var(--shadow-md)"; }}
      onMouseLeave={e => { e.currentTarget.style.transform = "translateY(0)";    e.currentTarget.style.boxShadow = "var(--shadow-sm)"; }}
    >
      <div style={{ padding: "10px 16px", background: "var(--green-bg)", borderBottom: "1px solid var(--green-bdr)", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <span style={{ fontSize: 11, fontWeight: 700, color: "var(--green)", letterSpacing: "0.06em", textTransform: "uppercase" }}>Accepted · Preparing Unit</span>
        <span className="chip" style={{ background: "var(--card)", color: "var(--green)", border: "1px solid var(--green-bdr)" }}>#{req.id}</span>
      </div>

      <div style={{ padding: "16px" }}>
        <div style={{ fontSize: 15, fontWeight: 700, color: "var(--navy)", marginBottom: 14, letterSpacing: "-0.01em" }}>Emergency #{req.id}</div>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 10, marginBottom: 14, paddingBottom: 14, borderBottom: "1px solid var(--divider)" }}>
          {[["Condition", req.description], ["Location", req.location], ["Ambulance", req.ambulance]].map(([lbl, val]) => (
            <div key={lbl}>
              <div style={{ fontSize: 10, color: "var(--muted)", fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.07em", marginBottom: 4 }}>{lbl}</div>
              <div style={{ fontSize: 13, fontWeight: 600, color: "var(--navy2)" }}>{val}</div>
            </div>
          ))}
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
          <div style={{ width: 6, height: 6, borderRadius: "50%", background: "var(--green-mid)", animation: "breathe 2.5s ease infinite" }} />
          <span style={{ fontSize: 11, color: "var(--green)", fontWeight: 600 }}>Ambulance en route</span>
        </div>
      </div>
    </div>
  );
}

// ── Section Title ─────────────────────────────────────────────────────────────
function SectionTitle({ title, count, dotColor, chipBg, chipBdr }) {
  return (
    <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 14 }}>
      <div style={{ display: "flex", alignItems: "center", gap: 9 }}>
        <div style={{ width: 3, height: 18, borderRadius: 2, background: dotColor }} />
        <h2 style={{ fontSize: 13, fontWeight: 700, color: "var(--muted)", textTransform: "uppercase", letterSpacing: "0.07em" }}>{title}</h2>
      </div>
      {count > 0 && (
        <span className="chip" style={{ background: chipBg, color: dotColor, border: `1px solid ${chipBdr}` }}>{count}</span>
      )}
    </div>
  );
}

// ── Empty State ───────────────────────────────────────────────────────────────
function Empty({ line1, line2 }) {
  return (
    <div style={{
      background: "var(--card)", borderRadius: "var(--r-md)", padding: "44px 24px",
      textAlign: "center", boxShadow: "var(--shadow-sm)",
      border: "1.5px dashed var(--divider)",
    }}>
      <div style={{ color: "var(--muted)", fontSize: 13, fontWeight: 500, lineHeight: 1.8 }}>
        {line1}<br />
        <span style={{ fontSize: 12, color: "var(--blue3)", fontWeight: 600 }}>{line2}</span>
      </div>
    </div>
  );
}

// ── MAIN APP ──────────────────────────────────────────────────────────────────
export default function App() {
  const [requests,         setRequests]         = useState([]);
  const [acceptedPatients, setAcceptedPatients] = useState([]);
  const [alerts,           setAlerts]           = useState([]);
  const [beds, setBeds] = useState({ icu: 8, general: 22, ventilators: 5, icuMax: 12, generalMax: 40, ventMax: 8 });
  const alertId    = useRef(0);
  const prevIcu    = useRef(beds.icu);
  const rejectedIds = useRef(new Set());
  const socketRef   = useRef(null);

  // ── Helper: time-ago ────────────────────────────────────────
  function timeAgo(iso) {
    if (!iso) return "";
    const diff = Math.floor((Date.now() - new Date(iso).getTime()) / 1000);
    if (diff < 60)   return `${diff}s ago`;
    if (diff < 3600)  return `${Math.floor(diff / 60)}m ago`;
    return `${Math.floor(diff / 3600)}h ago`;
  }

  // ── Convert server emergency to UI card format ──────────────
  function emergencyToCard(e) {
    return {
      id:          e.request_id,
      description: e.description || "No description",
      location:    (e.patient_lat && e.patient_lng)
                     ? `Lat ${Number(e.patient_lat).toFixed(4)}, Lng ${Number(e.patient_lng).toFixed(4)}`
                     : "Unavailable",
      severity:    e.severity || "HIGH",
      status:      e.status,
      ambulance:   e.ambulance
                     ? `${e.ambulance.driver_name} — ${e.ambulance.ambulance_no}`
                     : "Assigning…",
      timeAgo:     timeAgo(e.created_at),
    };
  }

  // ── Add a real-time incoming request from Socket.IO ─────────
  function addIncomingRequest(data) {
    const card = {
      ...emergencyToCard({
        request_id:   data.request_id,
        description:   data.description,
        patient_lat:   data.patient_location?.latitude,
        patient_lng:   data.patient_location?.longitude,
        severity:      data.severity,
        created_at:    data.timestamp,
      }),
      isNew: true,
    };
    setRequests(prev => {
      if (prev.some(r => r.id === card.id)) return prev;
      return [card, ...prev];
    });
    // Auto-remove the "new" highlight after 3s
    setTimeout(() => {
      setRequests(prev =>
        prev.map(r => r.id === card.id ? { ...r, isNew: false } : r)
      );
    }, 3000);
  }

  // ── Connect to Socket.IO ────────────────────────────────────
  useEffect(() => {
    const socket = io(SOCKET_URL, {
      transports: ["websocket"],
      reconnection: true,
      reconnectionAttempts: 10,
      reconnectionDelay: 1000,
    });

    socketRef.current = socket;

    socket.on("connect", () => {
      console.log("[Socket] Connected to server");
      socket.emit("register_hospital", { hospitalId: HOSPITAL_ID_NUM }, (res) => {
        console.log("[Socket] register_hospital response:", res);
      });
    });

    // Listen for new emergency requests from the server
    socket.on("hospital_new_request", (data) => {
      console.log("[Socket] hospital_new_request:", data);
      addIncomingRequest(data);
    });

    socket.on("disconnect", () => {
      console.log("[Socket] Disconnected");
    });

    socket.on("connect_error", (err) => {
      console.error("[Socket] Connection error:", err);
    });

    return () => {
      socket.disconnect();
      socketRef.current = null;
    };
  }, []);

  // ── Poll server for active emergencies (reduced frequency) ──
  useEffect(() => {
    let active = true;

    const fetchEmergencies = async () => {
      try {
        const res  = await fetch(`${API_BASE}/hospital/emergencies`);
        const json = await res.json();
        if (!active) return;

        if (json.success && json.data?.emergencies) {
          const acceptedIds = new Set(acceptedPatients.map(p => p.id));
          const incoming = json.data.emergencies
            .filter(e => !acceptedIds.has(e.request_id) && !rejectedIds.current.has(e.request_id))
            .map(emergencyToCard);
          setRequests(incoming);
        }
      } catch (err) {
        console.error("Fetch emergencies error:", err);
      }
    };

    fetchEmergencies();
    // Reduced polling to every 15s (Socket.IO handles real-time adds)
    const timer = setInterval(fetchEmergencies, 15000);
    return () => { active = false; clearInterval(timer); };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [acceptedPatients]);

  // ── Alert bridge (keep for window.updateBeds / window.triggerAlert) ──
  useEffect(() => {
    window.updateBeds  = (data) => setBeds(p => ({ ...p, ...data }));
    window.triggerAlert = (data) => {
      const id  = ++alertId.current;
      const now = new Date().toLocaleTimeString("en-IN", { hour: "2-digit", minute: "2-digit", hour12: false });
      setAlerts(p => [{ ...data, id, time: now }, ...p.slice(0, 4)]);
    };
  }, []);

  useEffect(() => {
    if (prevIcu.current === beds.icu) return;
    prevIcu.current = beds.icu;
    if (beds.icu <= 2)      window.triggerAlert?.({ level: "critical", title: "ICU Beds Critical",    message: `Only ${beds.icu} ICU bed(s) remaining. Immediate action required.` });
    else if (beds.icu <= 4) window.triggerAlert?.({ level: "warning",  title: "ICU Beds Running Low", message: `${beds.icu} ICU beds left. Consider diverting non-critical patients.` });
  }, [beds.icu]);

  // ── Accept: tell server then move card ─────────────────────
  async function acceptRequest(id) {
    const sel = requests.find(r => r.id === id);
    if (!sel) return;
    setAcceptedPatients(p => [sel, ...p]);
    setRequests(p => p.filter(r => r.id !== id));
    try {
      // Use the proper respond endpoint for hospital matching workflow
      // First fetch active-requests to get the hospital_request_id
      const res = await fetch(`${API_BASE}/hospital/active-requests/${HOSPITAL_ID}`);
      const json = await res.json();
      let hospitalRequestId = null;
      if (json.success && json.data?.requests) {
        const match = json.data.requests.find(
          r => r.request_id === id && r.status === "pending"
        );
        hospitalRequestId = match?.hospital_request_id;
      }
      // Fallback: try direct accept endpoint
      if (!hospitalRequestId) {
        await fetch(`${API_BASE}/hospital/emergencies/${id}/accept`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ hospital_id: HOSPITAL_ID }),
        });
      } else {
        await fetch(`${API_BASE}/hospital/respond`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            hospitalRequestId,
            decision: "approve",
          }),
        });
      }
    } catch (err) { console.error("Accept error:", err); }
  }

  // ── Reject: tell server then remove card ──────────────────
  async function rejectRequest(id) {
    rejectedIds.current.add(id);
    setRequests(p => p.filter(r => r.id !== id));
    try {
      // Try to find the hospital_request_id for proper rejection
      const res = await fetch(`${API_BASE}/hospital/active-requests/${HOSPITAL_ID}`);
      const json = await res.json();
      let hospitalRequestId = null;
      if (json.success && json.data?.requests) {
        const match = json.data.requests.find(
          r => r.request_id === id && r.status === "pending"
        );
        hospitalRequestId = match?.hospital_request_id;
      }
      if (hospitalRequestId) {
        await fetch(`${API_BASE}/hospital/respond`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            hospitalRequestId,
            decision: "reject",
          }),
        });
      }
    } catch (err) { console.error("Reject error:", err); }
  }
  function dismissAlert(id)  { setAlerts(p => p.filter(a => a.id !== id)); }

  const totalActive = requests.length + acceptedPatients.length;

  return (
    <>
      <G />
      <div style={{ display: "flex", minHeight: "100vh" }}>

        <Sidebar />

        <div style={{ flex: 1, marginLeft: 210, display: "flex", flexDirection: "column", minHeight: "100vh" }}>

          {/* TOP BAR */}
          <header style={{
            background: "#fff",
            borderBottom: "1px solid var(--divider)",
            position: "sticky", top: 0, zIndex: 40,
          }}>
            {/* Main bar */}
            <div style={{
              padding: "0 28px", height: 60,
              display: "flex", alignItems: "center", justifyContent: "space-between",
              borderBottom: "1px solid var(--divider)",
            }}>
              <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
                <div style={{ width: 3, height: 32, background: "linear-gradient(180deg, #2563eb, #60a5fa)", borderRadius: 2 }} />
                <div>
                  <h1 style={{ fontSize: 16, fontWeight: 700, color: "var(--navy)", letterSpacing: "-0.02em", lineHeight: 1.2 }}>Emergency Dashboard</h1>
                  <div style={{ fontSize: 11, color: "var(--muted)", marginTop: 2, display: "flex", alignItems: "center", gap: 5 }}>
                    <span>Hospital Coordination</span>
                    <span style={{ color: "var(--divider)" }}>{"›"}</span>
                    <span style={{ color: "var(--blue2)", fontWeight: 500 }}>Live Operations</span>
                  </div>
                </div>
              </div>
              <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
                {totalActive > 0 && (
                  <span className="chip" style={{ background: "var(--danger-bg)", color: "var(--danger)", border: "1px solid var(--danger-bdr)", animation: "soft-blink 2.2s ease infinite" }}>
                    {totalActive} Active
                  </span>
                )}
                <div style={{ width: 1, height: 24, background: "var(--divider)" }} />
                <div style={{ display: "flex", alignItems: "center", gap: 6, background: "var(--green-bg)", border: "1px solid var(--green-bdr)", borderRadius: 8, padding: "5px 11px" }}>
                  <div style={{ width: 6, height: 6, borderRadius: "50%", background: "var(--green-mid)", animation: "breathe 2.5s ease infinite" }} />
                  <span style={{ fontSize: 11, fontWeight: 700, color: "var(--green)", letterSpacing: "0.05em" }}>LIVE</span>
                </div>
                <div style={{ background: "var(--bg)", border: "1px solid var(--divider)", borderRadius: 8, padding: "5px 13px", boxShadow: "var(--shadow-sm)" }}>
                  <LiveClock />
                </div>
              </div>
            </div>

            {/* Stats strip */}
            <div style={{ padding: "0 28px", height: 38, display: "flex", alignItems: "center", gap: 28, background: "var(--bg)" }}>
              {[
                { label: "Incoming",  value: requests.length,         color: "var(--danger)" },
                { label: "Preparing", value: acceptedPatients.length, color: "var(--green)"  },
                { label: "ICU Free",  value: beds.icu,                color: "var(--blue2)"  },
                { label: "Gen. Free", value: beds.general,            color: "var(--blue2)"  },
                { label: "Vents",     value: beds.ventilators,        color: "var(--blue2)"  },
              ].map(({ label, value, color }) => (
                <div key={label} style={{ display: "flex", alignItems: "center", gap: 6 }}>
                  <span style={{ fontSize: 11, color: "var(--muted)" }}>{label}</span>
                  <span style={{ fontSize: 13, fontWeight: 700, color, fontFamily: "var(--mono)" }}>{value}</span>
                </div>
              ))}
              <div style={{ marginLeft: "auto", fontSize: 11, color: "var(--muted)", display: "flex", alignItems: "center", gap: 5 }}>
                <div style={{ width: 5, height: 5, borderRadius: "50%", background: "var(--green-mid)", animation: "breathe 2.5s ease infinite" }} />
                Synced · Realtime
              </div>
            </div>
          </header>

          {/* BODY */}
          <div style={{ flex: 1, padding: "20px 28px", overflowY: "auto" }}>

            {/* BED AVAILABILITY */}
            <div style={{
              background: "var(--card)", borderRadius: "var(--r-md)",
              padding: "18px 20px", boxShadow: "var(--shadow-sm)",
              marginBottom: 16, border: "1px solid var(--divider)",
            }}>
              <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 16 }}>
                <div style={{ width: 3, height: 16, background: "var(--blue2)", borderRadius: 2 }} />
                <h2 style={{ fontSize: 13, fontWeight: 700, color: "var(--muted)", textTransform: "uppercase", letterSpacing: "0.07em" }}>Bed Availability</h2>
                <div style={{ flex: 1, height: 1, background: "var(--divider)", marginLeft: 4 }} />
                <div style={{ display: "flex", alignItems: "center", gap: 5 }}>
                  <div style={{ width: 5, height: 5, borderRadius: "50%", background: "var(--green-mid)", animation: "breathe 2.5s ease infinite" }} />
                  <span style={{ fontSize: 11, color: "var(--muted)", fontWeight: 500 }}>Synced · Realtime</span>
                </div>
              </div>
              <div style={{ display: "flex", gap: 14 }}>
                <BedGauge label="ICU Beds"    value={beds.icu}         max={beds.icuMax}     IcnCmp={IcnHeart} />
                <BedGauge label="General"     value={beds.general}     max={beds.generalMax} IcnCmp={IcnBed}   />
                <BedGauge label="Ventilators" value={beds.ventilators} max={beds.ventMax}    IcnCmp={IcnWind}  />
              </div>
            </div>

            {/* ALERTS */}
            <AlertBanner alerts={alerts} onDismiss={dismissAlert} />

            {/* TWO COLUMNS */}
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 20 }}>
              <div>
                <SectionTitle title="Incoming Requests" count={requests.length} dotColor="var(--danger)" chipBg="var(--danger-bg)" chipBdr="var(--danger-bdr)" />
                {requests.length === 0
                  ? <Empty line1="Monitoring for emergencies…" line2="System active" />
                  : requests.map(r => <RequestCard key={r.id} req={r} onAccept={acceptRequest} onReject={rejectRequest} />)
                }
              </div>
              <div>
                <SectionTitle title="Preparing for Arrival" count={acceptedPatients.length} dotColor="var(--green)" chipBg="var(--green-bg)" chipBdr="var(--green-bdr)" />
                {acceptedPatients.length === 0
                  ? <Empty line1="No patients accepted yet." line2="Awaiting acceptance" />
                  : acceptedPatients.map(r => <AcceptedCard key={r.id} req={r} />)
                }
              </div>
            </div>



          </div>
        </div>
      </div>
    </>
  );
}