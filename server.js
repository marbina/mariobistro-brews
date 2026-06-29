const express = require('express');
const session = require('express-session');
const cors    = require('cors');
const path    = require('path');

const app  = express();
const PORT = process.env.PORT || 3000;
const PIN  = process.env.ADMIN_PIN || '1234';

const SUPABASE_URL     = process.env.SUPABASE_URL     || 'https://vwfngwhgpjvwndufyzfz.supabase.co';
const SUPABASE_SERVICE = process.env.SUPABASE_SERVICE || '';

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

app.use('/api/menu',     cors({origin: '*'}));
app.use('/api/dinner',   cors({origin: '*'}));
app.use('/api/specials', cors({origin: '*'}));
app.use('/api/settings', cors({origin: '*'}));
app.use('/api/vendors',  cors({origin: '*'}));
app.use('/api/stories',  cors({origin: '*'}));
app.use('/api/recipes',  cors({origin: '*'}));

app.use(cors({
  origin: [
    'https://admin.mariobistrobrews.com',
    'https://mariobistrobrews.com',
    'https://www.mariobistrobrews.com',
    'http://localhost'
  ],
  credentials: true
}));
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));
app.use(session({
  secret: process.env.SESSION_SECRET || 'mbbrews-secret-2024',
  resave: false,
  saveUninitialized: false,
  cookie: { maxAge: 8 * 60 * 60 * 1000 }
}));

const requireAuth = (req, res, next) => {
  if (req.session.authed) return next();
  res.status(401).json({ error: 'Unauthorized' });
};

// ── PUBLIC VENDORS ────────────────────────────────────────────────
app.get('/api/vendors', async (req, res) => {
  try {
    const vendors = await sb('/vendors?active=eq.true&order=display_order.asc');
    res.json(vendors);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ── VENDOR CRUD ───────────────────────────────────────────────────
app.post('/api/admin/vendors', requireAuth, async (req, res) => {
  try {
    const response = await fetch(SUPABASE_URL + '/rest/v1/vendors', {
      method: 'POST',
      headers: { 'apikey': SUPABASE_SERVICE, 'Authorization': 'Bearer ' + SUPABASE_SERVICE, 'Content-Type': 'application/json', 'Prefer': 'return=representation' },
      body: JSON.stringify(req.body)
    });
    res.json(await response.json());
  } catch(e) { res.status(500).json({ error: e.message }); }
});

app.put('/api/admin/vendors/:id', requireAuth, async (req, res) => {
  try {
    const response = await fetch(SUPABASE_URL + '/rest/v1/vendors?id=eq.' + req.params.id, {
      method: 'PATCH',
      headers: { 'apikey': SUPABASE_SERVICE, 'Authorization': 'Bearer ' + SUPABASE_SERVICE, 'Content-Type': 'application/json', 'Prefer': 'return=representation' },
      body: JSON.stringify(req.body)
    });
    res.json(await response.json());
  } catch(e) { res.status(500).json({ error: e.message }); }
});

app.delete('/api/admin/vendors/:id', requireAuth, async (req, res) => {
  try {
    await fetch(SUPABASE_URL + '/rest/v1/vendors?id=eq.' + req.params.id, {
      method: 'DELETE',
      headers: { 'apikey': SUPABASE_SERVICE, 'Authorization': 'Bearer ' + SUPABASE_SERVICE }
    });
    res.json({ success: true });
  } catch(e) { res.status(500).json({ error: e.message }); }
});

// ── PUBLIC STORIES ────────────────────────────────────────────────
app.post('/api/stories', async (req, res) => {
  try {
    const { category, story, dish_name, name, phone } = req.body;
    if (!story || !story.trim()) return res.status(400).json({ error: 'Story is required' });
    const display_name = name ? name.trim().split(' ')[0] : null;
    const record = {
      category: category || 'other',
      story: story.trim(),
      dish_name: dish_name || null,
      name: name || null,
      display_name,
      phone: phone || null,
      status: 'pending'
    };
    const result = await sb('/customer_stories', { method: 'POST', body: JSON.stringify(record) });
    res.json({ ok: true, id: result[0]?.id });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.get('/api/stories/featured', async (req, res) => {
  try {
    const now = new Date().toISOString();
    const stories = await sb(`/customer_stories?status=eq.approved&or=(expires_at.is.null,expires_at.gt.${now})&order=created_at.desc&limit=10`);
    res.json(stories);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.get('/api/stories/homepage', async (req, res) => {
  try {
    const now = new Date().toISOString();
    const stories = await sb(`/customer_stories?status=eq.approved&show_on_homepage=eq.true&or=(expires_at.is.null,expires_at.gt.${now})&order=created_at.desc&limit=10`);
    res.json(stories);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ── ADMIN STORIES ─────────────────────────────────────────────────
app.get('/api/admin/stories', requireAuth, async (req, res) => {
  try {
    const { status, category } = req.query;
    let filter = '?order=created_at.desc';
    if (status && status !== 'all')     filter += `&status=eq.${status}`;
    if (category && category !== 'all') filter += `&category=eq.${category}`;
    res.json(await sb(`/customer_stories${filter}`));
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.patch('/api/admin/stories/:id', requireAuth, async (req, res) => {
  try {
    const result = await sb(`/customer_stories?id=eq.${req.params.id}`, {
      method: 'PATCH', body: JSON.stringify(req.body)
    });
    res.json(result[0] || { ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.delete('/api/admin/stories/:id', requireAuth, async (req, res) => {
  try {
    await sb(`/customer_stories?id=eq.${req.params.id}`, { method: 'DELETE', prefer: 'return=minimal' });
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ── PUBLIC RECIPES ────────────────────────────────────────────────
app.get('/api/recipes', async (req, res) => {
  try {
    const recipes = await sb('/recipes?active=eq.true&order=created_at.desc');
    res.json(recipes);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.get('/api/recipes/:id', async (req, res) => {
  try {
    const recipes = await sb(`/recipes?id=eq.${req.params.id}&active=eq.true`);
    res.json(recipes[0] || null);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.get('/api/recipes/by-item/:itemId', async (req, res) => {
  try {
    const recipes = await sb(`/recipes?menu_item_id=eq.${req.params.itemId}&active=eq.true`);
    res.json(recipes[0] || null);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ── ADMIN RECIPES ─────────────────────────────────────────────────
app.get('/api/admin/recipes', requireAuth, async (req, res) => {
  try {
    res.json(await sb('/recipes?order=created_at.desc'));
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.get('/api/admin/recipes/:id', requireAuth, async (req, res) => {
  try {
    const recipes = await sb(`/recipes?id=eq.${req.params.id}`);
    res.json(recipes[0] || null);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.post('/api/admin/recipes', requireAuth, async (req, res) => {
  try {
    const result = await sb('/recipes', { method: 'POST', body: JSON.stringify(req.body) });
    res.json(result[0]);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.patch('/api/admin/recipes/:id', requireAuth, async (req, res) => {
  try {
    const body = { ...req.body, updated_at: new Date().toISOString() };
    const result = await sb(`/recipes?id=eq.${req.params.id}`, { method: 'PATCH', body: JSON.stringify(body) });
    res.json(result[0]);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.delete('/api/admin/recipes/:id', requireAuth, async (req, res) => {
  try {
    await sb(`/recipes?id=eq.${req.params.id}`, { method: 'DELETE', prefer: 'return=minimal' });
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ── Category groups ───────────────────────────────────────────────
const BAR_CATEGORIES = ['wine','beer','cocktail','spirit','na','special','canned','lunch_pizza','lunch_panini','lunch_small_plate','lunch_soup_salad','dinner_special','dinner_pasta','dinner_pizza','dinner_small_plate','brunch','beverage'];
const DINNER_CATEGORIES = ['pizza','panini','small_plate','pasta','soup_salad','dinner_special','brunch','beverage'];

// ── PUBLIC MENU API ───────────────────────────────────────────────
app.get('/api/menu', async (req, res) => {
  try {
    const cats = BAR_CATEGORIES.map(c => `category.eq.${c}`).join(',');
    res.json(await sb(`/menu_items?or=(${cats})&available=eq.true&order=category,sort_order`));
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.get('/api/dinner', async (req, res) => {
  try {
    const cats = DINNER_CATEGORIES.map(c => `category.eq.${c}`).join(',');
    res.json(await sb(`/menu_items?or=(${cats})&available=eq.true&order=category,sort_order`));
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.get('/api/menu/:category', async (req, res) => {
  try {
    res.json(await sb(`/menu_items?category=eq.${req.params.category}&available=eq.true&order=sort_order`));
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.get('/api/specials', async (req, res) => {
  try {
    res.json(await sb(`/menu_items?is_special=eq.true&available=eq.true&order=category,sort_order`));
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.get('/api/settings', async (req, res) => {
  try {
    const rows = await sb('/site_settings?select=key,value');
    const settings = {};
    rows.forEach(r => settings[r.key] = r.value);
    res.json(settings);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ── AUTH ──────────────────────────────────────────────────────────
app.post('/api/auth/login', (req, res) => {
  const { pin } = req.body;
  if (pin === PIN) { req.session.authed = true; res.json({ ok: true }); }
  else res.status(401).json({ error: 'Wrong PIN' });
});

app.post('/api/auth/logout', (req, res) => { req.session.destroy(); res.json({ ok: true }); });
app.get('/api/auth/check', (req, res) => { res.json({ authed: !!req.session.authed }); });

// ── ADMIN ITEMS ───────────────────────────────────────────────────
app.get('/api/admin/items', requireAuth, async (req, res) => {
  try {
    const { category, menu } = req.query;
    let filter = '?order=category,sort_order';
    if (category) {
      filter = `?category=eq.${category}&order=sort_order`;
    } else if (menu === 'bar') {
      const cats = BAR_CATEGORIES.map(c => `category.eq.${c}`).join(',');
      filter = `?or=(${cats})&order=category,sort_order`;
    } else if (menu === 'dinner') {
      const cats = DINNER_CATEGORIES.map(c => `category.eq.${c}`).join(',');
      filter = `?or=(${cats})&order=category,sort_order`;
    }
    res.json(await sb(`/menu_items${filter}`));
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.get('/api/admin/items/:id', requireAuth, async (req, res) => {
  try {
    const items = await sb(`/menu_items?id=eq.${req.params.id}`);
    res.json(items[0] || null);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.post('/api/admin/items', requireAuth, async (req, res) => {
  try {
    const item = await sb('/menu_items', { method: 'POST', body: JSON.stringify(req.body) });
    res.json(item[0]);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.patch('/api/admin/items/:id', requireAuth, async (req, res) => {
  try {
    const body = { ...req.body, updated_at: new Date().toISOString() };
    const item = await sb(`/menu_items?id=eq.${req.params.id}`, { method: 'PATCH', body: JSON.stringify(body) });
    res.json(item[0]);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.delete('/api/admin/items/:id', requireAuth, async (req, res) => {
  try {
    await sb(`/menu_items?id=eq.${req.params.id}`, { method: 'DELETE', prefer: 'return=minimal' });
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.patch('/api/admin/items/:id/toggle', requireAuth, async (req, res) => {
  try {
    const current = await sb(`/menu_items?id=eq.${req.params.id}&select=available`);
    const newVal = !current[0].available;
    await sb(`/menu_items?id=eq.${req.params.id}`, { method: 'PATCH', body: JSON.stringify({ available: newVal, updated_at: new Date().toISOString() }) });
    res.json({ available: newVal });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.patch('/api/admin/items/:id/special', requireAuth, async (req, res) => {
  try {
    const current = await sb(`/menu_items?id=eq.${req.params.id}&select=is_special`);
    const newVal = !current[0].is_special;
    await sb(`/menu_items?id=eq.${req.params.id}`, { method: 'PATCH', body: JSON.stringify({ is_special: newVal, updated_at: new Date().toISOString() }) });
    res.json({ is_special: newVal });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.patch('/api/admin/settings', requireAuth, async (req, res) => {
  try {
    for (const [key, value] of Object.entries(req.body)) {
      await sb(`/site_settings?key=eq.${key}`, { method: 'PATCH', body: JSON.stringify({ value, updated_at: new Date().toISOString() }) });
    }
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Mario Bistro admin running on port ${PORT}`);
});
