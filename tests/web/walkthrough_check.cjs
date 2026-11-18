// Opens a web walkthrough in a browser without a screen and walks through it:
//
//     node tests/web/walkthrough_check.cjs <walkthrough folder> <prefix for pictures> [--lab] [--baked]
//
// Any walkthrough: the scene comes up, W walks, the views are reached, a click on the floor
// walks there, a flat wall stops the walk and lets it slide, the plan, the tour, measuring,
// a link to a view. With --lab, the room that tests/dev/lab.gd builds (check "web"), whose
// measures are known: the doorway, the staircase, the hotspot, the floor's two materials,
// the two chairs; and, where Meta's headset emulator is installed (tools/web_viewer, by
// npm install), the same walkthrough in an emulated Quest 3.
//
// Needs Node with Playwright and its Chromium. Prints "WEB ok ...", "WEB FAIL ...", "WEB note ..."
// (and XR ... for the headset); exits with the number of failures. Without Playwright it says
// "WEB skipped" and exits 0.
const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

let chromium;
try {
  chromium = require('playwright').chromium;
} catch (e) {
  console.log('WEB skipped: Playwright is not installed here');
  process.exit(0);
}
const args = process.argv.slice(2);
const folder = path.resolve(args[0]);
const prefix = args[1] || path.join(folder, 'check');
const LAB = args.includes('--lab');
const BAKED = args.includes('--baked');
const IWER = process.env.IWER || path.join(__dirname, '../../tools/web_viewer/node_modules/iwer/build/iwer.min.js');
const SLOW = Number(process.env.ORIEL_WEB_SLOW || 1);     // software drawing is slow: waits are multiplied by this
let fails = 0;
const ok = (cond, text, tag = 'WEB') => { if (!cond) fails++; console.log(`${tag} ${cond ? 'ok  ' : 'FAIL'} ${text}`); };
const note = (text, tag = 'WEB') => console.log(`${tag} note ${text}`);
const f2 = (x) => Number(x).toFixed(2);

async function open(browser, query, hash, init) {
  const page = await browser.newPage({ viewport: { width: 800, height: 450 } });
  const errors = [];
  page.on('console', (m) => { if (m.type() === 'error') errors.push(m.text().slice(0, 300)); });
  page.on('pageerror', (e) => errors.push(String(e).slice(0, 400)));
  page.on('requestfailed', (r) => errors.push('not fetched: ' + r.url()));
  if (init) await init(page);
  await page.goto(`http://localhost:${port}/${query}${hash || ''}`);
  await page.waitForFunction(() => window.oriel && window.oriel.ready, null, { timeout: 600000 * SLOW });
  return { page, errors };
}
const until = async (page, fn, ms = 90000, arg) => { try { await page.waitForFunction(fn, arg, { timeout: ms * SLOW }); return true; } catch (e) { return false; } };
const st = (page) => page.evaluate(() => window.oriel.state());
const still = (page, ms = 240000) => until(page, () => {
  const s = window.oriel.state(); const k = s.position.map((x) => x.toFixed(3)).join(',');
  window._still = (window._last === k) ? (window._still || 0) + 1 : 0; window._last = k; return window._still > 8;
}, ms);
const shot = (page, name) => page.screenshot({ path: `${prefix}_${name}.png`, timeout: 300000 * SLOW }).catch(() => {});

let port = 0;
(async () => {
  port = 8100 + Math.floor(Math.random() * 800);
  const server = spawn('python3', [path.join(folder, 'serve.py'), '--port', String(port), '--local'], { env: { ...process.env, ORIEL_SERVE_QUIET: '1' } });
  await new Promise((r) => server.stdout.once('data', r));
  const browser = await chromium.launch({ args: ['--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist'] });
  try {
    await walk(browser);
    if (LAB) await lab(browser);
    await headset(browser);
  } finally {
    await browser.close();
    server.kill();
  }
  console.log(`WEB RESULT ${fails === 0 ? 'PASS' : 'FAIL'} (${fails} failed)`);
  process.exit(Math.min(fails, 99));
})().catch((e) => { console.error(e); console.log('WEB FAIL the check itself stopped: ' + String(e).slice(0, 200)); process.exit(1); });

// ------------------------------------------------------------ any walkthrough
async function walk(browser) {
  // The cover first: nothing moves until Start.
  let { page, errors } = await open(browser, '', '');
  let a = await st(page);
  const cover = await page.evaluate(() => { const c = document.querySelector('.o-cover'); return c ? { shown: !c.hidden && getComputedStyle(c).display !== 'none', text: c.innerText.slice(0, 200) } : null; });
  const title = await page.evaluate(() => window.oriel.data.title);
  ok(!a.started && cover && cover.shown && cover.text.includes(title), `the page opens on its cover, "${title}", and waits`);
  await page.close();

  ({ page, errors } = await open(browser, '?autostart', ''));
  a = await st(page);
  ok(a.started && a.mode === 'walk' && a.triangles > 10, `with ?autostart it goes straight in: ${a.objects} objects, ${a.triangles} triangles, ${a.calls} draws${a.baked ? ', light baked' : ''}`);
  ok(BAKED ? a.baked : true, BAKED ? 'its light is the baked light' : 'its light is the sun and the lamps');
  const views = await page.evaluate(() => window.oriel.data.views || []);
  // W: forward, the way the view faces, feet on the floor.
  await page.keyboard.down('KeyW');
  await until(page, (p0) => { const s = window.oriel.state(); return Math.hypot(s.position[0] - p0[0], s.position[2] - p0[2]) > 0.6; }, 120000, a.position);
  await page.keyboard.up('KeyW');
  let b = await st(page);
  const moved = Math.hypot(b.position[0] - a.position[0], b.position[2] - a.position[2]);
  const along = (-(b.position[0] - a.position[0]) * Math.sin(a.yaw) - (b.position[2] - a.position[2]) * Math.cos(a.yaw)) / Math.max(moved, 1e-6);
  ok(moved > 0.5 && along > 0.95 && b.onGround, `W walks forward (${f2(moved)} m, ${along.toFixed(3)} along the view), feet on the floor`);
  if (views.length > 1) {
    await page.keyboard.press('BracketRight');
    await until(page, () => { const o = window.oriel, s = o.state(); return s.view === 1 && !s.moving && !o.ui.fading; });
    await page.waitForTimeout(600);
    const c = await st(page);
    const v = views[1];
    ok(c.view === 1 && Math.hypot(c.position[0] - v.position[0], c.position[2] - v.position[2]) < 0.06 && Math.abs(c.position[1] + c.eye - v.position[1]) < 0.06,
      `] goes to the next view, "${v.name}" (eyes at ${f2(c.position[1] + c.eye)} m)`);
    await page.keyboard.press('BracketLeft');
    await until(page, () => { const o = window.oriel, s = o.state(); return s.view === 0 && !s.moving && !o.ui.fading; });
    ok((await st(page)).view === 0, '[ goes back');
  }
  // A click on the floor walks there.
  await page.evaluate(() => { window.oriel.nav.goToView(0, { instant: true }); window.oriel.nav.pitch = -0.55; });
  await page.waitForTimeout(500);
  const vp = page.viewportSize();
  const target = await page.evaluate(() => { const o = window.oriel; const h = o.nav.pick(o.canvas.clientWidth / 2, o.canvas.clientHeight * 0.6); return h ? { p: h.point.toArray(), ny: h.normal.y } : null; });
  if (target && target.ny > 0.6) {
    await page.mouse.click(vp.width / 2, vp.height * 0.6);
    await until(page, () => window.oriel.state().moving, 10000);
    await until(page, () => !window.oriel.state().moving, 120000);
    const d = await st(page);
    ok(Math.hypot(d.position[0] - target.p[0], d.position[2] - target.p[2]) < 0.12 && Math.abs(d.position[1] - target.p[1]) < 0.12, `a click on the floor walks there (${target.p.map(f2).join(', ')})`);
  } else note('no floor under the middle of the first view to click on');
  // A flat wall: the walk stops a body's half-width from it, and slides along it at an angle.
  await page.evaluate(() => window.oriel.nav.goToView(0, { instant: true }));
  await page.waitForTimeout(400);
  const wall = await page.evaluate(() => {
    const o = window.oriel, nav = o.nav, V = nav.pos.constructor;
    let best = null;
    const base = nav.pos.clone();
    for (let k = 0; k < 64; k++) {
      const yaw = k * Math.PI / 32;
      const dir = new V(-Math.sin(yaw), 0, -Math.cos(yaw));
      const from = base.clone(); from.y += 1.0;
      const h = nav.cast(from, dir, 14);
      if (!h || Math.abs(h.normal.y) > 0.12 || h.distance < 1.0) continue;
      const n = h.normal.clone(); n.y = 0; n.normalize();
      if (n.dot(dir) > -0.5) continue;
      const t = new V(-n.z, 0, n.x);
      const d0 = h.point.dot(n);
      let flat = true;
      for (const [side, up] of [[-0.45, 1.0], [0.45, 1.0], [0, 0.35], [0, 1.55], [-0.45, 0.35], [0.45, 1.55]]) {
        const f = base.clone().addScaledVector(t, side); f.y += up;
        const g = nav.cast(f, n.clone().negate(), 20);
        if (!g || g.normal.dot(n) < 0.995 || Math.abs(g.point.dot(n) - d0) > 0.02) { flat = false; break; }
      }
      if (!flat) continue;
      const gap = base.dot(n) - d0;
      if (gap < 0.7) continue;
      if (!best || gap < best.gap) best = { gap, n: n.toArray(), d0 };
    }
    if (best) { nav.yaw = Math.atan2(best.n[0], best.n[2]); nav.pitch = 0; }
    return best;
  });
  if (wall) {
    await page.keyboard.down('KeyW');
    await still(page);
    await page.keyboard.up('KeyW');
    const e = await st(page);
    const left = e.position[0] * wall.n[0] + e.position[2] * wall.n[2] - wall.d0;
    ok(left > 0.2 && left < 0.36, `walking squarely at a wall ${f2(wall.gap)} m away stops ${left.toFixed(3)} m from it (the visitor is 0.25 m round)`);
    await page.evaluate((n) => { window.oriel.nav.yaw = Math.atan2(n[0], n[2]) + Math.PI / 4; }, wall.n);
    const p0 = e.position;
    await page.keyboard.down('KeyW');
    await until(page, (q) => { const s = window.oriel.state(); return Math.hypot(s.position[0] - q[0], s.position[2] - q[2]) > 0.3; }, 60000, p0);
    await page.keyboard.up('KeyW');
    const s2 = await st(page);
    const left2 = s2.position[0] * wall.n[0] + s2.position[2] * wall.n[2] - wall.d0;
    const slid = Math.hypot(s2.position[0] - p0[0], s2.position[2] - p0[2]);
    ok(left2 > 0.2 && slid > 0.25, `at an angle the walk slides along the wall (${f2(slid)} m) without going through it (${left2.toFixed(3)} m off)`);
  } else note('no flat wall within reach of the first view');
  // Orbit, the plan, a click on the plan.
  await page.keyboard.press('Digit2');
  await until(page, () => window.oriel.state().mode === 'orbit', 20000);
  ok((await st(page)).mode === 'orbit', '2 turns to the orbit');
  await page.waitForTimeout(800);
  await shot(page, 'orbit');
  await page.keyboard.press('Digit3');
  await until(page, () => window.oriel.state().mode === 'top', 20000);
  ok((await st(page)).mode === 'top', '3 shows the plan from above');
  await page.waitForTimeout(1200);
  await shot(page, 'plan');
  await page.keyboard.press('Digit1');
  await until(page, () => window.oriel.state().mode === 'walk', 20000);
  ok((await st(page)).mode === 'walk', '1 comes back to walking');
  // The tour.
  if (views.length > 1) {
    await page.evaluate(() => window.oriel.nav.goToView(0, { instant: true }));
    await page.keyboard.press('KeyT');
    ok(await until(page, () => window.oriel.state().tour, 10000), 'T starts the tour');
    ok(await until(page, () => window.oriel.state().view === 1, 240000), 'the tour goes on to the second view by itself');
    await page.keyboard.press('KeyT');
    await page.waitForTimeout(300);
    ok(!(await st(page)).tour, 'T stops it');
  }
  // Measuring: two clicks, a length that is the distance between them.
  if (await page.evaluate(() => !!window.oriel.ui.btns.measure)) {
    await page.evaluate(() => { window.oriel.nav.goToView(0, { instant: true }); window.oriel.nav.pitch = -0.45; });
    await page.waitForTimeout(500);
    const pts = await page.evaluate(() => { const o = window.oriel, w = o.canvas.clientWidth, h = o.canvas.clientHeight; const a = o.nav.pick(w * 0.38, h * 0.62), b = o.nav.pick(w * 0.62, h * 0.62); return a && b ? [a.point.toArray(), b.point.toArray()] : null; });
    if (pts) {
      await page.keyboard.press('KeyM');
      await page.mouse.click(vp.width * 0.38, vp.height * 0.62);
      await page.mouse.click(vp.width * 0.62, vp.height * 0.62);
      await page.waitForTimeout(500);
      const m = await page.evaluate(() => window.oriel.ui.measure.lines.map((l) => l.length));
      const want = Math.hypot(pts[0][0] - pts[1][0], pts[0][1] - pts[1][1], pts[0][2] - pts[1][2]);
      ok(m.length === 1 && Math.abs(m[0] - want) < 0.03, `measuring between two clicks gives ${m.length ? m[0].toFixed(3) : '-'} m (they are ${want.toFixed(3)} m apart)`);
      await shot(page, 'measure');
      await page.keyboard.press('KeyM');
    } else note('nothing under the two points to measure between');
  }
  ok(errors.length === 0, errors.length ? `${errors.length} errors on the page: ${errors[0]}` : 'no errors on the page');
  await page.close();
  // A link to a view opens there.
  if (views.length > 1) {
    const v = views[views.length - 1];
    ({ page, errors } = await open(browser, '?autostart&probes=0', '#view=' + encodeURIComponent(v.name)));
    const s = await st(page);
    ok(s.view === views.length - 1 && Math.hypot(s.position[0] - v.position[0], s.position[2] - v.position[2]) < 0.06, `…#view=${v.name} opens at that view`);
    // "Copy a link to where I am" puts the spot into the page's address.
    await page.evaluate(() => { const n = window.oriel.nav; n.yaw += 0.4; window.oriel.ui.copyLink(); });
    const spotAt = await st(page);
    const link = await page.evaluate(() => location.hash);
    await page.close();
    if (link.startsWith('#p=')) {
      ({ page, errors } = await open(browser, '?autostart&probes=0', link));
      const t = await st(page);
      ok(Math.hypot(t.position[0] - spotAt.position[0], t.position[2] - spotAt.position[2]) < 0.05 && Math.abs(t.yaw - spotAt.yaw) < 0.02, 'and a copied link to a spot opens at that spot, facing the same way');
      await page.close();
    } else ok(false, 'a link to where the visitor stands is made (' + link + ')');
  }
}

// ------------------------------------------------------------ the lab's room (tests/dev/lab.gd, _web)
async function lab(browser) {
  const { page, errors } = await open(browser, '?autostart', '');
  const names = await page.evaluate(() => Object.fromEntries(Object.entries(window.oriel.data.objects).map(([k, v]) => [(v.path || '').split('/').pop(), k])));
  await shot(page, 'inside');
  // The staircase: from the view at its foot, W climbs ten steps of 0.17 m to the landing.
  await page.evaluate(() => { const o = window.oriel; o.nav.goToView(o.data.views.findIndex((v) => v.name === 'Stairs'), { instant: true }); });
  await page.waitForTimeout(500);
  const foot = await st(page);
  await page.keyboard.down('KeyW');
  await until(page, () => window.oriel.state().position[0] > 1.3, 300000);
  await page.keyboard.up('KeyW');
  await page.waitForTimeout(600);
  const top = await st(page);
  ok(Math.abs(foot.position[1]) < 0.03 && Math.abs(top.position[1] - 1.7) < 0.04 && top.onGround, `the staircase carries the visitor up: from the floor (${f2(foot.position[1])} m) to the landing (${f2(top.position[1])} m; it is 1.70 m up)`);
  await shot(page, 'landing');
  // The doorway: 1 m wide. Through its middle the walk passes; beside it the wall stops it.
  await page.evaluate(() => { const n = window.oriel.nav; n.settle(new n.pos.constructor(0, 1.6, 0)); n.yaw = 0; n.pitch = 0; });
  await page.waitForTimeout(300);
  await page.keyboard.down('KeyW');
  await until(page, () => window.oriel.state().position[2] < -3.2, 240000);
  await page.keyboard.up('KeyW');
  const out = await st(page);
  ok(out.position[2] < -3.0 && Math.abs(out.position[0]) < 0.3, `through the doorway and out (now ${f2(-out.position[2] - 2.2)} m beyond the wall)`);
  await page.evaluate(() => { const n = window.oriel.nav; n.settle(new n.pos.constructor(1.5, 1.6, 0)); n.yaw = 0; n.pitch = 0; });
  await page.waitForTimeout(300);
  await page.keyboard.down('KeyW');
  await still(page);
  await page.keyboard.up('KeyW');
  const stopped = await st(page);
  ok(Math.abs(stopped.position[2] - (-2.0 + 0.25)) < 0.06, `beside the doorway the wall stops the walk 0.25 m from it (at ${f2(stopped.position[2])}; the wall's face is at -2.00)`);
  // The hotspot: its marker on the page opens its note.
  await page.evaluate(() => { const o = window.oriel; o.nav.goToView(0, { instant: true }); o.nav.settle(new o.nav.pos.constructor(0.6, 1.6, 0.4)); o.nav.yaw = 0; o.nav.pitch = -0.1; });
  await page.waitForTimeout(1500);
  const marker = await page.evaluate(() => { const m = document.querySelector('.o-marker'); if (!m) return null; const r = m.getBoundingClientRect(); return { x: r.x + r.width / 2, y: r.y + r.height / 2, hidden: m.hidden || getComputedStyle(m).display === 'none', title: m.title || m.getAttribute('aria-label') || '' }; });
  if (marker && !marker.hidden) {
    await page.mouse.click(marker.x, marker.y);
    await page.waitForTimeout(500);
    const panel = await page.evaluate(() => { const p = window.oriel.ui.panels.spot; return p.hidden ? '' : p.innerText; });
    ok(panel.includes('The doorway') && panel.includes('One metre wide'), 'the hotspot\'s marker opens its note ("The doorway")');
    await shot(page, 'hotspot');
    await page.keyboard.press('Escape');
  } else ok(false, 'the hotspot shows as a marker on the page');
  // The floor's two materials: Options, then Slate; the floor is then slate-dark.
  const floorColour = () => page.evaluate((name) => { const m = window.oriel.world.meshes.get(name)[0].material; return m.color.toArray().map((x) => +x.toFixed(3)).concat([m.name]); }, names.Floor);
  const before = await floorColour();
  const has = await page.evaluate(() => !!window.oriel.ui.btns.options);
  ok(has, 'there is an Options button, as the scene has things to choose');
  if (has) {
    await page.evaluate(() => window.oriel.ui.btns.options.click());
    await page.waitForTimeout(300);
    const chips = await page.evaluate(() => [...document.querySelectorAll('.o-options .o-chip')].map((c) => c.title || c.innerText));
    await page.evaluate(() => { const c = [...document.querySelectorAll('.o-options .o-swatch')].find((x) => x.title === 'Slate'); if (c) c.click(); });
    await page.waitForTimeout(600);
    const after = await floorColour();
    ok(before[0] > after[0] + 0.05 && after[0] < 0.1, `choosing Slate for the floor changes it (its red from ${before[0]} to ${after[0]}; the choices: ${chips.join(', ')})`);
    await shot(page, 'slate');
    // The chairs: one shown at a time.
    const seen = () => page.evaluate((n) => [window.oriel.world.objects.get(n[0]).visible, window.oriel.world.objects.get(n[1]).visible], [names['Chair oak'], names['Chair blue']]);
    const s0 = await seen();
    await page.evaluate(() => { const c = [...document.querySelectorAll('.o-options .o-chip')].find((x) => x.innerText.trim() === 'Chair blue'); if (c) c.click(); });
    await page.waitForTimeout(500);
    const s1 = await seen();
    ok(s0[0] && !s0[1] && !s1[0] && s1[1], 'of the two chairs one is shown at a time, and the visitor chooses which');
    await page.keyboard.press('Escape');
  }
  if (BAKED) {
    const light = await page.evaluate((n) => {
      const o = window.oriel, w = o.world;
      const ball = w.meshes.get(n.Ball)[0], wall = w.meshes.get(n['Wall east'])[0];
      return { ball: !!ball.material.vertexColors && !!ball.geometry.attributes.color, wall: !!wall.material.lightMap, probes: w.probes.length, mirrored: ball.material.envMap ? 1 : 0, eye: o.state().light };
    }, names);
    ok(light.ball && light.wall, 'in the browser the ball is lit by the light at its corners and the wall by its lightmap');
    ok(light.probes >= 1 && light.mirrored === 1, `the viewer looked round from ${light.probes} of the views, and the ball mirrors the room it stands in`);
    // The eye: outside in daylight the exposure is as set; inside the lamp-lit room it opens up.
    const expo = async (view) => { await page.evaluate((v) => { const o = window.oriel; o.nav.goToView(o.data.views.findIndex((x) => x.name === v), { instant: true }); }, view); await page.waitForTimeout(3500 * SLOW); return (await st(page)).light; };
    const outside = await expo('Outside'), inside = await expo('Inside');
    if (outside && inside) ok(outside.gain < 1.6 && inside.gain >= outside.gain, `the eye adjusts: outside the exposure is held (x${f2(outside.gain)}), in the room it is x${f2(inside.gain)}`);
    else note('the eye has no daylight to go by in this scene');
    await shot(page, 'baked_inside');
  }
  ok(errors.length === 0, errors.length ? `${errors.length} errors on the page: ${errors[0]}` : 'no errors on the page with all that');
  await page.close();
}

// ------------------------------------------------------------ in an emulated headset
async function headset(browser) {
  if (!fs.existsSync(IWER)) {
    note('no headset emulator here (npm install in tools/web_viewer brings it): VR not tried', 'XR');
    return;
  }
  const xok = (c, t) => ok(c, t, 'XR');
  const { page, errors } = await open(browser, '?autostart&probes=0', '', async (p) => {
    await p.addInitScript({ path: IWER });
    await p.addInitScript(() => { const d = new IWER.XRDevice(IWER.metaQuest3, { stereoEnabled: true }); d.installRuntime(); d.position.set(0, 1.6, 0); window.xrDevice = d; });
  });
  const xs = () => page.evaluate(() => { const o = window.oriel, s = o.state(); return { ...s, head: o.xr.headWorld().toArray(), aim: o.xr.aim ? (o.xr.aim.target ? o.xr.aim.target.toArray() : 'none') : null }; });
  let a = await xs();
  xok(a.vrSupported && await page.evaluate(() => !window.oriel.ui.btns.vr.hidden), 'the page finds the headset and shows its VR button');
  const before = a;
  await page.evaluate(() => window.oriel.ui.btns.vr.click());
  xok(await until(page, () => window.oriel.state().vr, 60000), 'the button starts an immersive session');
  await until(page, () => !window.oriel.xr.wantHead, 60000);
  await page.waitForTimeout(1500 * SLOW);
  a = await xs();
  xok(Math.hypot(a.head[0] - before.position[0], a.head[2] - before.position[2]) < 0.06 && Math.abs(a.position[1] - before.position[1]) < 0.06, `in the headset the visitor stands where they stood on the page (${a.head.map(f2).join(', ')})`);
  xok(Math.abs(a.head[1] - a.position[1] - 1.6) < 0.06, `with the head at the headset's own height above the floor (${f2(a.head[1] - a.position[1])} m)`);
  await shot(page, 'xr');
  // The trigger: an arc to a place on the floor; let go, and the visitor is there.
  await page.evaluate(() => { const c = window.xrDevice.controllers.right; c.position.set(0.2, 1.1, -0.3); c.quaternion.set(-0.3007, 0, 0, 0.9537); c.updateButtonValue('trigger', 1); });
  const aimed = await until(page, () => window.oriel.xr.aim && window.oriel.xr.aim.target, 60000);
  const b = await xs();
  xok(aimed && Array.isArray(b.aim), 'holding the trigger draws the arc to a place on the floor' + (Array.isArray(b.aim) ? ` (${b.aim.map(f2).join(', ')})` : ''));
  await shot(page, 'xr_arc');
  await page.evaluate(() => window.xrDevice.controllers.right.updateButtonValue('trigger', 0));
  await until(page, () => !window.oriel.xr.aim, 30000);
  await page.waitForTimeout(1200 * SLOW);
  const c = await xs();
  xok(Array.isArray(b.aim) && Math.hypot(c.head[0] - b.aim[0], c.head[2] - b.aim[2]) < 0.08 && Math.abs(c.position[1] - b.aim[1]) < 0.08, 'letting go jumps there');
  // The left stick walks the way the head faces; the right turns 30 degrees about the head.
  const fwd = await page.evaluate(() => { const o = window.oriel; const d = o.camera.getWorldDirection(new o.nav.pos.constructor()); d.y = 0; d.normalize(); return [d.x, d.z]; });
  await page.evaluate(() => window.xrDevice.controllers.left.updateAxes('thumbstick', 0, -1));
  await until(page, (p0) => { const h = window.oriel.xr.headWorld(); return Math.hypot(h.x - p0[0], h.z - p0[2]) > 0.4; }, 240000, [c.head[0], c.head[2]]);
  await page.evaluate(() => window.xrDevice.controllers.left.updateAxes('thumbstick', 0, 0));
  await page.waitForTimeout(600);
  const d = await xs();
  const moved = Math.hypot(d.head[0] - c.head[0], d.head[2] - c.head[2]);
  const along = ((d.head[0] - c.head[0]) * fwd[0] + (d.head[2] - c.head[2]) * fwd[1]) / Math.max(moved, 1e-6);
  xok(moved > 0.3 && along > 0.9, `the left stick walks the way the head faces (${f2(moved)} m, ${along.toFixed(3)} along it)`);
  await page.evaluate(() => window.xrDevice.controllers.right.updateAxes('thumbstick', 1, 0));
  await until(page, (y) => Math.abs(window.oriel.state().yaw - y) > 0.3, 30000, d.yaw);
  await page.evaluate(() => window.xrDevice.controllers.right.updateAxes('thumbstick', 0, 0));
  await page.waitForTimeout(600);
  const e = await xs();
  const turned = (d.yaw - e.yaw) * 180 / Math.PI;
  xok(Math.abs(turned - 30) < 0.5 && Math.hypot(e.head[0] - d.head[0], e.head[2] - d.head[2]) < 0.03, `the right stick turns ${turned.toFixed(1)} degrees, the head staying where it is`);
  const views = await page.evaluate(() => (window.oriel.data.views || []).length);
  if (views > 1) {
    await page.evaluate(() => window.xrDevice.controllers.right.updateButtonValue('a-button', 1));
    await until(page, (v) => window.oriel.state().view !== v, 30000, e.view);
    await page.evaluate(() => window.xrDevice.controllers.right.updateButtonValue('a-button', 0));
    await page.waitForTimeout(1200 * SLOW);
    const f = await xs();
    const v = await page.evaluate((i) => window.oriel.data.views[i], f.view);
    xok(f.view !== e.view && Math.hypot(f.head[0] - v.position[0], f.head[2] - v.position[2]) < 0.1, `A goes to the next view, "${v.name}"`);
  }
  // A hotspot: stood before it, pointed at, the trigger opens its panel.
  const spot = await page.evaluate(() => { const s = window.oriel.xr.spots[0]; return s ? s.position.toArray() : null; });
  if (spot) {
    await page.evaluate((p) => {
      const o = window.oriel, V = o.nav.pos.constructor;
      const floor = o.nav.floorUnder(new V(p[0], p[1] + 0.3, p[2] + 1.6), 0.5, 6);
      o.xr.placeHead(new V(p[0], floor ?? o.nav.pos.y, p[2] + 1.6));
    }, spot);
    await page.waitForTimeout(800);
    await page.evaluate((p) => {
      const o = window.oriel, V = o.nav.pos.constructor, c = window.xrDevice.controllers.right;
      c.position.set(0.15, 1.2, -0.2);
      o.rig.updateMatrixWorld(true);
      const from = new V(0.15, 1.2, -0.2).applyMatrix4(o.rig.matrixWorld);
      const local = new V(p[0], p[1], p[2]).sub(from).normalize().transformDirection(o.rig.matrixWorld.clone().invert());
      const q = new o.camera.quaternion.constructor().setFromUnitVectors(new V(0, 0, -1), local);
      c.quaternion.set(q.x, q.y, q.z, q.w);
    }, spot);
    await page.waitForTimeout(800);
    await page.evaluate(() => window.xrDevice.controllers.right.updateButtonValue('trigger', 1));
    const opened = await until(page, () => !!window.oriel.xr.panel, 30000);
    await page.evaluate(() => window.xrDevice.controllers.right.updateButtonValue('trigger', 0));
    xok(opened, 'the trigger on a hotspot opens its panel, in the scene before the visitor');
    await page.waitForTimeout(800);
    await shot(page, 'xr_spot');
  }
  await page.evaluate(() => window.oriel.renderer.xr.getSession().end());
  xok(await until(page, () => !window.oriel.state().vr, 30000), 'ending the session comes back to the page');
  await page.waitForTimeout(800);
  const g = await xs();
  xok(g.mode === 'walk' && !g.vr, 'which goes on from where the headset left off');
  xok(errors.length === 0, errors.length ? `${errors.length} errors on the page: ${errors[0]}` : 'no errors on the page in the headset');
  await page.close();
}
