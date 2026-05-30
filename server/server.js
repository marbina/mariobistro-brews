const express = require('express');
const session = require('express-session');
const cors    = require('cors');
const path    = require('path');

const app  = express();
const PORT = process.env.PORT || 3000;
const PIN  = process.env.ADMIN_PIN || '1234';

const SUPABASE_URL     = process.env.SUPABASE_URL     || 'https://vwfngwhgpjvwndufyzfz.supabase.co';
const SUPABASE_SERVICE = process.env.SUPABASE_SERVICE || '';

// ── Supabase fetch helper ──────────────────────────────────────────
async function sb(path, options = {}) {
  const url = `${SUPABASE_URL}/rest/v1${path}`;
  const res = await fetch(url, {
    ...options,
    headers: {
      'apikey':        SUPABASE_SERVICE,
      'Authorization': `Bearer ${SUPABASE_SERVICE}`,
      'Content-Type':  'application/json',
      'Prefer':        options.prefer || 'return=representation',
      ...(options.headers || {})
    }
  });
  if (!res.ok) {
    const err = await res.text();
    throw new Error(`Supabase error ${res.status}: ${err}`);
  }
  const text = await res.text();
  return text ? JSON.parse(text) : [];
}

// ── Middleware ─────────────────────────────────────────────────────
app.use(cors({ origin: ['https://mariobistrobrews.com', 'http://localhost'] }));
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));
app.use(session({
  secret: process.env.SESSION_SECRET || 'mbbrews-secret-2024',
  resave: false,
  saveUninitialized: false,
  cookie: { maxAge: 8 * 60 * 60 * 1000 } // 8 hours
}));

const requireAuth = (req, res, next) => {
  if (req.session.authed) return next();
  res.status(401).json({ error: 'Unauthorized' });
};

// ── PUBLIC API — customer menu reads ──────────────────────────────

// GET all available menu items (for customer page)
app.get('/api/menu', async (req, res) => {
  try {
    const items = await sb('/menu_items?available=eq.true&order=category,sort_order');
    res.json(items);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// GET site settings (hours, phone, address etc)
app.get('/api/settings', async (req, res) => {
  try {
    const rows = await sb('/site_settings?select=key,value');
    const settings = {};
    rows.forEach(r => settings[r.key] = r.value);
    res.json(settings);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// GET wine details joined
app.get('/api/menu/wine', async (req, res) => {
  try {
    const items = await sb('/menu_items?category=eq.wine&available=eq.true&order=sort_order&select=*,wine_details(*)');
    res.json(items);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ── AUTH ───────────────────────────────────────────────────────────
app.post('/api/auth/login', (req, res) => {
  const { pin } = req.body;
  if (pin === PIN) {
    req.session.authed = true;
    res.json({ ok: true });
  } else {
    res.status(401).json({ error: 'Wrong PIN' });
  }
});

app.post('/api/auth/logout', (req, res) => {
  req.session.destroy();
  res.json({ ok: true });
});

app.get('/api/auth/check', (req, res) => {
  res.json({ authed: !!req.session.authed });
});

// ── ADMIN API — requires PIN ───────────────────────────────────────

// GET all items (including unavailable)
app.get('/api/admin/items', requireAuth, async (req, res) => {
  try {
    const { category } = req.query;
    const filter = category ? `?category=eq.${category}&order=sort_order` : '?order=category,sort_order';
    const items = await sb(`/menu_items${filter}`);
    res.json(items);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// GET single item
app.get('/api/admin/items/:id', requireAuth, async (req, res) => {
  try {
    const items = await sb(`/menu_items?id=eq.${req.params.id}`);
    res.json(items[0] || null);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// POST create item
app.post('/api/admin/items', requireAuth, async (req, res) => {
  try {
    const item = await sb('/menu_items', {
      method: 'POST',
      body: JSON.stringify(req.body)
    });
    res.json(item[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// PATCH update item
app.patch('/api/admin/items/:id', requireAuth, async (req, res) => {
  try {
    const body = { ...req.body, updated_at: new Date().toISOString() };
    const item = await sb(`/menu_items?id=eq.${req.params.id}`, {
      method: 'PATCH',
      body: JSON.stringify(body)
    });
    res.json(item[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// DELETE item
app.delete('/api/admin/items/:id', requireAuth, async (req, res) => {
  try {
    await sb(`/menu_items?id=eq.${req.params.id}`, {
      method: 'DELETE',
      prefer: 'return=minimal'
    });
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// PATCH toggle available (86 item)
app.patch('/api/admin/items/:id/toggle', requireAuth, async (req, res) => {
  try {
    const current = await sb(`/menu_items?id=eq.${req.params.id}&select=available`);
    const newVal  = !current[0].available;
    await sb(`/menu_items?id=eq.${req.params.id}`, {
      method: 'PATCH',
      body: JSON.stringify({ available: newVal, updated_at: new Date().toISOString() })
    });
    res.json({ available: newVal });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// PATCH toggle special
app.patch('/api/admin/items/:id/special', requireAuth, async (req, res) => {
  try {
    const current = await sb(`/menu_items?id=eq.${req.params.id}&select=is_special`);
    const newVal  = !current[0].is_special;
    await sb(`/menu_items?id=eq.${req.params.id}`, {
      method: 'PATCH',
      body: JSON.stringify({ is_special: newVal, updated_at: new Date().toISOString() })
    });
    res.json({ is_special: newVal });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// PATCH update settings
app.patch('/api/admin/settings', requireAuth, async (req, res) => {
  try {
    const updates = req.body;
    for (const [key, value] of Object.entries(updates)) {
      await sb(`/site_settings?key=eq.${key}`, {
        method: 'PATCH',
        body: JSON.stringify({ value, updated_at: new Date().toISOString() })
      });
    }
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ── Serve admin panel ──────────────────────────────────────────────
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Mario Bistro admin running on port ${PORT}`);
});
