<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>NexusLib v2.3</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600;700&display=swap');
*,*::before,*::after{margin:0;padding:0;box-sizing:border-box}
:root{--ui:'Outfit',sans-serif;--mono:'JetBrains Mono',monospace}

/* ══════════════ THEMES ══════════════ */
body{
  --a:#818cf8;--a2:#c4b5fd;
  --aglow:rgba(129,140,248,.3);--adim:rgba(129,140,248,.1);
  --bg:#06060a;
  --s1:rgba(12,12,18,.97);--s2:rgba(16,16,25,.94);--s3:rgba(20,20,32,.9);
  --b0:rgba(255,255,255,.04);--b1:rgba(255,255,255,.08);--b2:rgba(255,255,255,.15);
  --t1:rgba(238,236,255,.97);--t2:rgba(168,163,210,.72);--t3:rgba(98,93,143,.52);
  --ok:#4ade80;--warn:#fb923c;--err:#f87171;--inf:#60a5fa;
  --pill-off:rgba(255,255,255,.1);
}
body.ocean{
  --a:#22d3ee;--a2:#67e8f9;--aglow:rgba(34,211,238,.28);--adim:rgba(34,211,238,.09);
  --bg:#020c14;--s1:rgba(4,14,26,.97);--s2:rgba(6,20,36,.94);--s3:rgba(8,26,46,.92);
  --b0:rgba(34,211,238,.04);--b1:rgba(34,211,238,.09);--b2:rgba(34,211,238,.18);
  --t1:rgba(218,244,255,.97);--t2:rgba(128,194,230,.72);--t3:rgba(68,136,184,.5);
  --pill-off:rgba(34,211,238,.1);
}
body.crimson{
  --a:#fb7185;--a2:#fda4af;--aglow:rgba(251,113,133,.3);--adim:rgba(251,113,133,.09);
  --bg:#070306;--s1:rgba(15,3,7,.97);--s2:rgba(21,5,11,.94);--s3:rgba(27,7,15,.92);
  --b0:rgba(251,113,133,.04);--b1:rgba(251,113,133,.09);--b2:rgba(251,113,133,.18);
  --t1:rgba(255,232,236,.97);--t2:rgba(213,150,168,.72);--t3:rgba(143,80,103,.5);
  --pill-off:rgba(251,113,133,.1);
}
body.light{
  --a:#6366f1;--a2:#818cf8;--aglow:rgba(99,102,241,.22);--adim:rgba(99,102,241,.09);
  --bg:#e8e8f4;--s1:rgba(252,252,255,.97);--s2:rgba(246,246,253,.95);--s3:rgba(255,255,255,.93);
  --b0:rgba(0,0,0,.04);--b1:rgba(0,0,0,.07);--b2:rgba(99,102,241,.2);
  --t1:rgba(10,10,28,.95);--t2:rgba(55,53,108,.67);--t3:rgba(105,103,158,.47);
  --ok:#16a34a;--warn:#d97706;--err:#dc2626;--inf:#2563eb;
  --pill-off:rgba(0,0,0,.12);
}

/* ══════════════ PAGE ══════════════ */
body{
  font-family:var(--ui);background:var(--bg);
  min-height:100vh;display:flex;flex-direction:column;
  align-items:center;justify-content:center;
  gap:18px;padding:28px 20px;
  position:relative;overflow-x:hidden;transition:background .4s;
}
body::before,body::after{
  content:'';position:fixed;border-radius:50%;pointer-events:none;z-index:0;transition:background .4s;
}
body::before{
  width:580px;height:580px;top:-150px;left:-110px;
  background:radial-gradient(circle,var(--aglow) 0%,transparent 65%);
  animation:orb1 14s ease-in-out infinite alternate;
}
body::after{
  width:460px;height:460px;bottom:-120px;right:-80px;
  background:radial-gradient(circle,var(--aglow) 0%,transparent 65%);
  animation:orb2 18s ease-in-out infinite alternate;opacity:.5;
}
@keyframes orb1{from{transform:translate(0,0)scale(1)}to{transform:translate(48px,38px)scale(1.12)}}
@keyframes orb2{from{transform:translate(0,0)scale(1)}to{transform:translate(-34px,-26px)scale(1.1)}}

/* ══════════════ META BAR ══════════════ */
.meta{position:relative;z-index:10;display:flex;align-items:center;gap:8px;}
.meta-sep{width:1px;height:18px;background:var(--b1);}
.pill-group{
  display:flex;gap:2px;background:var(--s2);
  border:1px solid var(--b1);border-radius:9px;padding:3px;
}
.pg-btn{
  padding:4px 11px;border-radius:6px;border:none;background:transparent;
  font:600 11px/1 var(--ui);color:var(--t3);cursor:pointer;
  transition:all .18s;letter-spacing:.3px;
}
.pg-btn:hover{color:var(--t2);}
.pg-btn.on{
  background:var(--adim);color:var(--t1);
  border:1px solid var(--b2);
  box-shadow:0 0 12px var(--aglow);
}

/* ══════════════ GLOW SHELL ══════════════ */
.shell{position:relative;z-index:1;}
.shell::before{
  content:'';position:absolute;inset:-34px;
  background:radial-gradient(ellipse at center,var(--aglow) 0%,transparent 65%);
  border-radius:32px;pointer-events:none;
  animation:shellGlow 5s ease-in-out infinite alternate;transition:background .4s;
}
@property --ca{syntax:'<angle>';inherits:false;initial-value:0deg;}
.shell::after{
  content:'';position:absolute;inset:-1px;border-radius:17px;
  background:conic-gradient(from var(--ca,0deg),
    transparent 0%,var(--aglow) 15%,var(--a) 25%,var(--aglow) 35%,transparent 50%,
    transparent 62%,var(--aglow) 77%,transparent 92%);
  -webkit-mask:linear-gradient(#fff 0 0) content-box,linear-gradient(#fff 0 0);
  -webkit-mask-composite:xor;mask-composite:exclude;padding:1px;
  pointer-events:none;animation:ringRot 7s linear infinite;transition:background .4s;
}
@keyframes shellGlow{from{opacity:.55;transform:scale(.97)}to{opacity:1;transform:scale(1.04)}}
@keyframes ringRot{to{--ca:360deg}}

/* ══════════════ WINDOW ══════════════ */
.win{
  position:relative;z-index:2;
  width:640px;height:460px;
  border-radius:16px;border:1px solid var(--b1);
  background:
    url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='256' height='256'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.8' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='256' height='256' filter='url(%23n)' opacity='.03'/%3E%3C/svg%3E"),
    var(--s1);
  backdrop-filter:blur(52px) saturate(165%) brightness(1.02);
  -webkit-backdrop-filter:blur(52px) saturate(165%) brightness(1.02);
  display:flex;flex-direction:column;overflow:hidden;
  box-shadow:
    0 0 0 1px rgba(255,255,255,.04) inset,
    0 1px 0 var(--b1) inset,
    0 50px 100px rgba(0,0,0,.7),
    0 20px 40px rgba(0,0,0,.45);
  transition:height .35s cubic-bezier(.32,.72,0,1),opacity .3s,background .4s;
  animation:winIn .5s cubic-bezier(.22,1,.36,1) both;
}
@keyframes winIn{from{opacity:0;transform:scale(.93)translateY(12px)}to{opacity:1;transform:none}}
.win::after{
  content:'';position:absolute;top:0;left:8%;right:8%;height:1px;
  background:linear-gradient(90deg,transparent,var(--b2) 28%,var(--a) 50%,var(--b2) 72%,transparent);
  opacity:.65;pointer-events:none;z-index:5;transition:background .4s;
}
.win.gone{opacity:0;pointer-events:none;transform:scale(.95)!important;}
.win.mini{height:52px!important;}

/* ══════════════ TITLEBAR ══════════════ */
.tbar{
  position:relative;z-index:4;height:52px;flex-shrink:0;
  display:flex;align-items:center;padding:0 13px;gap:8px;
  background:var(--s2);border-bottom:1px solid var(--b0);
  cursor:grab;transition:background .4s;
}
.tbar:active{cursor:grabbing;}
.tbar::before{
  content:'';position:absolute;top:0;left:0;right:0;height:2px;
  background:linear-gradient(90deg,transparent,var(--a) 30%,var(--a2) 70%,transparent);
  opacity:.5;transition:background .4s;
}
.t-logo{
  width:24px;height:24px;border-radius:7px;flex-shrink:0;
  background:linear-gradient(135deg,var(--a),var(--a2));
  display:flex;align-items:center;justify-content:center;
  font:700 10px/1 var(--mono);color:#fff;
  box-shadow:0 2px 10px var(--aglow),0 0 0 1px rgba(255,255,255,.12) inset;
  transition:box-shadow .4s;
}
.t-name{font:700 13px/1 var(--ui);color:var(--t1);}
.t-ver{
  font:600 9px/1 var(--mono);color:var(--a);
  background:var(--adim);border:1px solid var(--b1);
  padding:2px 7px;border-radius:5px;letter-spacing:.5px;
  transition:color .4s,background .4s;
}
.t-gap{flex:1;}
.wcs{display:flex;gap:7px;align-items:center;}
.wc{width:13px;height:13px;border-radius:50%;border:none;cursor:pointer;flex-shrink:0;transition:filter .15s,transform .15s;}
.wc:hover{filter:brightness(1.3);transform:scale(1.12);}
.wc.cl{background:#ff5f57;box-shadow:0 0 8px rgba(255,95,87,.6);}
.wc.mn{background:#febc2e;box-shadow:0 0 8px rgba(254,188,46,.5);}

/* ══════════════ BODY LAYOUT ══════════════ */
.wbody{flex:1;display:flex;overflow:hidden;position:relative;z-index:2;}

/* ══════════════ SIDEBAR (main tabs) ══════════════ */
.sidebar{
  width:46px;flex-shrink:0;
  background:var(--s2);border-right:1px solid var(--b0);
  display:flex;flex-direction:column;align-items:center;
  padding:8px 0;gap:4px;transition:background .4s;
}

/* layout-top hides sidebar */
.win.layout-top .sidebar{display:none;}
.win.layout-top .top-strip{display:flex;}

.sb-btn{
  width:32px;height:32px;border-radius:9px;border:none;background:transparent;
  font-size:15px;cursor:pointer;
  display:flex;align-items:center;justify-content:center;
  color:var(--t3);transition:all .2s;position:relative;
}
.sb-btn:hover{background:var(--b0);color:var(--t2);transform:scale(1.06);}
.sb-btn.on{background:var(--adim);color:var(--a);}
.sb-btn.on::before{
  content:'';position:absolute;left:-1px;top:50%;transform:translateY(-50%);
  width:3px;height:17px;background:var(--a);border-radius:0 3px 3px 0;
  box-shadow:0 0 8px var(--aglow);transition:background .4s,box-shadow .4s;
}
.sb-btn > span{
  position:absolute;left:calc(100% + 10px);top:50%;
  transform:translateY(-50%) translateX(-4px);
  background:var(--s2);border:1px solid var(--b2);
  color:var(--t1);font:500 11px/1 var(--ui);
  padding:5px 9px;border-radius:7px;white-space:nowrap;
  pointer-events:none;opacity:0;
  transition:opacity .14s,transform .14s;
  backdrop-filter:blur(24px);box-shadow:0 4px 16px rgba(0,0,0,.4);z-index:999;
}
.sb-btn:hover > span{opacity:1;transform:translateY(-50%) translateX(0);}
.sb-div{width:22px;height:1px;background:var(--b1);flex-shrink:0;}
.sb-bot{flex:1;}

/* top strip (layout-top mode) */
.top-strip{
  display:none;
  align-items:center;gap:2px;flex:1;padding:0 4px;
}
.ttab{
  height:29px;padding:0 11px;border-radius:7px;border:none;
  background:transparent;font:500 12px/1 var(--ui);color:var(--t3);
  cursor:pointer;display:flex;align-items:center;gap:5px;
  transition:all .18s;white-space:nowrap;position:relative;
}
.ttab:hover{color:var(--t2);background:var(--b0);}
.ttab.on{color:var(--t1);font-weight:600;background:var(--adim);}
.ttab.on::after{
  content:'';position:absolute;bottom:-1px;left:18%;right:18%;height:2px;
  background:var(--a);border-radius:2px 2px 0 0;
  box-shadow:0 0 8px var(--aglow);
}

/* ══════════════ CONTENT COLUMN ══════════════ */
.content{flex:1;display:flex;flex-direction:column;overflow:hidden;}

/* ══════════════ SUB-TAB BAR ══════════════
   Sits at the top of the content area.
   Each main tab has its own set of sub-tabs.
   Only the active main tab's sub-bar is shown.
══════════════════════════════════════════ */
.sub-bar{
  height:36px;flex-shrink:0;
  border-bottom:1px solid var(--b0);
  background:var(--s2);
  display:none; /* hidden by default */
  align-items:center;
  padding:0 10px;gap:3px;
  transition:background .4s;
}
.sub-bar.active{display:flex;}

.stab{
  height:26px;padding:0 11px;
  border-radius:6px;border:none;
  background:transparent;
  font:500 11px/1 var(--ui);color:var(--t3);
  cursor:pointer;
  transition:all .16s;
  white-space:nowrap;position:relative;
}
.stab:hover{color:var(--t2);background:var(--b0);}
.stab.on{
  color:var(--t1);font-weight:600;
  background:var(--adim);
  border:1px solid var(--b1);
}
/* small accent dot under active sub-tab */
.stab.on::after{
  content:'';position:absolute;
  bottom:3px;left:50%;transform:translateX(-50%);
  width:14px;height:2px;
  background:var(--a);border-radius:2px;
  box-shadow:0 0 6px var(--aglow);
}

/* ══════════════ PAGE AREA ══════════════ */
.pages{flex:1;position:relative;overflow:hidden;}
.page{
  position:absolute;inset:0;
  overflow-y:auto;overflow-x:hidden;
  padding:10px 11px 12px;
  display:flex;flex-direction:column;gap:5px;
  opacity:0;transform:translateX(8px);
  pointer-events:none;
  scrollbar-width:thin;scrollbar-color:var(--b2) transparent;
}
.page::-webkit-scrollbar{width:3px;}
.page::-webkit-scrollbar-thumb{background:var(--b2);border-radius:2px;}
.page.on{
  opacity:1;transform:none;pointer-events:all;
  transition:opacity .22s cubic-bezier(.25,.46,.45,.94),
             transform .22s cubic-bezier(.25,.46,.45,.94);
}
.page.out{
  opacity:0;transform:translateX(-8px);pointer-events:none;
  transition:opacity .15s,transform .15s;
}

/* ══════════════ STATUS BAR ══════════════ */
.sbar{
  position:relative;z-index:4;height:26px;flex-shrink:0;
  border-top:1px solid var(--b0);background:var(--s2);
  display:flex;align-items:center;padding:0 12px;gap:8px;
  transition:background .4s;
}
.sbar-dot{
  width:6px;height:6px;border-radius:50%;background:var(--ok);
  box-shadow:0 0 6px var(--ok);flex-shrink:0;
  animation:dotP 2.5s ease-in-out infinite;
}
@keyframes dotP{0%,100%{box-shadow:0 0 4px var(--ok);}50%{box-shadow:0 0 14px var(--ok);}}
.sbar-t{font:500 10px/1 var(--mono);color:var(--t3);letter-spacing:.5px;}
.sbar-g{flex:1;}
.sbar-tag{
  font:600 10px/1 var(--mono);color:var(--a);
  background:var(--adim);border:1px solid var(--b1);
  padding:2px 7px;border-radius:5px;
  transition:color .4s,background .4s;
}

/* ══════════════ CARD ══════════════ */
.card{
  background:var(--s3);border-radius:11px;border:1px solid var(--b0);
  position:relative;overflow:visible;flex-shrink:0;
  transition:background .15s,border-color .2s,box-shadow .2s,transform .12s;
}
.card::before{
  content:'';position:absolute;inset:0;border-radius:inherit;
  background:linear-gradient(140deg,rgba(255,255,255,.025) 0%,transparent 55%);
  pointer-events:none;z-index:0;
}
.card:hover{border-color:var(--b2);box-shadow:0 2px 18px rgba(0,0,0,.22);}
.card.flash{animation:cFlash .3s ease-out;}
@keyframes cFlash{
  0%{box-shadow:0 0 0 0 var(--aglow);}
  45%{box-shadow:0 0 0 5px var(--aglow);}
  100%{box-shadow:0 0 0 0 transparent;}
}

/* 2-col */
.r2{display:flex;gap:5px;flex-shrink:0;}
.r2>.card{flex:1;}

/* ══════════════ BUTTON ══════════════ */
.c-btn{
  display:flex;align-items:center;padding:0 13px;height:46px;
  gap:10px;cursor:pointer;position:relative;z-index:1;
}
.c-btn.sm{height:34px;}
.c-ico{
  width:26px;height:26px;border-radius:8px;
  background:var(--adim);border:1px solid var(--b1);
  display:flex;align-items:center;justify-content:center;
  font-size:12px;flex-shrink:0;
  transition:transform .2s,box-shadow .2s;
}
.card:hover .c-ico{transform:scale(1.08);box-shadow:0 2px 10px var(--aglow);}
.c-txt{flex:1;}
.c-lbl{display:block;font:600 13px/1 var(--ui);color:var(--t1);margin-bottom:3px;}
.c-btn.sm .c-lbl,.c-btn.sm.no-dsc .c-lbl{margin-bottom:0;}
.c-dsc{font:400 11px/1 var(--ui);color:var(--t3);}
.c-arr{
  width:22px;height:22px;border-radius:6px;background:var(--b0);
  display:flex;align-items:center;justify-content:center;
  color:var(--t3);font-size:14px;font-weight:600;
  transition:background .2s,color .2s,transform .2s;
}
.card:hover .c-arr{background:var(--a);color:#fff;transform:translateX(2px);}

/* ══════════════ TOGGLE ══════════════ */
.c-tog{
  display:flex;align-items:center;padding:0 13px;height:46px;
  gap:10px;cursor:pointer;position:relative;z-index:1;
}
.c-tog.sm{height:34px;}
.c-tog-txt{flex:1;}
.c-tog-lbl{display:block;font:600 13px/1 var(--ui);color:var(--t1);margin-bottom:3px;}
.c-tog.sm .c-tog-lbl{margin-bottom:0;}
.c-tog-dsc{font:400 11px/1 var(--ui);color:var(--t3);}
.pill{
  width:38px;height:21px;border-radius:11px;
  background:var(--pill-off);border:1px solid var(--b1);
  position:relative;flex-shrink:0;cursor:pointer;
  transition:background .28s cubic-bezier(.25,.46,.45,.94),border-color .28s,box-shadow .28s;
}
.pill.on{background:var(--a);border-color:var(--a);box-shadow:0 0 12px var(--aglow);}
.pill-k{
  position:absolute;top:3px;left:3px;
  width:13px;height:13px;border-radius:50%;
  background:rgba(255,255,255,.45);
  box-shadow:0 1px 4px rgba(0,0,0,.35);
  transition:left .28s cubic-bezier(.34,1.56,.64,1),background .28s,width .12s;
}
.pill.on .pill-k{left:20px;background:#fff;}
.pill:active .pill-k{width:17px;}
.pill.on:active .pill-k{left:16px;width:17px;}

/* ══════════════ SLIDER ══════════════ */
.c-slide{padding:11px 13px 13px;position:relative;z-index:1;}
.sl-top{display:flex;align-items:baseline;justify-content:space-between;margin-bottom:10px;}
.sl-lbl{font:600 13px/1 var(--ui);color:var(--t1);}
.sl-val{
  font:600 11px/1 var(--mono);color:var(--a);
  background:var(--adim);border:1px solid var(--b1);
  padding:2px 8px;border-radius:5px;min-width:36px;text-align:center;
}
.sl-track{height:4px;background:var(--b1);border-radius:2px;position:relative;cursor:pointer;}
.sl-fill{
  position:absolute;top:0;left:0;height:100%;
  background:linear-gradient(90deg,var(--a),var(--a2));
  border-radius:2px;pointer-events:none;box-shadow:0 0 6px var(--aglow);
}
.sl-thumb{
  position:absolute;top:50%;transform:translate(-50%,-50%);
  width:14px;height:14px;border-radius:50%;
  background:var(--t1);border:2.5px solid var(--a);
  box-shadow:0 0 8px var(--aglow),0 2px 4px rgba(0,0,0,.4);
  cursor:grab;z-index:2;transition:transform .1s,box-shadow .15s;
}
.sl-thumb:hover{transform:translate(-50%,-50%) scale(1.2);}
.sl-thumb:active{cursor:grabbing;transform:translate(-50%,-50%) scale(1.25);}

/* ══════════════ TEXTBOX ══════════════ */
.c-tb{padding:10px 13px;display:flex;flex-direction:column;gap:6px;position:relative;z-index:1;}
.tb-lbl{font:600 9px/1 var(--mono);color:var(--t3);letter-spacing:1.5px;text-transform:uppercase;}
.tb-wrap{
  height:30px;background:rgba(0,0,0,.18);
  border-radius:8px;border:1px solid var(--b1);
  display:flex;align-items:center;padding:0 10px;gap:7px;
  transition:border-color .2s,box-shadow .2s;
}
.tb-wrap:focus-within{border-color:var(--a);box-shadow:0 0 0 3px var(--adim),0 0 10px var(--aglow);}
.tb-pre{font:500 11px/1 var(--mono);color:var(--t3);flex-shrink:0;}
.tb-in{flex:1;background:none;border:none;outline:none;font:400 12px/1 var(--mono);color:var(--t1);caret-color:var(--a);}
.tb-in::placeholder{color:var(--t3);}

/* ══════════════ DROPDOWN ══════════════ */
.c-dd{padding:10px 13px;display:flex;flex-direction:column;gap:6px;position:relative;z-index:1;}
.dd-lbl{font:600 9px/1 var(--mono);color:var(--t3);letter-spacing:1.5px;text-transform:uppercase;}
.dd-head{
  height:30px;background:rgba(0,0,0,.18);
  border-radius:8px;border:1px solid var(--b1);
  display:flex;align-items:center;padding:0 10px;gap:6px;
  cursor:pointer;transition:border-color .2s,box-shadow .2s;user-select:none;
}
.dd-head:hover{border-color:var(--b2);}
.dd-head.open{border-color:var(--a);box-shadow:0 0 0 3px var(--adim);}
.dd-cur{flex:1;font:400 12px/1 var(--ui);color:var(--t1);}
.dd-ic{font-size:10px;color:var(--t3);transition:transform .2s;}
.dd-head.open .dd-ic{transform:rotate(180deg);}
/* floating panel */
.dd-float{
  position:absolute;
  background:var(--s2);
  border:1px solid var(--a);border-radius:9px;
  overflow:hidden;z-index:9999;
  box-shadow:0 14px 36px rgba(0,0,0,.6),0 4px 12px rgba(0,0,0,.35);
  backdrop-filter:blur(40px);
  display:none;max-height:160px;overflow-y:auto;
  scrollbar-width:thin;scrollbar-color:var(--b2) transparent;
}
.dd-float.open{display:block;animation:ddIn .17s cubic-bezier(.25,.46,.45,.94);}
@keyframes ddIn{from{opacity:0;transform:translateY(-5px)}to{opacity:1;transform:none}}
.dd-opt{
  height:30px;display:flex;align-items:center;
  padding:0 11px;font:400 12px/1 var(--ui);color:var(--t2);
  cursor:pointer;transition:background .1s,color .1s;
  border-bottom:1px solid var(--b0);
}
.dd-opt:last-child{border-bottom:none;}
.dd-opt:hover{background:var(--adim);color:var(--t1);}
.dd-opt.sel{color:var(--a);font-weight:600;}

/* ══════════════ KEYBIND ══════════════ */
.c-kb{display:flex;align-items:center;padding:0 13px;height:34px;gap:10px;position:relative;z-index:1;}
.kb-lbl{flex:1;font:600 13px/1 var(--ui);color:var(--t1);}
.kb-key{
  font:600 11px/1 var(--mono);color:var(--a);
  background:var(--adim);border:1px solid var(--b2);
  padding:4px 11px;border-radius:6px;cursor:pointer;
  min-width:58px;text-align:center;
  transition:all .2s;box-shadow:0 2px 0 var(--b1);
}
.kb-key:hover{border-color:var(--a);box-shadow:0 0 10px var(--aglow),0 2px 0 var(--b1);}
.kb-key.hot{color:var(--warn);border-color:var(--warn);box-shadow:0 0 12px rgba(251,146,60,.4);animation:kbP .6s ease-in-out infinite alternate;}
@keyframes kbP{from{opacity:.7}to{opacity:1}}

/* ══════════════ COLOR PICKER ══════════════ */
.c-cp{position:relative;z-index:1;}
.cp-row{display:flex;align-items:center;padding:0 13px;height:36px;gap:10px;cursor:pointer;}
.cp-lbl{flex:1;font:600 13px/1 var(--ui);color:var(--t1);}
.cp-sw{width:40px;height:18px;border-radius:5px;border:1px solid var(--b1);box-shadow:0 2px 8px rgba(0,0,0,.3);transition:transform .15s;flex-shrink:0;}
.cp-row:hover .cp-sw{transform:scale(1.07);}
.cp-body{border-top:1px solid var(--b0);padding:10px 13px;display:none;flex-direction:column;gap:7px;}
.cp-body.open{display:flex;}
.hsv{display:flex;align-items:center;gap:8px;}
.hsv-l{font:600 8px/1 var(--mono);color:var(--t3);width:10px;text-align:center;letter-spacing:1px;text-transform:uppercase;}
.hsv-t{flex:1;height:5px;border-radius:3px;background:var(--b1);position:relative;cursor:pointer;}
.hsv-f{height:100%;border-radius:3px;position:absolute;left:0;top:0;}
.hsv-k{position:absolute;width:11px;height:11px;border-radius:50%;background:#fff;top:50%;transform:translate(-50%,-50%);box-shadow:0 1px 4px rgba(0,0,0,.5),0 0 0 1.5px rgba(255,255,255,.6);cursor:grab;}

/* ══════════════ PARAGRAPH ══════════════ */
.c-para{padding:12px 13px;display:flex;flex-direction:column;gap:5px;position:relative;z-index:1;}
.para-t{font:700 13px/1 var(--ui);color:var(--t1);}
.para-b{font:400 12px/1.6 var(--ui);color:var(--t2);}

/* ══════════════ NOTIFICATIONS ══════════════ */
#nc{
  position:fixed;top:18px;right:18px;
  display:flex;flex-direction:column;gap:8px;
  width:298px;pointer-events:none;z-index:99999;
}
.notif{
  pointer-events:all;border-radius:12px;overflow:hidden;position:relative;
  transform:translateX(115%);opacity:0;
  transition:transform .38s cubic-bezier(.34,1.2,.64,1),opacity .28s;
  box-shadow:0 10px 36px rgba(0,0,0,.55),0 2px 8px rgba(0,0,0,.3);
}
.notif.in{transform:none;opacity:1;}
.notif.out{transform:translateX(115%);opacity:0;transition:transform .28s cubic-bezier(.6,0,.74,.05),opacity .2s;}
.n-bg{background:var(--s2);backdrop-filter:blur(40px);border:1px solid var(--b1);border-radius:12px;overflow:hidden;}
.n-top{height:3px;}
.n-row{display:flex;align-items:flex-start;padding:11px 14px 11px 11px;gap:10px;}
.n-icon{width:30px;height:30px;border-radius:8px;display:flex;align-items:center;justify-content:center;font:700 12px/1 var(--mono);flex-shrink:0;}
.n-body{flex:1;}
.n-ttl{font:700 13px/1 var(--ui);color:var(--t1);margin-bottom:3px;}
.n-msg{font:400 11px/1.45 var(--ui);color:var(--t2);}
.n-prog{height:2px;background:var(--b0);}
.n-fill{height:100%;transition:width linear;}
.n-x{position:absolute;top:9px;right:9px;width:18px;height:18px;border:none;background:var(--b1);border-radius:50%;cursor:pointer;color:var(--t3);font-size:12px;display:flex;align-items:center;justify-content:center;transition:background .15s,color .15s;line-height:1;}
.n-x:hover{background:var(--err);color:#fff;}

/* resize */
.rsz{position:absolute;bottom:4px;right:4px;width:12px;height:12px;cursor:nwse-resize;z-index:10;opacity:.2;transition:opacity .2s;}
.rsz:hover{opacity:.6;}
.rsz::before,.rsz::after{content:'';position:absolute;background:var(--t3);border-radius:1px;}
.rsz::before{width:8px;height:1.5px;bottom:4px;right:1px;transform:rotate(-45deg);}
.rsz::after{width:5px;height:1.5px;bottom:1px;right:1px;transform:rotate(-45deg);}
</style>
</head>
<body>

<!-- META -->
<div class="meta">
  <div class="pill-group">
    <button class="pg-btn on" onclick="setTheme('',this)">Dark</button>
    <button class="pg-btn" onclick="setTheme('ocean',this)">Ocean</button>
    <button class="pg-btn" onclick="setTheme('crimson',this)">Crimson</button>
    <button class="pg-btn" onclick="setTheme('light',this)">Light</button>
  </div>
  <div class="meta-sep"></div>
  <div class="pill-group">
    <button class="pg-btn on" onclick="setLayout('left',this)">⊟ Sidebar</button>
    <button class="pg-btn" onclick="setLayout('top',this)">⊤ Top</button>
  </div>
</div>

<!-- SHELL -->
<div class="shell">
<div class="win layout-left" id="win">

  <!-- TITLEBAR -->
  <div class="tbar" id="tbar">
    <div class="t-logo">N</div>
    <span class="t-name">NexusLib</span>
    <span class="t-ver">v2.3</span>

    <!-- top strip (layout-top only) -->
    <div class="top-strip" id="top-strip">
      <button class="ttab on" data-main="combat" onclick="gotoMain('combat',this)">⚔ Combat</button>
      <button class="ttab" data-main="visuals" onclick="gotoMain('visuals',this)">◈ Visuals</button>
      <button class="ttab" data-main="world" onclick="gotoMain('world',this)">⊕ World</button>
      <button class="ttab" data-main="config" onclick="gotoMain('config',this)">⚙ Config</button>
    </div>

    <div class="t-gap"></div>
    <div class="wcs">
      <button class="wc mn" onclick="toggleMini()"></button>
      <button class="wc cl" onclick="closeWin()"></button>
    </div>
  </div>

  <!-- BODY -->
  <div class="wbody">

    <!-- SIDEBAR -->
    <div class="sidebar" id="sidebar">
      <button class="sb-btn on" data-main="combat" onclick="gotoMain('combat',this)">⚔<span>Combat</span></button>
      <button class="sb-btn" data-main="visuals" onclick="gotoMain('visuals',this)">◈<span>Visuals</span></button>
      <button class="sb-btn" data-main="world" onclick="gotoMain('world',this)">⊕<span>World</span></button>
      <div class="sb-div"></div>
      <button class="sb-btn" data-main="config" onclick="gotoMain('config',this)">⚙<span>Config</span></button>
      <div class="sb-bot"></div>
      <button class="sb-btn" onclick="notify('Saved','Config saved.','ok')">💾<span>Save</span></button>
    </div>

    <!-- CONTENT COLUMN -->
    <div class="content">

      <!-- SUB-TAB BARS (one per main tab, only active one shows) -->

      <!-- Combat sub-tabs -->
      <div class="sub-bar active" id="sub-combat">
        <button class="stab on" data-page="combat-main" onclick="gotoSub('combat','combat-main',this)">General</button>
        <button class="stab" data-page="combat-aim" onclick="gotoSub('combat','combat-aim',this)">Aimbot</button>
        <button class="stab" data-page="combat-misc" onclick="gotoSub('combat','combat-misc',this)">Misc</button>
      </div>

      <!-- Visuals sub-tabs -->
      <div class="sub-bar" id="sub-visuals">
        <button class="stab on" data-page="visuals-esp" onclick="gotoSub('visuals','visuals-esp',this)">ESP</button>
        <button class="stab" data-page="visuals-colors" onclick="gotoSub('visuals','visuals-colors',this)">Colors</button>
        <button class="stab" data-page="visuals-chams" onclick="gotoSub('visuals','visuals-chams',this)">Chams</button>
      </div>

      <!-- World sub-tabs -->
      <div class="sub-bar" id="sub-world">
        <button class="stab on" data-page="world-move" onclick="gotoSub('world','world-move',this)">Movement</button>
        <button class="stab" data-page="world-tp" onclick="gotoSub('world','world-tp',this)">Teleport</button>
      </div>

      <!-- Config sub-tabs -->
      <div class="sub-bar" id="sub-config">
        <button class="stab on" data-page="config-ui" onclick="gotoSub('config','config-ui',this)">Interface</button>
        <button class="stab" data-page="config-save" onclick="gotoSub('config','config-save',this)">Profiles</button>
        <button class="stab" data-page="config-about" onclick="gotoSub('config','config-about',this)">About</button>
      </div>

      <!-- PAGE AREA -->
      <div class="pages">

        <!-- ── COMBAT › GENERAL ── -->
        <div class="page on" id="p-combat-main" data-main="combat">
          <div class="card c-tog" onclick="tog(this)">
            <div class="c-ico">🛡</div>
            <div class="c-tog-txt">
              <span class="c-tog-lbl">God Mode</span>
              <span class="c-tog-dsc">Prevents all incoming damage</span>
            </div>
            <div class="pill on"><div class="pill-k"></div></div>
          </div>
          <div class="card c-tog sm" onclick="tog(this)">
            <div class="c-ico">∞</div>
            <div class="c-tog-txt"><span class="c-tog-lbl">Infinite Stamina</span></div>
            <div class="pill on"><div class="pill-k"></div></div>
          </div>
          <div class="card c-tog sm" onclick="tog(this)">
            <div class="c-ico">🔮</div>
            <div class="c-tog-txt"><span class="c-tog-lbl">Anti-Knockback</span></div>
            <div class="pill"><div class="pill-k"></div></div>
          </div>
          <div class="card c-tog sm" onclick="tog(this)">
            <div class="c-ico">⚡</div>
            <div class="c-tog-txt"><span class="c-tog-lbl">Auto Attack</span></div>
            <div class="pill"><div class="pill-k"></div></div>
          </div>
          <div class="r2">
            <div class="card c-btn sm" onclick="flash(this)">
              <div class="c-ico">🎯</div>
              <div class="c-txt"><span class="c-lbl">Kill Aura</span></div>
              <div class="c-arr">›</div>
            </div>
            <div class="card c-btn sm" onclick="flash(this)">
              <div class="c-ico">💀</div>
              <div class="c-txt"><span class="c-lbl">One Hit Kill</span></div>
              <div class="c-arr">›</div>
            </div>
          </div>
          <div class="card">
            <div class="c-kb"><span class="kb-lbl">Kill Aura Key</span><div class="kb-key" onclick="listenKey(this)">E</div></div>
          </div>
        </div>

        <!-- ── COMBAT › AIMBOT ── -->
        <div class="page" id="p-combat-aim" data-main="combat">
          <div class="card c-tog sm" onclick="tog(this)">
            <div class="c-ico">◎</div>
            <div class="c-tog-txt"><span class="c-tog-lbl">Silent Aim</span></div>
            <div class="pill on"><div class="pill-k"></div></div>
          </div>
          <div class="card c-tog sm" onclick="tog(this)">
            <div class="c-ico">👁</div>
            <div class="c-tog-txt"><span class="c-tog-lbl">Draw FOV Circle</span></div>
            <div class="pill on"><div class="pill-k"></div></div>
          </div>
          <div class="card" style="overflow:visible;">
            <div class="c-dd">
              <span class="dd-lbl">Target Mode</span>
              <div class="dd-head" onclick="ddToggle(this)" data-opts='["Nearest","Lowest HP","Random","Crosshair"]'>
                <span class="dd-cur">Nearest</span><span class="dd-ic">▾</span>
              </div>
            </div>
          </div>
          <div class="card" style="overflow:visible;">
            <div class="c-dd">
              <span class="dd-lbl">Hitbox</span>
              <div class="dd-head" onclick="ddToggle(this)" data-opts='["Head","Torso","Nearest Part","Random"]'>
                <span class="dd-cur">Head</span><span class="dd-ic">▾</span>
              </div>
            </div>
          </div>
          <div class="card">
            <div class="c-slide" data-min="0" data-max="360" data-val="90" data-step="5">
              <div class="sl-top"><span class="sl-lbl">FOV Size</span><span class="sl-val">90</span></div>
              <div class="sl-track"><div class="sl-fill"></div><div class="sl-thumb"></div></div>
            </div>
          </div>
          <div class="card">
            <div class="c-slide" data-min="1" data-max="20" data-val="5" data-step="1">
              <div class="sl-top"><span class="sl-lbl">Smoothness</span><span class="sl-val">5</span></div>
              <div class="sl-track"><div class="sl-fill"></div><div class="sl-thumb"></div></div>
            </div>
          </div>
          <div class="card">
            <div class="c-kb"><span class="kb-lbl">Aimbot Hold Key</span><div class="kb-key" onclick="listenKey(this)">Q</div></div>
          </div>
        </div>

        <!-- ── COMBAT › MISC ── -->
        <div class="page" id="p-combat-misc" data-main="combat">
          <div class="card c-tog sm" onclick="tog(this)">
            <div class="c-ico">🏃</div>
            <div class="c-tog-txt"><span class="c-tog-lbl">Auto Dodge</span></div>
            <div class="pill"><div class="pill-k"></div></div>
          </div>
          <div class="card c-tog sm" onclick="tog(this)">
            <div class="c-ico">🧲</div>
            <div class="c-tog-txt"><span class="c-tog-lbl">Attract Players</span></div>
            <div class="pill"><div class="pill-k"></div></div>
          </div>
          <div class="card c-tog sm" onclick="tog(this)">
            <div class="c-ico">⏱</div>
            <div class="c-tog-txt"><span class="c-tog-lbl">Fast Cooldowns</span></div>
            <div class="pill on"><div class="pill-k"></div></div>
          </div>
          <div class="card">
            <div class="c-slide" data-min="1" data-max="50" data-val="10" data-step="1">
              <div class="sl-top"><span class="sl-lbl">Attack Range</span><span class="sl-val">10</span></div>
              <div class="sl-track"><div class="sl-fill"></div><div class="sl-thumb"></div></div>
            </div>
          </div>
          <div class="card">
            <div class="c-slide" data-min="1" data-max="20" data-val="5" data-step="1">
              <div class="sl-top"><span class="sl-lbl">Hit Delay (ms)</span><span class="sl-val">5</span></div>
              <div class="sl-track"><div class="sl-fill"></div><div class="sl-thumb"></div></div>
            </div>
          </div>
        </div>

        <!-- ── VISUALS › ESP ── -->
        <div class="page" id="p-visuals-esp" data-main="visuals">
          <div class="r2">
            <div class="card c-tog sm" onclick="tog(this)">
              <div class="c-ico">⬜</div>
              <div class="c-tog-txt"><span class="c-tog-lbl">ESP Boxes</span></div>
              <div class="pill on"><div class="pill-k"></div></div>
            </div>
            <div class="card c-tog sm" onclick="tog(this)">
              <div class="c-ico">╱</div>
              <div class="c-tog-txt"><span class="c-tog-lbl">Tracers</span></div>
              <div class="pill"><div class="pill-k"></div></div>
            </div>
          </div>
          <div class="r2">
            <div class="card c-tog sm" onclick="tog(this)">
              <div class="c-ico">◎</div>
              <div class="c-tog-txt"><span class="c-tog-lbl">Nametags</span></div>
              <div class="pill on"><div class="pill-k"></div></div>
            </div>
            <div class="card c-tog sm" onclick="tog(this)">
              <div class="c-ico">❤</div>
              <div class="c-tog-txt"><span class="c-tog-lbl">Health Bar</span></div>
              <div class="pill on"><div class="pill-k"></div></div>
            </div>
          </div>
          <div class="r2">
            <div class="card c-tog sm" onclick="tog(this)">
              <div class="c-ico">💨</div>
              <div class="c-tog-txt"><span class="c-tog-lbl">Distance</span></div>
              <div class="pill"><div class="pill-k"></div></div>
            </div>
            <div class="card c-tog sm" onclick="tog(this)">
              <div class="c-ico">🎯</div>
              <div class="c-tog-txt"><span class="c-tog-lbl">Highlight Target</span></div>
              <div class="pill on"><div class="pill-k"></div></div>
            </div>
          </div>
          <div class="card">
            <div class="c-slide" data-min="0.5" data-max="5" data-val="1.5" data-step="0.5">
              <div class="sl-top"><span class="sl-lbl">ESP Thickness</span><span class="sl-val">1.5</span></div>
              <div class="sl-track"><div class="sl-fill"></div><div class="sl-thumb"></div></div>
            </div>
          </div>
          <div class="card">
            <div class="c-slide" data-min="10" data-max="2000" data-val="500" data-step="10">
              <div class="sl-top"><span class="sl-lbl">Max Distance</span><span class="sl-val">500</span></div>
              <div class="sl-track"><div class="sl-fill"></div><div class="sl-thumb"></div></div>
            </div>
          </div>
        </div>

        <!-- ── VISUALS › COLORS ── -->
        <div class="page" id="p-visuals-colors" data-main="visuals">
          <div class="card c-cp" id="cp-enemy">
            <div class="cp-row" onclick="cpToggle('cp-enemy')">
              <div class="c-ico" style="background:rgba(248,113,113,.15);">●</div>
              <span class="cp-lbl">Enemy ESP</span>
              <div class="cp-sw" style="background:#f87171;"></div>
            </div>
            <div class="cp-body" id="cpb-enemy">
              <div class="hsv"><span class="hsv-l">H</span>
                <div class="hsv-t" style="background:linear-gradient(90deg,#f00,#ff0,#0f0,#0ff,#00f,#f0f,#f00)">
                  <div class="hsv-f" style="background:transparent;width:0%"></div><div class="hsv-k" style="left:2%"></div>
                </div>
              </div>
              <div class="hsv"><span class="hsv-l">S</span>
                <div class="hsv-t"><div class="hsv-f" style="width:56%;background:linear-gradient(90deg,#fff,#f87171)"></div><div class="hsv-k" style="left:56%"></div></div>
              </div>
              <div class="hsv"><span class="hsv-l">V</span>
                <div class="hsv-t"><div class="hsv-f" style="width:97%;background:linear-gradient(90deg,#000,#f87171)"></div><div class="hsv-k" style="left:97%"></div></div>
              </div>
            </div>
          </div>
          <div class="card c-cp" id="cp-ally">
            <div class="cp-row" onclick="cpToggle('cp-ally')">
              <div class="c-ico" style="background:rgba(74,222,128,.15);">●</div>
              <span class="cp-lbl">Ally ESP</span>
              <div class="cp-sw" style="background:#4ade80;"></div>
            </div>
          </div>
          <div class="card c-cp" id="cp-tracer">
            <div class="cp-row" onclick="cpToggle('cp-tracer')">
              <div class="c-ico" style="background:rgba(96,165,250,.15);">●</div>
              <span class="cp-lbl">Tracer Color</span>
              <div class="cp-sw" style="background:#60a5fa;"></div>
            </div>
          </div>
          <div class="card c-cp" id="cp-target">
            <div class="cp-row" onclick="cpToggle('cp-target')">
              <div class="c-ico" style="background:rgba(251,191,36,.15);">●</div>
              <span class="cp-lbl">Target Highlight</span>
              <div class="cp-sw" style="background:#fbbf24;"></div>
            </div>
          </div>
        </div>

        <!-- ── VISUALS › CHAMS ── -->
        <div class="page" id="p-visuals-chams" data-main="visuals">
          <div class="card c-tog sm" onclick="tog(this)">
            <div class="c-ico">🎨</div>
            <div class="c-tog-txt"><span class="c-tog-lbl">Enable Chams</span></div>
            <div class="pill"><div class="pill-k"></div></div>
          </div>
          <div class="card" style="overflow:visible;">
            <div class="c-dd">
              <span class="dd-lbl">Chams Style</span>
              <div class="dd-head" onclick="ddToggle(this)" data-opts='["Flat","Shaded","Wireframe","Glass","Neon"]'>
                <span class="dd-cur">Flat</span><span class="dd-ic">▾</span>
              </div>
            </div>
          </div>
          <div class="card c-cp" id="cp-chams">
            <div class="cp-row" onclick="cpToggle('cp-chams')">
              <div class="c-ico" style="background:rgba(196,181,253,.15);">●</div>
              <span class="cp-lbl">Chams Color</span>
              <div class="cp-sw" style="background:#c4b5fd;"></div>
            </div>
          </div>
          <div class="card">
            <div class="c-slide" data-min="0" data-max="100" data-val="70" data-step="5">
              <div class="sl-top"><span class="sl-lbl">Opacity</span><span class="sl-val">70</span></div>
              <div class="sl-track"><div class="sl-fill"></div><div class="sl-thumb"></div></div>
            </div>
          </div>
        </div>

        <!-- ── WORLD › MOVEMENT ── -->
        <div class="page" id="p-world-move" data-main="world">
          <div class="card">
            <div class="c-slide" data-min="16" data-max="300" data-val="16" data-step="1">
              <div class="sl-top"><span class="sl-lbl">Walk Speed</span><span class="sl-val">16</span></div>
              <div class="sl-track"><div class="sl-fill"></div><div class="sl-thumb"></div></div>
            </div>
          </div>
          <div class="card">
            <div class="c-slide" data-min="0" data-max="300" data-val="50" data-step="1">
              <div class="sl-top"><span class="sl-lbl">Jump Power</span><span class="sl-val">50</span></div>
              <div class="sl-track"><div class="sl-fill"></div><div class="sl-thumb"></div></div>
            </div>
          </div>
          <div class="card">
            <div class="c-slide" data-min="10" data-max="200" data-val="40" data-step="1">
              <div class="sl-top"><span class="sl-lbl">Fly Speed</span><span class="sl-val">40</span></div>
              <div class="sl-track"><div class="sl-fill"></div><div class="sl-thumb"></div></div>
            </div>
          </div>
          <div class="r2">
            <div class="card c-tog sm" onclick="tog(this)">
              <div class="c-ico">👻</div>
              <div class="c-tog-txt"><span class="c-tog-lbl">NoClip</span></div>
              <div class="pill"><div class="pill-k"></div></div>
            </div>
            <div class="card c-tog sm" onclick="tog(this)">
              <div class="c-ico">🕊</div>
              <div class="c-tog-txt"><span class="c-tog-lbl">Fly</span></div>
              <div class="pill"><div class="pill-k"></div></div>
            </div>
          </div>
          <div class="r2">
            <div class="card c-tog sm" onclick="tog(this)">
              <div class="c-ico">⬆</div>
              <div class="c-tog-txt"><span class="c-tog-lbl">Inf. Jump</span></div>
              <div class="pill on"><div class="pill-k"></div></div>
            </div>
            <div class="card c-tog sm" onclick="tog(this)">
              <div class="c-ico">🌊</div>
              <div class="c-tog-txt"><span class="c-tog-lbl">Swim Fast</span></div>
              <div class="pill"><div class="pill-k"></div></div>
            </div>
          </div>
        </div>

        <!-- ── WORLD › TELEPORT ── -->
        <div class="page" id="p-world-tp" data-main="world">
          <div class="r2">
            <div class="card c-btn sm" onclick="flash(this);notify('Teleport','Moved to Spawn.','inf')">
              <div class="c-txt"><span class="c-lbl">→ Spawn</span></div>
            </div>
            <div class="card c-btn sm" onclick="flash(this);notify('Teleport','Moved to cursor.','inf')">
              <div class="c-txt"><span class="c-lbl">→ Cursor</span></div>
            </div>
          </div>
          <div class="r2">
            <div class="card c-btn sm" onclick="flash(this)">
              <div class="c-txt"><span class="c-lbl">→ Player</span></div>
            </div>
            <div class="card c-btn sm" onclick="flash(this)">
              <div class="c-txt"><span class="c-lbl">→ Waypoint</span></div>
            </div>
          </div>
          <div class="card">
            <div class="c-tb">
              <span class="tb-lbl">Custom Coords</span>
              <div class="tb-wrap">
                <span class="tb-pre">xyz</span>
                <input class="tb-in" type="text" placeholder="0, 0, 0">
              </div>
            </div>
          </div>
          <div class="card" style="overflow:visible;">
            <div class="c-dd">
              <span class="dd-lbl">Target Player</span>
              <div class="dd-head" onclick="ddToggle(this)" data-opts='["Select player...","Player1","xXProXx","Noob123","Guest"]'>
                <span class="dd-cur">Select player...</span><span class="dd-ic">▾</span>
              </div>
            </div>
          </div>
          <div class="card c-tog sm" onclick="tog(this)">
            <div class="c-ico">🔁</div>
            <div class="c-tog-txt"><span class="c-tog-lbl">Loop Teleport</span></div>
            <div class="pill"><div class="pill-k"></div></div>
          </div>
          <div class="card">
            <div class="c-kb"><span class="kb-lbl">Teleport Key</span><div class="kb-key" onclick="listenKey(this)">T</div></div>
          </div>
        </div>

        <!-- ── CONFIG › INTERFACE ── -->
        <div class="page" id="p-config-ui" data-main="config">
          <div class="card" style="overflow:visible;">
            <div class="c-dd">
              <span class="dd-lbl">Tab Position</span>
              <div class="dd-head" onclick="ddToggle(this)" data-opts='["Left Sidebar","Top Strip"]' data-action="layoutFromDd">
                <span class="dd-cur">Left Sidebar</span><span class="dd-ic">▾</span>
              </div>
            </div>
          </div>
          <div class="card" style="overflow:visible;">
            <div class="c-dd">
              <span class="dd-lbl">UI Theme</span>
              <div class="dd-head" onclick="ddToggle(this)" data-opts='["Dark","Ocean","Crimson","Light"]' data-action="themeFromDd">
                <span class="dd-cur">Dark</span><span class="dd-ic">▾</span>
              </div>
            </div>
          </div>
          <div class="card">
            <div class="c-kb"><span class="kb-lbl">Toggle UI</span><div class="kb-key" onclick="listenKey(this)">RShift</div></div>
          </div>
          <div class="card c-tog sm" onclick="tog(this)">
            <div class="c-ico">🔔</div>
            <div class="c-tog-txt"><span class="c-tog-lbl">Notifications</span></div>
            <div class="pill on"><div class="pill-k"></div></div>
          </div>
          <div class="card c-tog sm" onclick="tog(this)">
            <div class="c-ico">💡</div>
            <div class="c-tog-txt"><span class="c-tog-lbl">Auto-Save Config</span></div>
            <div class="pill on"><div class="pill-k"></div></div>
          </div>
        </div>

        <!-- ── CONFIG › PROFILES ── -->
        <div class="page" id="p-config-save" data-main="config">
          <div class="card">
            <div class="c-tb">
              <span class="tb-lbl">Config Name</span>
              <div class="tb-wrap">
                <input class="tb-in" type="text" placeholder="default" value="my_config">
              </div>
            </div>
          </div>
          <div class="r2">
            <div class="card c-btn sm" onclick="flash(this);notify('Saved','Config saved.','ok')">
              <div class="c-txt"><span class="c-lbl">💾 Save</span></div>
            </div>
            <div class="card c-btn sm" onclick="flash(this);notify('Loaded','Config loaded.','inf')">
              <div class="c-txt"><span class="c-lbl">📂 Load</span></div>
            </div>
          </div>
          <div class="card c-btn sm" onclick="flash(this);notify('Reset','Config reset to defaults.','warn')">
            <div class="c-txt"><span class="c-lbl" style="color:var(--err)">↺ Reset to Default</span></div>
          </div>
        </div>

        <!-- ── CONFIG › ABOUT ── -->
        <div class="page" id="p-config-about" data-main="config">
          <div class="card c-para">
            <span class="para-t">NexusLib v2.3</span>
            <span class="para-b">Sub-tabs keep every setting one click away — no scrolling, no collapsing. Each main tab has its own sub-tab bar. Works with 2 settings or 20.</span>
          </div>
          <div class="card c-para" style="border-color:var(--b2);">
            <span class="para-t" style="color:var(--a)">What's New in v2.3</span>
            <span class="para-b">— Sub-tab navigation per main tab<br>— No more scrolling to reach any setting<br>— Tab position: Sidebar or Top strip<br>— Floating dropdown portaling<br>— Spring-physics pill toggles</span>
          </div>
          <div class="r2">
            <div class="card c-btn sm" onclick="flash(this);notify('Info','NexusLib v2.3','inf')">
              <div class="c-txt"><span class="c-lbl" style="color:var(--inf)">ℹ Info</span></div>
            </div>
            <div class="card c-btn sm" onclick="flash(this);notify('Success','OK!','ok')">
              <div class="c-txt"><span class="c-lbl" style="color:var(--ok)">✓ Success</span></div>
            </div>
          </div>
          <div class="r2">
            <div class="card c-btn sm" onclick="flash(this);notify('Warning','Watch out.','warn')">
              <div class="c-txt"><span class="c-lbl" style="color:var(--warn)">⚠ Warn</span></div>
            </div>
            <div class="card c-btn sm" onclick="flash(this);notify('Error','Failed.','err')">
              <div class="c-txt"><span class="c-lbl" style="color:var(--err)">✕ Error</span></div>
            </div>
          </div>
        </div>

      </div><!-- /pages -->
    </div><!-- /content -->
  </div><!-- /wbody -->

  <div class="sbar">
    <div class="sbar-dot"></div>
    <span class="sbar-t">Connected · 6ms</span>
    <div class="sbar-g"></div>
    <span class="sbar-t" id="sbar-lbl">Combat › General</span>
    <span class="sbar-tag">v2.3.0</span>
  </div>
  <div class="rsz" id="rsz"></div>
</div><!-- /win -->
</div><!-- /shell -->

<div id="dd-float" class="dd-float"></div>
<div id="nc"></div>

<script>
/* ══ STATE ══════════════════════════════════ */
let curMain = 'combat';
// track current sub-tab per main tab
const curSub = {combat:'combat-main', visuals:'visuals-esp', world:'world-move', config:'config-ui'};
const mainNames = {combat:'Combat',visuals:'Visuals',world:'World',config:'Config'};
const subNames  = {
  'combat-main':'General','combat-aim':'Aimbot','combat-misc':'Misc',
  'visuals-esp':'ESP','visuals-colors':'Colors','visuals-chams':'Chams',
  'world-move':'Movement','world-tp':'Teleport',
  'config-ui':'Interface','config-save':'Profiles','config-about':'About'
};

function updateStatusBar() {
  const el = document.getElementById('sbar-lbl');
  if (el) el.textContent = mainNames[curMain] + ' › ' + (subNames[curSub[curMain]]||'');
}

/* ══ MAIN TAB NAV ════════════════════════════ */
function gotoMain(id, src) {
  if (id === curMain) return;

  // hide old pages
  document.querySelectorAll('.page[data-main="'+curMain+'"]').forEach(p=>{
    p.classList.remove('on'); p.classList.add('out');
    setTimeout(()=>p.classList.remove('out'),180);
  });
  // hide old sub-bar
  const oldSub = document.getElementById('sub-'+curMain);
  if (oldSub) oldSub.classList.remove('active');

  curMain = id;

  // show new sub-bar
  const newSub = document.getElementById('sub-'+id);
  if (newSub) newSub.classList.add('active');

  // show current sub-page for this main tab
  const pageId = 'p-' + curSub[id];
  const newPage = document.getElementById(pageId);
  if (newPage) newPage.classList.add('on');

  // sync sidebar / top-strip buttons
  document.querySelectorAll('[data-main]').forEach(b=>{
    if (!b.classList.contains('stab')) // don't touch sub-tab buttons
      b.classList.toggle('on', b.dataset.main === id);
  });

  updateStatusBar();
}

/* ══ SUB-TAB NAV ═════════════════════════════ */
function gotoSub(mainId, pageId, btn) {
  const old = document.getElementById('p-' + curSub[mainId]);
  if (old) { old.classList.remove('on'); old.classList.add('out'); setTimeout(()=>old.classList.remove('out'),180); }

  curSub[mainId] = pageId;

  const nxt = document.getElementById('p-' + pageId);
  if (nxt) nxt.classList.add('on');

  // sync sub-tab buttons
  const bar = document.getElementById('sub-' + mainId);
  if (bar) bar.querySelectorAll('.stab').forEach(b=>b.classList.toggle('on', b.dataset.page===pageId));

  updateStatusBar();
}

/* ══ THEME ═══════════════════════════════════ */
const TMAP = {'Dark':'','Ocean':'ocean','Crimson':'crimson','Light':'light'};
function setTheme(cls, btn) {
  document.body.className = cls;
  if (btn) { document.querySelectorAll('.pg-btn').forEach(b=>b.classList.remove('on')); btn.classList.add('on'); }
}
function themeFromDd(val) {
  const cls = TMAP[val]||'';
  document.body.className = cls;
  document.querySelectorAll('.pg-btn').forEach(b=>{ if(b.textContent===val) b.classList.add('on'); else b.classList.remove('on'); });
}

/* ══ LAYOUT ══════════════════════════════════ */
function setLayout(mode, btn) {
  const win = document.getElementById('win');
  win.classList.remove('layout-left','layout-top');
  win.classList.add('layout-' + mode);
  if (btn) { document.querySelectorAll('.pg-btn').forEach(b=>{ if(b.onclick&&b.onclick.toString().includes('setLayout')) b.classList.remove('on'); }); btn.classList.add('on'); }
  // sync config dd
  const names = {left:'Left Sidebar',top:'Top Strip'};
  document.querySelectorAll('.dd-head[data-action="layoutFromDd"] .dd-cur').forEach(el=>el.textContent=names[mode]||'Left Sidebar');
}
function layoutFromDd(val) {
  const m = val === 'Top Strip' ? 'top' : 'left';
  setLayout(m, null);
  // sync meta buttons
  document.querySelectorAll('.pg-btn').forEach(b=>{
    if (b.getAttribute('onclick')&&b.getAttribute('onclick').includes('setLayout'))
      b.classList.toggle('on', (m==='left'&&b.textContent.includes('Sidebar'))||(m==='top'&&b.textContent.includes('Top')));
  });
}

/* ══ TOGGLE ══════════════════════════════════ */
function tog(el) {
  const p = el.querySelector('.pill');
  if (!p) return;
  p.classList.toggle('on');
  const c = el.closest('.card');
  if (c) { c.style.transform='scale(0.987)'; setTimeout(()=>c.style.transform='',110); }
}

/* ══ FLASH ═══════════════════════════════════ */
function flash(el) {
  const c = el.closest ? el.closest('.card') : el;
  if (!c) return;
  c.classList.remove('flash'); void c.offsetWidth; c.classList.add('flash');
  setTimeout(()=>c.classList.remove('flash'),330);
}

/* ══ SLIDERS ═════════════════════════════════ */
function initSliders() {
  document.querySelectorAll('.c-slide').forEach(sl => {
    const min=parseFloat(sl.dataset.min||0), max=parseFloat(sl.dataset.max||100);
    const step=parseFloat(sl.dataset.step||1), init=parseFloat(sl.dataset.val||min);
    const track=sl.querySelector('.sl-track'), fill=sl.querySelector('.sl-fill');
    const thumb=sl.querySelector('.sl-thumb'), valEl=sl.querySelector('.sl-val');
    let drag=false;
    const dp=step<1?1:0;
    const clamp=v=>Math.max(min,Math.min(max,v));
    const snap=v=>Math.round(v/step)*step;
    const v2p=v=>(v-min)/(max-min);
    function set(v){
      v=clamp(snap(v));
      const p=v2p(v);
      fill.style.width=(p*100)+'%'; thumb.style.left=(p*100)+'%';
      if(valEl) valEl.textContent=v.toFixed(dp);
    }
    function fromE(e){ const r=track.getBoundingClientRect(); return clamp(snap(min+(max-min)*((e.clientX-r.left)/r.width))); }
    set(init);
    thumb.addEventListener('mousedown',e=>{drag=true;e.preventDefault();e.stopPropagation();});
    track.addEventListener('mousedown',e=>{drag=true;set(fromE(e));e.preventDefault();});
    document.addEventListener('mousemove',e=>{if(drag)set(fromE(e));});
    document.addEventListener('mouseup',()=>{drag=false;});
  });
}
initSliders();

/* ══ DROPDOWN ════════════════════════════════ */
let activeDd = null;
const floatEl = document.getElementById('dd-float');

function ddCloseAll() {
  floatEl.classList.remove('open'); floatEl.innerHTML='';
  document.querySelectorAll('.dd-head.open').forEach(h=>h.classList.remove('open'));
  activeDd = null;
}
function ddToggle(head) {
  if (activeDd===head) { ddCloseAll(); return; }
  ddCloseAll();
  activeDd = head;
  head.classList.add('open');
  const opts = JSON.parse(head.dataset.opts||'[]');
  const cur  = head.querySelector('.dd-cur').textContent;
  const action = head.dataset.action;
  floatEl.innerHTML = opts.map(o=>`<div class="dd-opt${o===cur?' sel':''}" onclick="ddPick(this,'${o.replace(/'/g,"\\'")}')">
    ${o===cur?'▸ ':''}${o}</div>`).join('');
  floatEl._head = head;
  floatEl._action = action;
  // position relative to .win
  const win = document.getElementById('win');
  const wr  = win.getBoundingClientRect();
  const hr  = head.getBoundingClientRect();
  floatEl.style.left  = (hr.left-wr.left)+'px';
  floatEl.style.top   = (hr.bottom-wr.top+2)+'px';
  floatEl.style.width = hr.width+'px';
  win.appendChild(floatEl);
  floatEl.classList.add('open');
}
function ddPick(optEl, val) {
  if (!floatEl._head) return;
  floatEl._head.querySelector('.dd-cur').textContent = val;
  floatEl._head.classList.remove('open');
  if (floatEl._action==='layoutFromDd') layoutFromDd(val);
  if (floatEl._action==='themeFromDd')  themeFromDd(val);
  ddCloseAll();
  event.stopPropagation();
}
document.addEventListener('click', e=>{
  if (!e.target.closest('.dd-head')&&!e.target.closest('#dd-float')) ddCloseAll();
});

/* ══ KEYBIND ════════════════════════════════ */
let activeKb = null;
function listenKey(el) {
  if (activeKb) return;
  activeKb = el;
  el.classList.add('hot'); el.dataset.prev = el.textContent; el.textContent='...';
  function handler(e) {
    e.preventDefault();
    const k = e.code.replace('Key','').replace('Digit','');
    el.textContent = k==='Escape' ? el.dataset.prev : k;
    el.classList.remove('hot'); activeKb=null;
    document.removeEventListener('keydown', handler);
  }
  document.addEventListener('keydown', handler);
}

/* ══ COLOR PICKER ════════════════════════════ */
function cpToggle(id) {
  const el=document.getElementById(id); if(!el) return;
  el.querySelector('.cp-body')?.classList.toggle('open');
}

/* ══ WINDOW CONTROLS ════════════════════════ */
let isMini=false;
function toggleMini(){ isMini=!isMini; document.getElementById('win').classList.toggle('mini',isMini); }
function closeWin(){ document.getElementById('win').classList.add('gone'); document.querySelector('.shell').style.cssText+=';opacity:0;transition:opacity .3s;'; }

/* ══ DRAG ════════════════════════════════════ */
(function(){
  const win=document.getElementById('win'), bar=document.getElementById('tbar');
  let d=false,ox=0,oy=0,tx=0,ty=0;
  bar.addEventListener('mousedown',e=>{
    if(e.target.closest('.wcs,.top-strip,.ttab,.wc,.pg-btn')) return;
    d=true; ox=e.clientX; oy=e.clientY; tx=win._tx||0; ty=win._ty||0;
    win.style.transition='none'; e.preventDefault();
  });
  document.addEventListener('mousemove',e=>{ if(!d) return; tx+=e.clientX-ox; ty+=e.clientY-oy; ox=e.clientX; oy=e.clientY; win._tx=tx; win._ty=ty; win.style.transform=`translate(${tx}px,${ty}px)`; });
  document.addEventListener('mouseup',()=>{ if(d){d=false;win.style.transition='';} });
})();

/* ══ RESIZE ══════════════════════════════════ */
(function(){
  const win=document.getElementById('win'), rsz=document.getElementById('rsz');
  let d=false,sx=0,sy=0,sw=0,sh=0;
  rsz.addEventListener('mousedown',e=>{ d=true;sx=e.clientX;sy=e.clientY;sw=win.offsetWidth;sh=win.offsetHeight;e.preventDefault();e.stopPropagation(); });
  document.addEventListener('mousemove',e=>{ if(!d) return; win.style.width=Math.max(520,sw+e.clientX-sx)+'px'; win.style.height=Math.max(320,sh+e.clientY-sy)+'px'; });
  document.addEventListener('mouseup',()=>d=false);
})();

/* ══ NOTIFICATIONS ═══════════════════════════ */
const NC={ok:{c:'#4ade80',bg:'rgba(74,222,128,.13)',i:'✓'},warn:{c:'#fb923c',bg:'rgba(251,146,60,.13)',i:'!'},err:{c:'#f87171',bg:'rgba(248,113,113,.13)',i:'✕'},inf:{c:'#60a5fa',bg:'rgba(96,165,250,.13)',i:'i'}};
const NDUR=4000;
function notify(title,msg,type){
  const c=NC[type]||NC.inf, nc=document.getElementById('nc');
  const el=document.createElement('div'); el.className='notif';
  el.innerHTML=`<div class="n-bg"><div class="n-top" style="background:${c.c}"></div><div class="n-row"><div class="n-icon" style="background:${c.bg};color:${c.c}">${c.i}</div><div class="n-body"><div class="n-ttl">${title}</div>${msg?`<div class="n-msg">${msg}</div>`:''}</div></div><div class="n-prog"><div class="n-fill" style="background:${c.c};width:100%"></div></div></div><button class="n-x" onclick="dismissN(this.closest('.notif'))">×</button>`;
  nc.appendChild(el);
  requestAnimationFrame(()=>requestAnimationFrame(()=>el.classList.add('in')));
  const fill=el.querySelector('.n-fill');
  setTimeout(()=>{ fill.style.transition=`width ${NDUR}ms linear`; fill.style.width='0%'; },40);
  const t=setTimeout(()=>dismissN(el),NDUR); el._t=t;
}
function dismissN(el){ if(!el||el._d) return; el._d=true; clearTimeout(el._t); el.classList.remove('in'); el.classList.add('out'); setTimeout(()=>el.remove(),330); }

/* ══ ENTRY STAGGER ═══════════════════════════ */
window.addEventListener('load',()=>{
  document.querySelectorAll('#p-combat-main > *').forEach((el,i)=>{
    el.style.opacity='0'; el.style.transform='translateY(7px)';
    setTimeout(()=>{ el.style.transition='opacity .26s,transform .26s'; el.style.opacity=''; el.style.transform=''; },100+i*35);
  });
  updateStatusBar();
});
</script>
</body>
</html>
