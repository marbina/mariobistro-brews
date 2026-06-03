# Mario Bistro Brews — Digital Menu System

Full-stack restaurant menu and bar management system for Mario Bistro Brews, Orchard Park NY.

## Live URLs
- Customer menu: https://mariobistrobrews.com/menu.html
- Staff admin: https://admin.mariobistrobrews.com
- API: https://admin.mariobistrobrews.com/api/menu

## Architecture
- HostGator — WordPress + menu.html
- DigitalOcean Droplet — 159.203.143.149, Express API + Admin panel
- Supabase — PostgreSQL database
- Cloudflare — DNS (admin subdomain grey cloud)
- PM2 — process manager (app: mariobistro)
- Nginx — reverse proxy port 3000

## Quick Commands
ssh root@159.203.143.149
cd /var/www/mariobistro
pm2 restart mariobistro
pm2 logs mariobistro --lines 50

## Support
See SUPPORT_PROMPT.md f
eof
