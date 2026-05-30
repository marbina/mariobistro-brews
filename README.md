# Mario Bistro Brews — Digital Menu System

> A full-stack restaurant menu and bar management system for Mario Bistro Brews, Orchard Park NY.
> Staff manage the menu live from any phone. Customers scan a QR code and see real-time updates.

---

## Live URLs

| URL | Purpose |
|-----|---------|
| `https://mariobistrobrews.com/menu` | Customer-facing menu page |
| `https://admin.mariobistrobrews.com` | Staff admin panel (PIN protected) |

---

## What this system does

### For customers
- Scan a QR code at the table or bar → full menu loads on their phone
- Browse Wine, Beer, Cocktails, Spirits, Food, N/A drinks
- See tonight's specials highlighted in gold
- 86'd items hidden automatically
- SEO-optimized text menu (replaces PDF — Google can now index your menu)

### For staff
- PIN-protected admin panel at `admin.mariobistrobrews.com`
- Add, edit, delete any menu item
- Toggle items as 86'd — disappears from customer menu instantly
- Mark items as Tonight's Special — gold badge appears on customer menu
- Update hours, phone, address, specials banner
- Works on any phone or tablet on the floor

---

## Tech stack

| Layer | Technology |
|-------|-----------|
| Customer menu page | HTML/CSS/JS — hosted on HostGator |
| WordPress CMS | Elementor Canvas template |
| Staff admin panel | Node.js + Express |
| Database | Supabase (hosted Postgres) |
| Server | DigitalOcean Droplet — Ubuntu 22.04 |
| Process manager | PM2 |
| Reverse proxy | Nginx |
| SSL | Let's Encrypt / Certbot (auto-renews) |
| DNS | Cloudflare |

---

## Project structure

```
mariobistro-brews/
├── README.md
├── .gitignore
├── customer/
│   └── demo.html              ← Customer menu page (upload to HostGator)
└── server/
    ├── server.js              ← Express API + auth + Supabase connection
    ├── package.json           ← Node dependencies
    ├── schema.sql             ← Supabase schema + full menu seed data
    ├── deploy.sh              ← One-shot DigitalOcean droplet setup
    ├── .env.example           ← Environment variable template
    └── public/
        └── index.html         ← Staff admin panel UI
```

---

## Infrastructure

### DigitalOcean Droplet
- **IP:** `159.203.143.149`
- **Size:** 1 vCPU / 1GB RAM / $6/mo
- **OS:** Ubuntu 22.04
- **App path:** `/var/www/mariobistro`
- **PM2 process name:** `mariobistro`

### Supabase
- **Project URL:** `https://vwfngwhgpjvwndufyzfz.supabase.co`
- **Tables:** `menu_items`, `wine_details`, `beer_details`, `site_settings`

### DNS (Cloudflare)
| Record | Type | Points to | Proxy |
|--------|------|-----------|-------|
| `admin` | A | `159.203.143.149` | DNS only (grey) |
| `@` | A | `192.254.236.166` | Proxied (HostGator) |

---

## Database schema

### menu_items
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | Primary key |
| category | text | wine / beer / cocktail / spirit / food / na / special |
| name | text | Item name |
| description | text | Tasting notes, ingredients |
| price | numeric | Per glass / per item |
| badge | text | e.g. Local, GF, Draft |
| available | boolean | False = 86'd, hidden from customers |
| is_special | boolean | True = gold badge on customer menu |
| sort_order | integer | Display order within category |

### site_settings
| Key | Default value |
|-----|--------------|
| hours | Wednesday – Saturday · 4:00pm – Close |
| kitchen_hours | Kitchen closes at 9:00pm · Wed – Sat |
| phone | (716) 740-8080 |
| email | mariobistrobrews@gmail.com |
| address | 4211 North Buffalo Rd · Orchard Park, NY 14127 |
| specials_banner | Ask your server about tonight's chef pairing |

---

## API endpoints

### Public (no auth required)
```
GET  /api/menu          → all available menu items
GET  /api/menu/wine     → wine items with wine_details joined
GET  /api/settings      → site settings (hours, phone, address)
```

### Admin (PIN session required)
```
POST   /api/auth/login           → { pin } → starts session
POST   /api/auth/logout          → clears session
GET    /api/auth/check           → { authed: true/false }

GET    /api/admin/items          → all items (including 86'd)
GET    /api/admin/items/:id      → single item
POST   /api/admin/items          → create item
PATCH  /api/admin/items/:id      → update item
DELETE /api/admin/items/:id      → delete item
PATCH  /api/admin/items/:id/toggle  → toggle available
PATCH  /api/admin/items/:id/special → toggle is_special
PATCH  /api/admin/settings       → update site settings
```

---

## Deploy from scratch

### 1. Supabase setup
1. Create a project at [supabase.com](https://supabase.com)
2. Go to **SQL Editor** → paste and run `server/schema.sql`
3. Go to **Settings → API** → copy your `anon` and `service_role` keys

### 2. DigitalOcean droplet
1. Create Ubuntu 22.04 droplet ($6/mo)
2. SSH in: `ssh root@YOUR_IP`
3. Upload files: `scp -r server/* root@YOUR_IP:/var/www/mariobistro/`
4. Create `.env` from `.env.example` and fill in your keys
5. Run: `cd /var/www/mariobistro && npm install && bash deploy.sh`

### 3. DNS
Add an A record in Cloudflare:
```
Type: A  |  Name: admin  |  Content: YOUR_DROPLET_IP  |  Proxy: DNS only
```

### 4. SSL
```bash
certbot --nginx -d admin.mariobistrobrews.com
```

### 5. HostGator
Upload `customer/demo.html` to `public_html/menu/` in HostGator File Manager.
In WordPress → create a page with slug `menu` → Elementor Canvas template → paste body content into HTML widget.

---

## PM2 commands (on droplet)

```bash
pm2 status                    # check all running processes
pm2 logs mariobistro          # live logs
pm2 restart mariobistro       # restart after code changes
pm2 stop mariobistro          # stop server
pm2 save                      # save process list
```

---

## Changing the PIN

**Option A** — Admin panel → Settings tab → Change PIN section

**Option B** — Update `.env` on the droplet:
```bash
nano /var/www/mariobistro/.env
# Change ADMIN_PIN=1234 to your new PIN
pm2 restart mariobistro
```

---

## Roadmap / next steps

- [ ] Wire customer menu (`demo.html`) to live Supabase API — currently static HTML
- [ ] Generate and print QR codes for tables and bar
- [ ] Add wine bottle pricing to customer menu
- [ ] Beer ABV display on customer menu
- [ ] Nightly specials auto-clear at midnight
- [ ] Photo upload per menu item
- [ ] PDF print version generated from live data
- [ ] Customer menu pulls from `/api/menu` on page load

---

## Contact

**Mario Bistro Brews**
4211 North Buffalo Rd · Orchard Park, NY 14127
(716) 740-8080 · mariobistrobrews@gmail.com
[mariobistrobrews.com](https://mariobistrobrews.com)
