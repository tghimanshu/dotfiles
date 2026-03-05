// ── CONFIG ────────────────────────────────────────────────────────────────────
const CONFIG = {
  GH_USER: 'tghimanshu',
  LC_USER: 'himanshu_gohil_12',
  SERVICES: [
    { id: 'webui',     name: 'Open WebUI',  url: 'http://localhost:3000',  dotId: 'dot-webui',     latId: 'lat-webui' },
    { id: 'ollama',    name: 'Ollama API',  url: 'http://localhost:11434', dotId: 'dot-ollama',    latId: 'lat-ollama' },
    { id: 'lifeos',    name: 'Life OS',     url: 'http://localhost:4000',  dotId: 'dot-lifeos',    latId: 'lat-lifeos' },
    { id: 'portainer', name: 'Portainer',   url: 'http://localhost:9000',  dotId: 'dot-portainer', latId: 'lat-portainer' },
  ],
  POMO_PHASES: [
    { label: 'FOCUS',       duration: 25 * 60 },
    { label: 'SHORT BREAK', duration:  5 * 60 },
    { label: 'FOCUS',       duration: 25 * 60 },
    { label: 'SHORT BREAK', duration:  5 * 60 },
    { label: 'FOCUS',       duration: 25 * 60 },
    { label: 'SHORT BREAK', duration:  5 * 60 },
    { label: 'FOCUS',       duration: 25 * 60 },
    { label: 'LONG BREAK',  duration: 15 * 60 },
  ],
  CACHE_TTL: {
    HN:          5 * 60_000,
    GH_ACTIVITY: 10 * 60_000,
    CONTRIB:     30 * 60_000,
  },
  HABITS: ['LeetCode', 'Read', 'Deep Work', 'GitHub Commit'],
};

// ── API CACHE HELPERS ─────────────────────────────────────────────────────────
function cacheGet(key, ttl) {
  try {
    const raw = localStorage.getItem(key);
    if (!raw) return null;
    const { data, ts } = JSON.parse(raw);
    if (Date.now() - ts > ttl) return null;
    return data;
  } catch { return null; }
}

function cacheSet(key, data) {
  try {
    localStorage.setItem(key, JSON.stringify({ data, ts: Date.now() }));
  } catch { /* storage full */ }
}

// ── THEME ─────────────────────────────────────────────────────────────────────
const html     = document.documentElement;
const themeBtn = document.getElementById('theme-btn');

function applyTheme(t) {
  html.setAttribute('data-theme', t);
  themeBtn.textContent = t === 'dark' ? '☀ light' : '☾ dark';
  localStorage.setItem('theme', t);
  const mtc = document.getElementById('meta-theme-color');
  if (mtc) mtc.content = t === 'dark' ? '#0d0f14' : '#f0f2f8';
}

const savedTheme = localStorage.getItem('theme');
if (savedTheme) {
  applyTheme(savedTheme);
} else {
  applyTheme(window.matchMedia('(prefers-color-scheme: light)').matches ? 'light' : 'dark');
}

window.matchMedia('(prefers-color-scheme: light)').addEventListener('change', e => {
  if (!localStorage.getItem('theme')) applyTheme(e.matches ? 'light' : 'dark');
});

themeBtn.addEventListener('click', () => {
  applyTheme(html.getAttribute('data-theme') === 'dark' ? 'light' : 'dark');
});

// ── ACCENT COLOR ──────────────────────────────────────────────────────────────
const swatches = document.querySelectorAll('.swatch');

function applyAccent(name) {
  html.setAttribute('data-accent', name);
  localStorage.setItem('sp-accent', name);
  swatches.forEach(s => s.classList.toggle('active', s.dataset.accent === name));
}

swatches.forEach(s => s.addEventListener('click', () => applyAccent(s.dataset.accent)));
applyAccent(localStorage.getItem('sp-accent') || 'blue');

// ── TOAST ─────────────────────────────────────────────────────────────────────
const toastEl = document.getElementById('toast');
let toastTimer;
function showToast(msg, duration = 2000) {
  toastEl.textContent = msg;
  toastEl.classList.add('show');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => toastEl.classList.remove('show'), duration);
}

// ── CLOCK ─────────────────────────────────────────────────────────────────────
const DAYS        = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
const MONTHS      = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
const MONTHS_LONG = ['January','February','March','April','May','June','July','August','September','October','November','December'];

function todayStr() {
  const now = new Date();
  return `${now.getFullYear()}-${String(now.getMonth()+1).padStart(2,'0')}-${String(now.getDate()).padStart(2,'0')}`;
}

function greeting(h) {
  if (h < 5)  return 'Good night.';
  if (h < 12) return 'Good morning.';
  if (h < 17) return 'Good afternoon.';
  if (h < 21) return 'Good evening.';
  return 'Good night.';
}

function updateClock() {
  const now  = new Date();
  const h    = now.getHours();
  const hh   = String(h).padStart(2, '0');
  const mm   = String(now.getMinutes()).padStart(2, '0');
  const ss   = String(now.getSeconds()).padStart(2, '0');
  const date = `${DAYS[now.getDay()]}, ${now.getDate()} ${MONTHS[now.getMonth()]} ${now.getFullYear()}`;

  document.getElementById('header-clock').textContent   = `${hh}:${mm}`;
  document.getElementById('clock-hm').textContent       = `${hh}:${mm}`;
  document.getElementById('clock-s').textContent        = `:${ss}`;
  document.getElementById('clock-date').textContent     = date;
  document.getElementById('clock-greeting').textContent = greeting(h);
}
updateClock();
setInterval(updateClock, 1000);

// ── PAGE SWITCHING ────────────────────────────────────────────────────────────
let currentPage = 0;

function switchPage(idx) {
  currentPage = idx;
  document.querySelectorAll('.tab').forEach((t, i) => {
    t.classList.toggle('active', i === idx);
    t.setAttribute('aria-selected', i === idx);
  });
  document.querySelectorAll('.page').forEach(el => {
    el.classList.toggle('active', Number(el.dataset.page) === idx);
  });
  clearSearch();
  exitHintMode();
}

document.querySelectorAll('.tab').forEach((tab, i) => {
  tab.addEventListener('click', () => switchPage(i));
});

// ── DAILY FOCUS GOAL ──────────────────────────────────────────────────────────
const focusInput   = document.getElementById('focus-goal-input');
const focusClear   = document.getElementById('focus-goal-clear');
const focusDateEl  = document.getElementById('focus-goal-date');
const focusSavedEl = document.getElementById('focus-goal-saved');

function loadFocusGoal() {
  const today = todayStr();
  focusDateEl.textContent = today;
  try {
    const saved = JSON.parse(localStorage.getItem('sp-focus-goal') || 'null');
    if (saved && saved.date === today) {
      focusInput.value = saved.text;
    } else {
      focusInput.value = '';
      localStorage.removeItem('sp-focus-goal');
    }
  } catch {
    focusInput.value = '';
  }
}

let focusSaveTimer;
focusInput.addEventListener('input', () => {
  focusSavedEl.classList.remove('show');
  clearTimeout(focusSaveTimer);
  focusSaveTimer = setTimeout(() => {
    localStorage.setItem('sp-focus-goal', JSON.stringify({ text: focusInput.value, date: todayStr() }));
    focusSavedEl.classList.add('show');
    setTimeout(() => focusSavedEl.classList.remove('show'), 1500);
  }, 600);
});

focusClear.addEventListener('click', () => {
  focusInput.value = '';
  localStorage.removeItem('sp-focus-goal');
  showToast('Focus goal cleared');
});

loadFocusGoal();

// ── HABIT TRACKER ─────────────────────────────────────────────────────────────
function loadHabits() {
  try {
    return JSON.parse(localStorage.getItem('sp-habits') || 'null');
  } catch { return null; }
}

function saveHabits(data) {
  localStorage.setItem('sp-habits', JSON.stringify(data));
}

function defaultHabits() {
  const habits = {};
  CONFIG.HABITS.forEach(h => { habits[h] = { done: false, streak: 0 }; });
  return { date: todayStr(), habits };
}

function initHabits() {
  const today = todayStr();
  let data = loadHabits();

  if (!data) {
    data = defaultHabits();
    saveHabits(data);
    return data;
  }

  if (data.date === today) return data;

  // Day changed — update streaks
  const yesterday = new Date(data.date);
  const todayDate = new Date(today);
  const diffDays  = Math.round((todayDate - yesterday) / 86400000);

  CONFIG.HABITS.forEach(h => {
    if (!data.habits[h]) data.habits[h] = { done: false, streak: 0 };
    if (diffDays === 1) {
      // Yesterday — increment streak if done, else reset
      data.habits[h].streak = data.habits[h].done ? data.habits[h].streak + 1 : 0;
    } else {
      // Missed multiple days — reset streak
      data.habits[h].streak = 0;
    }
    data.habits[h].done = false;
  });

  data.date = today;
  saveHabits(data);
  return data;
}

let habitData = initHabits();

function renderHabits() {
  const list     = document.getElementById('habit-list');
  const score    = document.getElementById('habit-score');
  const dateEl   = document.getElementById('habit-date');
  const resetNote = document.getElementById('habit-reset-note');

  list.innerHTML = '';
  const doneCount = CONFIG.HABITS.filter(h => habitData.habits[h]?.done).length;

  CONFIG.HABITS.forEach(h => {
    const state  = habitData.habits[h] || { done: false, streak: 0 };
    const streak = state.streak;
    const hot    = streak >= 3;
    const li     = document.createElement('li');
    li.className = 'habit-item' + (state.done ? ' done' : '');
    li.innerHTML = `
      <input type="checkbox" class="habit-cb" data-habit="${h.replace(/"/g,'&quot;')}" ${state.done ? 'checked' : ''} />
      <span class="habit-name">${h.replace(/</g,'&lt;')}</span>
      <span class="habit-streak${hot ? ' hot' : ''}">${streak > 0 ? `🔥 ${streak}` : '—'}</span>`;
    list.appendChild(li);
  });

  score.textContent = `${doneCount}/${CONFIG.HABITS.length} today`;
  dateEl.textContent = habitData.date;
  resetNote.textContent = 'resets at midnight';
}

document.getElementById('habit-list').addEventListener('change', e => {
  if (!e.target.classList.contains('habit-cb')) return;
  const h = e.target.dataset.habit;
  if (!habitData.habits[h]) habitData.habits[h] = { done: false, streak: 0 };
  habitData.habits[h].done = e.target.checked;
  saveHabits(habitData);
  renderHabits();
});

renderHabits();

// Midnight auto-reset
let lastDateCheck = todayStr();
setInterval(() => {
  const now = todayStr();
  if (now !== lastDateCheck) {
    lastDateCheck = now;
    habitData = initHabits();
    renderHabits();
    loadFocusGoal();
  }
}, 60_000);

// ── SEARCH / FILTER ───────────────────────────────────────────────────────────
const searchEl    = document.getElementById('search');
const engineBadge = document.getElementById('engine-badge');
const noResults   = document.getElementById('no-results');

const ENGINES = {
  google: q => `https://www.google.com/search?q=${encodeURIComponent(q)}`,
  ddg:    q => `https://duckduckgo.com/?q=${encodeURIComponent(q)}`,
  yt:     q => `https://www.youtube.com/results?search_query=${encodeURIComponent(q)}`,
  gh:     q => `https://github.com/search?q=${encodeURIComponent(q)}`,
  npm:    q => `https://www.npmjs.com/search?q=${encodeURIComponent(q)}`,
  pypi:   q => `https://pypi.org/search/?q=${encodeURIComponent(q)}`,
};

let activeEngine = 'google';

function setEngine(name) {
  activeEngine = name;
  engineBadge.textContent = name;
}

function clearSearch() {
  searchEl.value = '';
  filterLinks('');
  setEngine('google');
}

function filterLinks(q) {
  const cards = document.querySelectorAll(`.page[data-page="${currentPage}"]`);
  let anyVisible = false;

  cards.forEach(card => {
    const links = card.querySelectorAll('.link-item');
    if (!links.length) return;
    links.forEach(link => {
      const name = link.querySelector('.link-name');
      const desc = link.querySelector('.link-desc');
      const text = (name?.textContent ?? '') + ' ' + (desc?.textContent ?? '');
      const match = !q || text.toLowerCase().includes(q.toLowerCase());
      link.classList.toggle('hidden', !match);
      if (match) anyVisible = true;

      if (name) {
        if (q && match) {
          const re = new RegExp(`(${q.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')})`, 'gi');
          name.innerHTML = name.textContent.replace(re, '<mark>$1</mark>');
        } else {
          name.innerHTML = name.textContent;
        }
      }
    });
  });

  noResults.classList.toggle('visible', !!q && !anyVisible);
}

function parseEnginePrefix(val) {
  const m = val.match(/^!(ddg|d|g|yt|gh|npm|pypi)\s+(.*)/i);
  if (!m) return null;
  const tag = m[1].toLowerCase();
  const q   = m[2];
  if (tag === 'd' || tag === 'ddg') return { engine: 'ddg',    query: q };
  if (tag === 'g')                  return { engine: 'google', query: q };
  if (tag === 'yt')                 return { engine: 'yt',     query: q };
  if (tag === 'gh')                 return { engine: 'gh',     query: q };
  if (tag === 'npm')                return { engine: 'npm',    query: q };
  if (tag === 'pypi')               return { engine: 'pypi',   query: q };
  return null;
}

searchEl.addEventListener('input', () => {
  const val    = searchEl.value;
  const parsed = parseEnginePrefix(val);
  if (parsed) {
    setEngine(parsed.engine);
    filterLinks(parsed.query);
  } else {
    setEngine('google');
    filterLinks(val);
  }
});

// ── HINT MODE ─────────────────────────────────────────────────────────────────
// NOTE: does NOT start with 'f' to avoid conflict with the hint-mode trigger key
const HINT_CHARS = 'jdkslagheiorutnmvwcybxzpqf';
const hintStatus = document.getElementById('hint-status');
let hintMode   = false;
let hintMap    = {};
let hintBuffer = '';

function enterHintMode() {
  hintMode   = true;
  hintMap    = {};
  hintBuffer = '';
  document.body.classList.add('hint-mode');
  hintStatus.classList.add('visible');

  const links = [...document.querySelectorAll(`.page[data-page="${currentPage}"] .link-item:not(.hidden)`)];
  links.forEach((link, i) => {
    const badge = link.querySelector('.hint-badge');
    if (!badge) return;
    const label = i < HINT_CHARS.length
      ? HINT_CHARS[i]
      : HINT_CHARS[Math.floor(i / HINT_CHARS.length) - 1] + HINT_CHARS[i % HINT_CHARS.length];
    badge.textContent = label.toUpperCase();
    hintMap[label] = link;
  });
}

function exitHintMode() {
  hintMode   = false;
  hintBuffer = '';
  document.body.classList.remove('hint-mode');
  hintStatus.classList.remove('visible');
  document.querySelectorAll('.hint-badge').forEach(b => { b.textContent = ''; });
}

function handleHintKey(key) {
  hintBuffer += key.toLowerCase();
  if (hintMap[hintBuffer]) {
    hintMap[hintBuffer].click();
    exitHintMode();
    return;
  }
  const hasPrefix = Object.keys(hintMap).some(k => k.startsWith(hintBuffer));
  if (!hasPrefix) exitHintMode();
}

// ── GLOBAL KEYBOARD ───────────────────────────────────────────────────────────
document.addEventListener('keydown', e => {
  const inInput = ['INPUT', 'TEXTAREA'].includes(document.activeElement.tagName);

  if (hintMode) {
    if (e.key === 'Escape') { exitHintMode(); return; }
    if (e.key.length === 1 && /[a-z]/i.test(e.key)) {
      e.preventDefault();
      handleHintKey(e.key);
    }
    return;
  }

  if (inInput) {
    if (e.key === 'Escape') {
      searchEl.blur();
      clearSearch();
    }
    if (e.key === 'Enter' && document.activeElement === searchEl) {
      const q = searchEl.value.trim();
      if (q) {
        const parsed = parseEnginePrefix(q);
        if (parsed) {
          window.location.href = ENGINES[parsed.engine](parsed.query);
        } else {
          const first = document.querySelector(`.page[data-page="${currentPage}"] .link-item:not(.hidden)`);
          if (first) {
            first.click();
          } else {
            window.location.href = ENGINES['google'](q);
          }
        }
        clearSearch();
        searchEl.blur();
      }
    }
    return;
  }

  switch (e.key) {
    case '/':
      e.preventDefault();
      searchEl.focus();
      searchEl.select();
      break;
    case 'f':
      e.preventDefault();
      enterHintMode();
      break;
    case 'Escape':
      clearSearch();
      break;
    case 't':
      e.preventDefault();
      applyTheme(html.getAttribute('data-theme') === 'dark' ? 'light' : 'dark');
      break;
    case 'p':
      e.preventDefault();
      pomoToggle();
      break;
    case 'r':
      e.preventDefault();
      refreshAllFeeds();
      break;
    case 'j':
      window.scrollBy({ top: 100, behavior: 'smooth' });
      break;
    case 'k':
      window.scrollBy({ top: -100, behavior: 'smooth' });
      break;
    case 'g':
      if (e.shiftKey) window.scrollTo({ top: document.body.scrollHeight, behavior: 'smooth' });
      else            window.scrollTo({ top: 0, behavior: 'smooth' });
      break;
    case '1': switchPage(0); break;
    case '2': switchPage(1); break;
    case '3': switchPage(2); break;
  }
});

// ── SERVICE STATUS CHECKS ─────────────────────────────────────────────────────
async function checkService(dotId, url, latId) {
  const dot   = document.getElementById(dotId);
  const latEl = latId ? document.getElementById(latId) : null;
  if (!dot) return;
  dot.className = 'status-dot checking';
  try {
    const ctrl  = new AbortController();
    const timer = setTimeout(() => ctrl.abort(), 3000);
    const t0    = performance.now();
    await fetch(url, { method: 'HEAD', mode: 'no-cors', signal: ctrl.signal });
    clearTimeout(timer);
    const ms = Math.round(performance.now() - t0);
    dot.className = 'status-dot up';
    if (latEl) latEl.textContent = `${ms}ms`;
  } catch {
    dot.className = 'status-dot down';
    if (latEl) latEl.textContent = '';
  }
}

function pollServices() {
  CONFIG.SERVICES.forEach(s => checkService(s.dotId, s.url, s.latId));
}

pollServices();
setInterval(pollServices, 30_000);

// ── POMODORO TIMER ────────────────────────────────────────────────────────────
let pomoPhaseIdx    = 0;
let pomoSecondsLeft = CONFIG.POMO_PHASES[0].duration;
let pomoRunning     = false;
let pomoInterval    = null;
let pomoSessions    = 0;

const pomoDisplay = document.getElementById('pomo-display');
const pomoPhaseEl = document.getElementById('pomo-phase');
const pomoBar     = document.getElementById('pomo-bar');
const pomoSessEl  = document.getElementById('pomo-sessions');

function pomoFmt(s) {
  const m  = Math.floor(s / 60);
  const ss = s % 60;
  return `${String(m).padStart(2,'0')}:${String(ss).padStart(2,'0')}`;
}

function pomoRender() {
  const phase = CONFIG.POMO_PHASES[pomoPhaseIdx];
  const pct   = (pomoSecondsLeft / phase.duration) * 100;
  pomoDisplay.textContent = pomoFmt(pomoSecondsLeft);
  pomoPhaseEl.textContent = phase.label;
  pomoBar.style.width     = pct + '%';

  let dots = '';
  for (let i = 0; i < 4; i++) {
    dots += `<span class="pomo-dot${i < pomoSessions ? ' done' : ''}"></span>`;
  }
  pomoSessEl.innerHTML = `Sessions: ${dots} (${pomoSessions}/4)`;

  document.getElementById('pomo-start').classList.toggle('active-btn', !pomoRunning);
  document.getElementById('pomo-pause').classList.toggle('active-btn', pomoRunning);
}

function pomoTick() {
  if (pomoSecondsLeft <= 0) {
    if (CONFIG.POMO_PHASES[pomoPhaseIdx].label === 'FOCUS') pomoSessions++;
    pomoPhaseIdx    = (pomoPhaseIdx + 1) % CONFIG.POMO_PHASES.length;
    pomoSecondsLeft = CONFIG.POMO_PHASES[pomoPhaseIdx].duration;
    showToast(`Pomodoro: ${CONFIG.POMO_PHASES[pomoPhaseIdx].label} — start!`);
  } else {
    pomoSecondsLeft--;
  }
  pomoRender();
}

function pomoToggle() {
  if (pomoRunning) {
    clearInterval(pomoInterval);
    pomoRunning = false;
  } else {
    pomoRunning  = true;
    pomoInterval = setInterval(pomoTick, 1000);
  }
  pomoRender();
}

function pomoReset() {
  clearInterval(pomoInterval);
  pomoRunning     = false;
  pomoSecondsLeft = CONFIG.POMO_PHASES[pomoPhaseIdx].duration;
  pomoRender();
}

function pomoSkip() {
  clearInterval(pomoInterval);
  if (CONFIG.POMO_PHASES[pomoPhaseIdx].label === 'FOCUS') pomoSessions++;
  pomoPhaseIdx    = (pomoPhaseIdx + 1) % CONFIG.POMO_PHASES.length;
  pomoSecondsLeft = CONFIG.POMO_PHASES[pomoPhaseIdx].duration;
  if (pomoRunning) pomoInterval = setInterval(pomoTick, 1000);
  showToast(`Skipped to: ${CONFIG.POMO_PHASES[pomoPhaseIdx].label}`);
  pomoRender();
}

document.getElementById('pomo-start').addEventListener('click', pomoToggle);
document.getElementById('pomo-pause').addEventListener('click', pomoToggle);
document.getElementById('pomo-reset').addEventListener('click', pomoReset);
document.getElementById('pomo-skip').addEventListener('click',  pomoSkip);

pomoRender();

// ── NOTES / SCRATCH PAD ───────────────────────────────────────────────────────
const notesArea     = document.getElementById('notes-area');
const notesChars    = document.getElementById('notes-chars');
const notesSaved    = document.getElementById('notes-saved');
const notesClearBtn = document.getElementById('notes-clear-btn');

notesArea.value = localStorage.getItem('scratch-notes') || '';
notesChars.textContent = `${notesArea.value.length} chars`;

let notesSaveTimer;
notesArea.addEventListener('input', () => {
  notesChars.textContent = `${notesArea.value.length} chars`;
  notesSaved.classList.remove('show');
  clearTimeout(notesSaveTimer);
  notesSaveTimer = setTimeout(() => {
    localStorage.setItem('scratch-notes', notesArea.value);
    notesSaved.classList.add('show');
    setTimeout(() => notesSaved.classList.remove('show'), 1500);
  }, 600);
});

notesClearBtn.addEventListener('click', () => {
  if (notesArea.value.length === 0) return;
  if (confirm('Clear scratch pad?')) {
    notesArea.value = '';
    localStorage.removeItem('scratch-notes');
    notesChars.textContent = '0 chars';
  }
});

// ── CALENDAR ──────────────────────────────────────────────────────────────────
let calDate = new Date();

function buildCalendar() {
  const now   = new Date();
  const year  = calDate.getFullYear();
  const month = calDate.getMonth();

  document.getElementById('cal-month-label').textContent = `${MONTHS_LONG[month]} ${year}`;

  const grid = document.getElementById('cal-grid');
  grid.innerHTML = '';

  ['Su','Mo','Tu','We','Th','Fr','Sa'].forEach(d => {
    const el = document.createElement('div');
    el.className = 'cal-dow';
    el.textContent = d;
    grid.appendChild(el);
  });

  const firstDay    = new Date(year, month, 1).getDay();
  const daysInMonth = new Date(year, month + 1, 0).getDate();
  const daysInPrev  = new Date(year, month, 0).getDate();

  for (let i = firstDay - 1; i >= 0; i--) {
    const el = document.createElement('div');
    el.className = 'cal-day other-month';
    el.textContent = daysInPrev - i;
    grid.appendChild(el);
  }

  for (let d = 1; d <= daysInMonth; d++) {
    const el      = document.createElement('div');
    el.className  = 'cal-day';
    const isToday = d === now.getDate() && month === now.getMonth() && year === now.getFullYear();
    if (isToday) el.classList.add('today');
    el.textContent = d;
    grid.appendChild(el);
  }

  const total     = firstDay + daysInMonth;
  const remainder = total % 7 === 0 ? 0 : 7 - (total % 7);
  for (let d = 1; d <= remainder; d++) {
    const el = document.createElement('div');
    el.className = 'cal-day other-month';
    el.textContent = d;
    grid.appendChild(el);
  }
}

document.getElementById('cal-prev').addEventListener('click', () => {
  calDate = new Date(calDate.getFullYear(), calDate.getMonth() - 1, 1);
  buildCalendar();
});
document.getElementById('cal-next').addEventListener('click', () => {
  calDate = new Date(calDate.getFullYear(), calDate.getMonth() + 1, 1);
  buildCalendar();
});

buildCalendar();

// ── WEATHER ───────────────────────────────────────────────────────────────────
// Persist unit preference
let weatherUseCelsius = localStorage.getItem('sp-weather-unit') !== 'F';
let weatherData       = null;

const WMO_ICONS = {
  0:'☀️', 1:'🌤', 2:'⛅', 3:'☁️',
  45:'🌫', 48:'🌫',
  51:'🌦', 53:'🌦', 55:'🌧',
  61:'🌧', 63:'🌧', 65:'🌧',
  71:'🌨', 73:'🌨', 75:'🌨',
  80:'🌦', 81:'🌧', 82:'⛈',
  95:'⛈', 96:'⛈', 99:'⛈',
};

const WMO_DESC = {
  0:'Clear sky', 1:'Mainly clear', 2:'Partly cloudy', 3:'Overcast',
  45:'Foggy', 48:'Icy fog',
  51:'Light drizzle', 53:'Drizzle', 55:'Dense drizzle',
  61:'Light rain', 63:'Rain', 65:'Heavy rain',
  71:'Light snow', 73:'Snow', 75:'Heavy snow',
  80:'Light showers', 81:'Showers', 82:'Heavy showers',
  95:'Thunderstorm', 96:'Thunderstorm + hail', 99:'Heavy thunderstorm',
};

function renderWeather() {
  const body = document.getElementById('weather-body');
  if (!weatherData) {
    body.innerHTML = '<div class="weather-loading">Could not load weather.</div>';
    return;
  }
  const d    = weatherData;
  const temp = weatherUseCelsius
    ? Math.round(d.current.temperature_2m) + '°C'
    : Math.round(d.current.temperature_2m * 9/5 + 32) + '°F';
  const fl   = weatherUseCelsius
    ? Math.round(d.current.apparent_temperature) + '°C'
    : Math.round(d.current.apparent_temperature * 9/5 + 32) + '°F';
  const wmo  = d.current.weather_code ?? 0;
  const icon = WMO_ICONS[wmo] ?? '🌡';
  const desc = WMO_DESC[wmo] ?? 'Unknown';
  const wind = Math.round(d.current.wind_speed_10m);
  const hum  = d.current.relative_humidity_2m;

  document.getElementById('weather-unit-btn').textContent = weatherUseCelsius ? '°C' : '°F';

  body.innerHTML = `
    <div class="weather-main">
      <div class="weather-icon">${icon}</div>
      <div class="weather-temp">${temp.replace(/[°CF]/g,'')}<span class="weather-unit">${weatherUseCelsius ? '°C' : '°F'}</span></div>
    </div>
    <div class="weather-desc">${desc}</div>
    <div class="weather-meta">
      <span>Feels like ${fl}</span>
      <span>Wind ${wind} km/h</span>
      <span>Humidity ${hum}%</span>
    </div>`;
}

async function fetchWeather() {
  document.getElementById('weather-body').innerHTML = '<div class="weather-loading">Fetching weather...</div>';
  try {
    const geoRes = await fetch('https://ipapi.co/json/');
    const geo    = await geoRes.json();
    const lat    = geo.latitude;
    const lon    = geo.longitude;
    const city   = geo.city || 'Your location';

    const url = `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}` +
      `&current=temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,wind_speed_10m` +
      `&timezone=auto`;
    const res  = await fetch(url);
    weatherData = await res.json();

    const title     = document.querySelector('#weather-reload-btn').closest('.card').querySelector('.card-title');
    const existCity = title.querySelector('.weather-city');
    if (!existCity) {
      const citySpan = document.createElement('span');
      citySpan.className = 'weather-city';
      citySpan.style.cssText = 'margin-left:4px;font-size:9.5px;letter-spacing:0.2px;text-transform:none;color:var(--text-faint);font-weight:400;';
      citySpan.textContent = city;
      title.appendChild(citySpan);
    }

    renderWeather();
  } catch {
    document.getElementById('weather-body').innerHTML =
      '<div class="weather-loading">Weather unavailable (no internet?)</div>';
  }
}

document.getElementById('weather-reload-btn').addEventListener('click', fetchWeather);
document.getElementById('weather-unit-btn').addEventListener('click', () => {
  weatherUseCelsius = !weatherUseCelsius;
  localStorage.setItem('sp-weather-unit', weatherUseCelsius ? 'C' : 'F');
  renderWeather();
});

fetchWeather();

// ── TODO WIDGET ───────────────────────────────────────────────────────────────
let todos = JSON.parse(localStorage.getItem('sp-todos') || '[]');

function saveTodos() {
  localStorage.setItem('sp-todos', JSON.stringify(todos));
}

function renderTodos() {
  const list  = document.getElementById('todo-list');
  const count = document.getElementById('todo-count');
  list.innerHTML = '';
  todos.forEach((t, i) => {
    const li = document.createElement('li');
    li.className = 'todo-item' + (t.done ? ' done' : '');
    li.innerHTML = `
      <input type="checkbox" class="todo-cb" ${t.done ? 'checked' : ''} data-i="${i}" />
      <span class="todo-text">${t.text.replace(/</g,'&lt;')}</span>
      <button class="todo-del" data-i="${i}" title="Delete">×</button>`;
    list.appendChild(li);
  });
  const total = todos.length;
  const done  = todos.filter(t => t.done).length;
  count.textContent = total === 0 ? 'No tasks' : `${done}/${total} done`;
}

function addTodo() {
  const inp  = document.getElementById('todo-input');
  const text = inp.value.trim();
  if (!text) return;
  todos.unshift({ text, done: false, id: Date.now() });
  saveTodos();
  renderTodos();
  inp.value = '';
}

document.getElementById('todo-add-btn').addEventListener('click', addTodo);
document.getElementById('todo-input').addEventListener('keydown', e => {
  if (e.key === 'Enter') addTodo();
});

document.getElementById('todo-list').addEventListener('change', e => {
  if (e.target.classList.contains('todo-cb')) {
    const i = +e.target.dataset.i;
    todos[i].done = e.target.checked;
    saveTodos();
    renderTodos();
  }
});

document.getElementById('todo-list').addEventListener('click', e => {
  const btn = e.target.closest('.todo-del');
  if (btn) {
    todos.splice(+btn.dataset.i, 1);
    saveTodos();
    renderTodos();
  }
});

document.getElementById('todo-clear-done-btn').addEventListener('click', () => {
  todos = todos.filter(t => !t.done);
  saveTodos();
  renderTodos();
  showToast('Cleared completed tasks');
});

renderTodos();

// ── COUNTDOWN TIMERS ──────────────────────────────────────────────────────────
let countdowns = JSON.parse(localStorage.getItem('sp-countdowns') || '[]');

function saveCountdowns() {
  localStorage.setItem('sp-countdowns', JSON.stringify(countdowns));
}

function daysUntil(dateStr) {
  const target = new Date(dateStr + 'T00:00:00');
  const now    = new Date();
  now.setHours(0, 0, 0, 0);
  return Math.round((target - now) / 86400000);
}

function renderCountdowns() {
  const list = document.getElementById('countdown-list');
  list.innerHTML = '';
  if (countdowns.length === 0) {
    list.innerHTML = '<li style="color:var(--text-faint);font-size:11px;padding:8px 0;">No countdowns yet</li>';
    return;
  }
  countdowns.forEach((cd, i) => {
    const days      = daysUntil(cd.date);
    const li        = document.createElement('li');
    li.className    = 'countdown-item';
    const daysClass = days < 0 ? 'countdown-days past' : 'countdown-days';
    const daysLabel = days === 0 ? 'Today!' : days < 0 ? `${Math.abs(days)}d ago` : `${days}d`;
    const subtitle  = days === 0 ? 'Today!' : days < 0 ? 'Past' : 'remaining';
    li.innerHTML = `
      <div class="countdown-info">
        <div class="countdown-event">${cd.name.replace(/</g,'&lt;')}</div>
        <div class="countdown-date-lbl">${cd.date}</div>
      </div>
      <div class="${daysClass}">${daysLabel}<div class="countdown-days-label">${subtitle}</div></div>
      <button class="countdown-del" data-i="${i}" title="Delete">×</button>`;
    list.appendChild(li);
  });
}

document.getElementById('cd-add-btn').addEventListener('click', () => {
  const name = document.getElementById('cd-name').value.trim();
  const date = document.getElementById('cd-date').value;
  if (!name || !date) { showToast('Enter both a name and date'); return; }
  countdowns.push({ name, date, id: Date.now() });
  countdowns.sort((a, b) => new Date(a.date) - new Date(b.date));
  saveCountdowns();
  renderCountdowns();
  document.getElementById('cd-name').value = '';
  document.getElementById('cd-date').value = '';
});

document.getElementById('countdown-list').addEventListener('click', e => {
  const btn = e.target.closest('.countdown-del');
  if (btn) {
    countdowns.splice(+btn.dataset.i, 1);
    saveCountdowns();
    renderCountdowns();
  }
});

renderCountdowns();

// ── HN HEADLINES ──────────────────────────────────────────────────────────────
function hnDomain(url) {
  try { return new URL(url).hostname.replace(/^www\./, ''); } catch { return ''; }
}

function renderHN(stories) {
  const body = document.getElementById('hn-body');
  body.innerHTML = stories.map((s, idx) => `
    <div class="hn-item">
      <span class="hn-num">${idx + 1}</span>
      <div>
        <a class="hn-link" href="${s.url || `https://news.ycombinator.com/item?id=${s.id}`}" target="_blank">${(s.title||'').replace(/</g,'&lt;')}</a>
        <div class="hn-meta">
          <span>${s.score} pts</span>
          ${s.url ? `<span>${hnDomain(s.url)}</span>` : ''}
          <a href="https://news.ycombinator.com/item?id=${s.id}" target="_blank" style="color:var(--text-faint);text-decoration:none;">${s.descendants||0} comments</a>
        </div>
      </div>
    </div>`).join('');
}

async function fetchHN() {
  const cached = cacheGet('cache-hn', CONFIG.CACHE_TTL.HN);
  if (cached) { renderHN(cached); return; }

  const body = document.getElementById('hn-body');
  body.innerHTML = '<div class="hn-loading">Loading stories…</div>';
  try {
    const ids    = await fetch('https://hacker-news.firebaseio.com/v0/topstories.json').then(r => r.json());
    const stories = await Promise.all(
      ids.slice(0, 10).map(id => fetch(`https://hacker-news.firebaseio.com/v0/item/${id}.json`).then(r => r.json()))
    );
    cacheSet('cache-hn', stories);
    renderHN(stories);
  } catch {
    body.innerHTML = '<div class="hn-loading">Could not load HN stories</div>';
  }
}

document.getElementById('hn-reload-btn').addEventListener('click', () => {
  localStorage.removeItem('cache-hn');
  fetchHN();
});
fetchHN();

// ── GITHUB ACTIVITY ───────────────────────────────────────────────────────────
const GH_EVENT_MAP = {
  PushEvent:         { icon: '⬆', label: e => `Pushed to ${e.repo.name.split('/')[1]}` },
  PullRequestEvent:  { icon: '⎇', label: e => `${e.payload.action} PR in ${e.repo.name.split('/')[1]}` },
  IssuesEvent:       { icon: '○', label: e => `${e.payload.action} issue in ${e.repo.name.split('/')[1]}` },
  WatchEvent:        { icon: '★', label: e => `Starred ${e.repo.name}` },
  ForkEvent:         { icon: '⑂', label: e => `Forked ${e.repo.name}` },
  CreateEvent:       { icon: '+', label: e => `Created ${e.payload.ref_type} in ${e.repo.name.split('/')[1]}` },
  DeleteEvent:       { icon: '−', label: e => `Deleted ${e.payload.ref_type} in ${e.repo.name.split('/')[1]}` },
  IssueCommentEvent: { icon: '💬', label: e => `Commented in ${e.repo.name.split('/')[1]}` },
  ReleaseEvent:      { icon: '🏷', label: e => `Released in ${e.repo.name.split('/')[1]}` },
  PublicEvent:       { icon: '🌐', label: e => `Made ${e.repo.name} public` },
};

function ghRelTime(isoStr) {
  const diff = (Date.now() - new Date(isoStr)) / 1000;
  if (diff < 60)    return 'just now';
  if (diff < 3600)  return `${Math.floor(diff/60)}m ago`;
  if (diff < 86400) return `${Math.floor(diff/3600)}h ago`;
  return `${Math.floor(diff/86400)}d ago`;
}

function renderGHActivity(events) {
  const body  = document.getElementById('gh-activity-body');
  const shown = events.slice(0, 10);
  body.innerHTML = shown.map(e => {
    const map    = GH_EVENT_MAP[e.type] || { icon: '•', label: ev => ev.type.replace('Event','') };
    const repoUrl = `https://github.com/${e.repo.name}`;
    return `<div class="gh-act-item">
      <span class="gh-act-icon">${map.icon}</span>
      <span class="gh-act-text">${map.label(e)} — <a href="${repoUrl}" target="_blank">${e.repo.name}</a></span>
      <span class="gh-act-time">${ghRelTime(e.created_at)}</span>
    </div>`;
  }).join('');
}

async function fetchGHActivity() {
  const cached = cacheGet('cache-gh-activity', CONFIG.CACHE_TTL.GH_ACTIVITY);
  if (cached) { renderGHActivity(cached); return; }

  const body = document.getElementById('gh-activity-body');
  body.innerHTML = '<div class="hn-loading">Loading activity…</div>';
  try {
    const res = await fetch(`https://api.github.com/users/${CONFIG.GH_USER}/events/public?per_page=15`);
    if (res.status === 403) {
      body.innerHTML = '<div class="hn-loading">GitHub API rate limit reached — try again later</div>';
      return;
    }
    const events = await res.json();
    if (!Array.isArray(events) || events.length === 0) {
      body.innerHTML = '<div class="hn-loading">No public activity found</div>';
      return;
    }
    cacheSet('cache-gh-activity', events);
    renderGHActivity(events);
  } catch {
    body.innerHTML = '<div class="hn-loading">Could not load GitHub activity</div>';
  }
}

document.getElementById('gh-reload-btn').addEventListener('click', () => {
  localStorage.removeItem('cache-gh-activity');
  fetchGHActivity();
});
fetchGHActivity();

// ── GITHUB CONTRIBUTION GRAPH ─────────────────────────────────────────────────
async function fetchContribGraph() {
  const cached = cacheGet('cache-gh-contrib', CONFIG.CACHE_TTL.CONTRIB);
  const wrap   = document.getElementById('contrib-wrap');
  const total  = document.getElementById('contrib-total');
  const banner = document.getElementById('gh-no-contrib-banner');

  function renderContribGraph(contributions) {
    const weeks = [];
    let week = [];
    contributions.forEach(day => {
      week.push(day);
      if (week.length === 7) { weeks.push(week); week = []; }
    });
    if (week.length) weeks.push(week);

    const totalCount = contributions.reduce((s, d) => s + d.count, 0);
    total.textContent = `${totalCount} contributions in the last year`;

    // Check today's contribution count
    const todayDate  = todayStr();
    const todayEntry = contributions.find(d => d.date === todayDate);
    if (banner) banner.classList.toggle('visible', !todayEntry || todayEntry.count === 0);

    const grid = document.createElement('div');
    grid.className = 'contrib-grid';
    weeks.forEach(w => {
      const col = document.createElement('div');
      col.className = 'contrib-col';
      w.forEach(d => {
        const cell = document.createElement('div');
        cell.className = 'contrib-cell';
        cell.dataset.level = d.level;
        cell.title = `${d.date}: ${d.count} contribution${d.count !== 1 ? 's' : ''}`;
        col.appendChild(cell);
      });
      grid.appendChild(col);
    });

    const legend = document.getElementById('contrib-legend');
    legend.innerHTML = '<span style="font-size:9.5px;color:var(--text-faint);margin-right:4px;">Less</span>';
    [0,1,2,3,4].forEach(lvl => {
      const c = document.createElement('div');
      c.className = 'contrib-legend-cell contrib-cell';
      c.dataset.level = lvl;
      legend.appendChild(c);
    });
    legend.innerHTML += '<span style="font-size:9.5px;color:var(--text-faint);margin-left:4px;">More</span>';

    wrap.innerHTML = '';
    wrap.appendChild(grid);
  }

  if (cached) { renderContribGraph(cached); return; }

  wrap.innerHTML = '<div class="hn-loading">Loading contributions…</div>';
  try {
    const data          = await fetch(`https://github-contributions-api.jogruber.de/v4/${CONFIG.GH_USER}?y=last`).then(r => r.json());
    const contributions = data.contributions;
    cacheSet('cache-gh-contrib', contributions);
    renderContribGraph(contributions);
  } catch {
    wrap.innerHTML = '<div class="hn-loading">Could not load contribution data</div>';
  }
}

fetchContribGraph();

// ── LEETCODE CONTRIBUTION GRAPH ───────────────────────────────────────────────
async function fetchLCContribGraph() {
  const cached = cacheGet('cache-lc-contrib', CONFIG.CACHE_TTL.CONTRIB);
  const wrap   = document.getElementById('lc-contrib-wrap');
  const meta   = document.getElementById('lc-contrib-meta');
  const banner = document.getElementById('lc-no-contrib-banner');

  function renderLCGraph(payload) {
    const { days, totalCount, streak } = payload;

    const nonZero = days.map(d => d.count).filter(c => c > 0).sort((a, b) => a - b);
    const p33 = nonZero[Math.floor(nonZero.length * 0.33)] || 1;
    const p66 = nonZero[Math.floor(nonZero.length * 0.66)] || 2;
    const maxC = nonZero[nonZero.length - 1] || 1;
    const getLevel = c => {
      if (c === 0) return 0;
      if (c <= p33) return 1;
      if (c <= p66) return 2;
      if (c < maxC) return 3;
      return 4;
    };

    // Check today's count
    const todayDate  = todayStr();
    const todayEntry = days.find(d => d.date === todayDate);
    if (banner) banner.classList.toggle('visible', !todayEntry || todayEntry.count === 0);

    const firstDow = new Date(days[0].date).getDay();
    const padded   = Array(firstDow).fill(null).concat(days);
    const weeks    = [];
    for (let i = 0; i < padded.length; i += 7) weeks.push(padded.slice(i, i + 7));

    meta.textContent = `${totalCount} submissions · streak ${streak ?? '?'}d`;

    const grid = document.createElement('div');
    grid.className = 'contrib-grid';
    weeks.forEach(w => {
      const col = document.createElement('div');
      col.className = 'contrib-col';
      w.forEach(d => {
        const cell = document.createElement('div');
        cell.className = 'contrib-cell';
        if (d) {
          cell.dataset.level = getLevel(d.count);
          cell.title = `${d.date}: ${d.count} submission${d.count !== 1 ? 's' : ''}`;
        } else {
          cell.style.opacity = '0';
          cell.style.pointerEvents = 'none';
        }
        col.appendChild(cell);
      });
      grid.appendChild(col);
    });

    const legend = document.getElementById('lc-contrib-legend');
    legend.innerHTML = '<span style="font-size:9.5px;color:var(--text-faint);margin-right:4px;">Less</span>';
    [0,1,2,3,4].forEach(lvl => {
      const c = document.createElement('div');
      c.className = 'contrib-legend-cell contrib-cell';
      c.dataset.level = lvl;
      legend.appendChild(c);
    });
    legend.innerHTML += '<span style="font-size:9.5px;color:var(--text-faint);margin-left:4px;">More</span>';

    wrap.innerHTML = '';
    wrap.appendChild(grid);
  }

  if (cached) { renderLCGraph(cached); return; }

  wrap.innerHTML = '<div class="hn-loading">Loading submissions…</div>';
  try {
    const data     = await fetch(`https://alfa-leetcode-api.onrender.com/${CONFIG.LC_USER}/calendar`).then(r => r.json());
    const calendar = JSON.parse(data.submissionCalendar || '{}');

    const todayUTC = new Date();
    const todayMs  = Date.UTC(todayUTC.getFullYear(), todayUTC.getMonth(), todayUTC.getDate());
    const days     = [];
    for (let i = 364; i >= 0; i--) {
      const ms      = todayMs - i * 86400000;
      const ts      = ms / 1000;
      const dateStr = new Date(ms).toISOString().slice(0, 10);
      days.push({ date: dateStr, count: calendar[ts] || 0 });
    }

    const totalCount = days.reduce((s, d) => s + d.count, 0);
    const payload    = { days, totalCount, streak: data.streak ?? null };
    cacheSet('cache-lc-contrib', payload);
    renderLCGraph(payload);
  } catch {
    wrap.innerHTML = '<div class="hn-loading">Could not load LeetCode data</div>';
  }
}

fetchLCContribGraph();

// ── REFRESH ALL FEEDS ─────────────────────────────────────────────────────────
function refreshAllFeeds() {
  localStorage.removeItem('cache-hn');
  localStorage.removeItem('cache-gh-activity');
  localStorage.removeItem('cache-gh-contrib');
  localStorage.removeItem('cache-lc-contrib');
  fetchHN();
  fetchGHActivity();
  fetchContribGraph();
  fetchLCContribGraph();
  fetchWeather();
  showToast('Feeds refreshed');
}

// ── COMMAND PALETTE ───────────────────────────────────────────────────────────
const cmdOverlay = document.getElementById('cmd-overlay');
const cmdInput   = document.getElementById('cmd-input');
const cmdResults = document.getElementById('cmd-results');

function buildCmdIndex() {
  const items = [];

  document.querySelectorAll('.link-item').forEach(el => {
    const name      = el.querySelector('.link-name')?.textContent || '';
    const desc      = el.querySelector('.link-desc')?.textContent || '';
    const href      = el.getAttribute('href') || '';
    const iconImg   = el.querySelector('.link-icon');
    const iconTxt   = el.querySelector('.link-icon-txt')?.textContent || '';
    const page      = el.closest('.card')?.dataset?.page ?? '';
    const pageLabel = page === '0' ? 'Life OS' : page === '1' ? 'Feeds' : 'Tools';
    items.push({ type: 'link', name, desc, href, iconImg: iconImg ? iconImg.src : null, iconTxt, tag: pageLabel });
  });

  const actions = [
    { type:'action', name:'Toggle Theme',      desc:'Switch dark/light mode',   iconTxt:'☾', action: () => themeBtn.click() },
    { type:'action', name:'Refresh All Feeds', desc:'Reload HN, GitHub, weather', iconTxt:'↻', action: refreshAllFeeds },
    { type:'action', name:'Page 1 — Life OS',  desc:'Switch to page 1',         iconTxt:'1', action: () => switchPage(0) },
    { type:'action', name:'Page 2 — Feeds',    desc:'Switch to page 2',         iconTxt:'2', action: () => switchPage(1) },
    { type:'action', name:'Page 3 — Tools',    desc:'Switch to page 3',         iconTxt:'3', action: () => switchPage(2) },
    { type:'action', name:'Start Pomodoro',     desc:'Start/pause focus timer',  iconTxt:'⏱', action: () => document.getElementById('pomo-start').click() },
  ];
  return [...items, ...actions];
}

let cmdIndex    = [];
let cmdSelected = -1;
let cmdFiltered = [];

function cmdScore(item, q) {
  const haystack = (item.name + ' ' + item.desc).toLowerCase();
  const needle   = q.toLowerCase();
  if (haystack.startsWith(needle)) return 2;
  if (haystack.includes(needle))   return 1;
  let hi = 0;
  for (const ch of needle) {
    hi = haystack.indexOf(ch, hi);
    if (hi === -1) return 0;
    hi++;
  }
  return 0.5;
}

function cmdHighlight(text, q) {
  if (!q) return text.replace(/</g,'&lt;');
  const safe = text.replace(/</g,'&lt;');
  const idx  = safe.toLowerCase().indexOf(q.toLowerCase());
  if (idx === -1) return safe;
  return safe.slice(0, idx) + `<mark>${safe.slice(idx, idx + q.length)}</mark>` + safe.slice(idx + q.length);
}

function renderCmdResults(q) {
  cmdSelected = -1;
  cmdFiltered = !q
    ? cmdIndex.slice(0, 8)
    : cmdIndex
        .map(item => ({ item, score: cmdScore(item, q) }))
        .filter(x => x.score > 0)
        .sort((a, b) => b.score - a.score)
        .slice(0, 12)
        .map(x => x.item);

  if (cmdFiltered.length === 0) {
    cmdResults.innerHTML = '<div style="padding:20px 16px;color:var(--text-faint);font-size:12px;text-align:center;">No results</div>';
    return;
  }

  cmdResults.innerHTML = cmdFiltered.map((item, i) => {
    const iconHtml = item.iconImg
      ? `<img class="cmd-item-img" src="${item.iconImg}" alt="" />`
      : `<div class="cmd-item-icon">${(item.iconTxt||'•').replace(/</g,'&lt;')}</div>`;
    return `<div class="cmd-item" data-i="${i}" tabindex="-1">
      ${iconHtml}
      <div class="cmd-item-text">
        <div class="cmd-item-name">${cmdHighlight(item.name, q)}</div>
        ${item.desc ? `<div class="cmd-item-sub">${item.desc.replace(/</g,'&lt;')}</div>` : ''}
      </div>
      ${item.tag ? `<div class="cmd-item-tag">${item.tag}</div>` : ''}
    </div>`;
  }).join('');
}

function cmdOpen() {
  cmdIndex = buildCmdIndex();
  cmdOverlay.classList.add('open');
  cmdInput.value = '';
  renderCmdResults('');
  requestAnimationFrame(() => cmdInput.focus());
}

function cmdClose() {
  cmdOverlay.classList.remove('open');
}

function cmdActivate(i) {
  const item = cmdFiltered[i];
  if (!item) return;
  cmdClose();
  if (item.type === 'link')        window.open(item.href, '_blank');
  else if (item.type === 'action') item.action();
}

function cmdMoveSelection(dir) {
  const items = cmdResults.querySelectorAll('.cmd-item');
  if (items.length === 0) return;
  items[cmdSelected]?.classList.remove('cmd-selected');
  cmdSelected = Math.max(0, Math.min(items.length - 1, cmdSelected + dir));
  items[cmdSelected].classList.add('cmd-selected');
  items[cmdSelected].scrollIntoView({ block: 'nearest' });
}

cmdInput.addEventListener('input', () => renderCmdResults(cmdInput.value.trim()));
cmdInput.addEventListener('keydown', e => {
  if (e.key === 'ArrowDown')  { e.preventDefault(); cmdMoveSelection(1); }
  else if (e.key === 'ArrowUp')   { e.preventDefault(); cmdMoveSelection(-1); }
  else if (e.key === 'Enter') { e.preventDefault(); cmdActivate(cmdSelected >= 0 ? cmdSelected : 0); }
  else if (e.key === 'Escape') cmdClose();
});
cmdResults.addEventListener('click', e => {
  const item = e.target.closest('.cmd-item');
  if (item) cmdActivate(+item.dataset.i);
});
cmdResults.addEventListener('mousemove', e => {
  const item = e.target.closest('.cmd-item');
  if (!item) return;
  cmdResults.querySelectorAll('.cmd-item').forEach(el => el.classList.remove('cmd-selected'));
  item.classList.add('cmd-selected');
  cmdSelected = +item.dataset.i;
});
cmdOverlay.addEventListener('click', e => { if (e.target === cmdOverlay) cmdClose(); });
document.addEventListener('keydown', e => {
  if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
    e.preventDefault();
    cmdOverlay.classList.contains('open') ? cmdClose() : cmdOpen();
  }
});
document.getElementById('bm-cmd-open').addEventListener('click', cmdOpen);

// ── SHORTCUTS POPUP ───────────────────────────────────────────────────────────
const shortcutsOverlay = document.getElementById('shortcuts-overlay');
const shortcutsTrigger = document.getElementById('shortcuts-trigger');
const shortcutsClose   = document.getElementById('shortcuts-modal-close');

function openShortcuts() {
  shortcutsOverlay.classList.add('open');
  shortcutsOverlay.setAttribute('aria-hidden', 'false');
  shortcutsClose.focus();
}

function closeShortcuts() {
  shortcutsOverlay.classList.remove('open');
  shortcutsOverlay.setAttribute('aria-hidden', 'true');
}

shortcutsTrigger.addEventListener('click', openShortcuts);
shortcutsClose.addEventListener('click', closeShortcuts);
shortcutsOverlay.addEventListener('click', e => { if (e.target === shortcutsOverlay) closeShortcuts(); });

document.addEventListener('keydown', e => {
  if (shortcutsOverlay.classList.contains('open')) {
    if (e.key === 'Escape') { e.preventDefault(); closeShortcuts(); }
    return;
  }
  if (['INPUT','TEXTAREA'].includes(document.activeElement.tagName)) return;
  if (e.key === '?') { e.preventDefault(); openShortcuts(); }
});

// ── DRAG-AND-DROP CARD REORDERING ─────────────────────────────────────────────
(function initDrag() {
  const grid     = document.getElementById('grid');
  const allCards = [...grid.querySelectorAll('.card.page')];
  allCards.forEach((card, i) => {
    if (!card.dataset.cardId) card.dataset.cardId = String(i);
  });

  for (let p = 0; p < 3; p++) {
    const saved = localStorage.getItem(`sp-card-order-${p}`);
    if (!saved) continue;
    const ids       = JSON.parse(saved);
    const pageCards = [...grid.querySelectorAll(`.card.page[data-page="${p}"]`)];
    const byId      = {};
    pageCards.forEach(c => { byId[c.dataset.cardId] = c; });
    const ordered   = ids.map(id => byId[id]).filter(Boolean);
    const remaining = pageCards.filter(c => !ids.includes(c.dataset.cardId));
    [...ordered, ...remaining].forEach(c => grid.appendChild(c));
  }

  let dragSrc     = null;
  let dragPage    = null;
  let placeholder = null;

  function createPlaceholder(refCard) {
    const ph = document.createElement('div');
    ph.className = 'card drag-placeholder';
    ph.style.cssText = `height:${refCard.offsetHeight}px;opacity:0.3;background:var(--accent);border-radius:10px;break-inside:avoid;margin-bottom:16px;`;
    return ph;
  }

  function saveOrder(pageIdx) {
    const cards = [...grid.querySelectorAll(`.card.page[data-page="${pageIdx}"]`)];
    localStorage.setItem(`sp-card-order-${pageIdx}`, JSON.stringify(cards.map(c => c.dataset.cardId)));
  }

  function getCardFromTarget(el) {
    while (el && el !== grid) {
      if (el.classList && el.classList.contains('card') && el.classList.contains('page')) return el;
      el = el.parentElement;
    }
    return null;
  }

  grid.addEventListener('dragstart', e => {
    const titleEl = e.target.closest ? e.target.closest('.card-title') : null;
    if (!titleEl) { e.preventDefault(); return; }
    const card = getCardFromTarget(titleEl);
    if (!card) { e.preventDefault(); return; }
    dragSrc  = card;
    dragPage = card.dataset.page;
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text/plain', card.dataset.cardId);
    placeholder = createPlaceholder(card);
    requestAnimationFrame(() => { card.style.opacity = '0.4'; });
  });

  grid.addEventListener('dragover', e => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
    const over = getCardFromTarget(e.target);
    if (!over || over === dragSrc || over === placeholder) return;
    if (over.dataset.page !== dragPage) return;

    // Use DOM order rather than clientY to decide insertion point.
    // CSS columns reflows cards visually, making clientY unreliable.
    const children = [...grid.children];
    const overIdx  = children.indexOf(over);
    const phIdx    = children.indexOf(placeholder);

    if (phIdx === -1 || phIdx > overIdx) {
      grid.insertBefore(placeholder, over);
    } else {
      grid.insertBefore(placeholder, over.nextSibling);
    }
  });

  grid.addEventListener('drop', e => {
    e.preventDefault();
    if (!dragSrc || !placeholder) return;
    grid.insertBefore(dragSrc, placeholder);
    placeholder.remove();
    placeholder = null;
    dragSrc.style.opacity = '';
    saveOrder(parseInt(dragPage, 10));
    dragSrc  = null;
    dragPage = null;
  });

  grid.addEventListener('dragend', () => {
    if (placeholder) { placeholder.remove(); placeholder = null; }
    if (dragSrc) { dragSrc.style.opacity = ''; dragSrc = null; }
    dragPage = null;
  });

  grid.querySelectorAll('.card.page .card-title').forEach(title => {
    title.setAttribute('draggable', 'true');
    title.style.cursor = 'grab';
  });
})();

// ── SERVICE WORKER REGISTRATION ───────────────────────────────────────────────
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('./sw.js').catch(() => {});
  });
}
