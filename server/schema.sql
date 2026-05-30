-- Mario Bistro Brews — Supabase Schema
-- Run this once in Supabase SQL Editor

-- Menu items table
create table if not exists menu_items (
  id          uuid primary key default gen_random_uuid(),
  category    text not null check (category in ('wine','beer','cocktail','spirit','food','na','special')),
  name        text not null,
  description text,
  price       numeric(8,2),
  badge       text,
  tags        text[],
  available   boolean default true,
  is_special  boolean default false,
  sort_order  integer default 0,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

-- Wine specific details
create table if not exists wine_details (
  id          uuid primary key references menu_items(id) on delete cascade,
  region      text,
  varietal    text,
  vintage     text,
  price_glass numeric(8,2),
  price_bottle numeric(8,2),
  wine_type   text check (wine_type in ('red','white','rose','sparkling'))
);

-- Beer specific details
create table if not exists beer_details (
  id          uuid primary key references menu_items(id) on delete cascade,
  style       text,
  abv         numeric(4,1),
  origin      text,
  serve_type  text check (serve_type in ('draft','bottle','can'))
);

-- Site settings (hours, specials banner, etc)
create table if not exists site_settings (
  key   text primary key,
  value text,
  updated_at timestamptz default now()
);

-- Insert default settings
insert into site_settings (key, value) values
  ('hours',           'Wednesday – Saturday · 4:00pm – Close'),
  ('kitchen_hours',   'Kitchen closes at 9:00pm · Wed – Sat'),
  ('phone',           '(716) 740-8080'),
  ('email',           'mariobistrobrews@gmail.com'),
  ('address',         '4211 North Buffalo Rd · Orchard Park, NY 14127'),
  ('specials_banner', 'Ask your server about tonight''s chef pairing')
on conflict (key) do nothing;

-- Seed wine items
insert into menu_items (category, name, description, price, badge, available, is_special, sort_order) values
  ('wine', 'Caymus Cabernet Sauvignon',    'Napa Valley · Full bodied, dark fruit, long silky finish',          22.00, null,  true, false, 1),
  ('wine', 'Meiomi Pinot Noir',            'California · Bright berry, silky tannins, strawberry & mocha',      14.00, null,  true, false, 2),
  ('wine', 'Decoy Merlot',                 'Sonoma County · Plum, black cherry, hint of chocolate',             13.00, null,  true, false, 3),
  ('wine', 'Rombauer Chardonnay',          'Carneros, CA · Buttery, vanilla oak, tropical fruit',               18.00, null,  true, false, 4),
  ('wine', 'Kim Crawford Sauvignon Blanc', 'Marlborough, NZ · Crisp citrus, fresh herb, grassy finish',         13.00, null,  true, false, 5),
  ('wine', 'Whispering Angel Rosé',        'Provence, France · Pale salmon, dry, wild strawberry & mineral',    17.00, null,  true, false, 6),
  ('wine', 'La Marca Prosecco',            'Veneto, Italy · Light, honeyed, golden apple & cream finish',       12.00, null,  true, false, 7);

-- Seed beer items
insert into menu_items (category, name, description, price, badge, available, is_special, sort_order) values
  ('beer', 'Guinness Draught',        'Dublin, Ireland · Roasted malt, coffee notes, cream finish',  9.00, 'Draft',  true, false, 1),
  ('beer', 'Southern Tier IPA',       'Lakewood, NY · Citrus forward, piney bitterness',             8.00, 'Local',  true, false, 2),
  ('beer', 'Blue Moon Belgian White', 'Golden, CO · Wheat ale, orange peel, coriander',              8.00, 'Draft',  true, false, 3),
  ('beer', 'Corona Extra',            'Mexico · Light, crisp, mild hop character',                   6.00, 'Bottle', true, false, 4),
  ('beer', 'Heineken',                'Netherlands · Pale lager, mild malt, clean finish',           6.00, 'Bottle', true, false, 5),
  ('beer', 'Flying Bison Rusty Chain','Buffalo, NY · Red ale, caramel malt, smooth',                 7.00, 'Local',  true, false, 6);

-- Seed cocktails
insert into menu_items (category, name, description, price, available, is_special, sort_order) values
  ('cocktail', 'Bistro Negroni',           'House-infused gin, Campari, sweet vermouth, expressed orange peel',                        14.00, true, false, 1),
  ('cocktail', 'Lavender Mule',            'Tito''s vodka, house lavender syrup, fresh lime, ginger beer, crystallized lavender rim',   13.00, true, false, 2),
  ('cocktail', 'Dark & Spicy Paloma',      'Mezcal, fresh grapefruit, jalapeño honey, Tajín rim, charred citrus',                      15.00, true, false, 3),
  ('cocktail', 'Aperol Spritz',            'Aperol, La Marca Prosecco, splash of soda, orange slice',                                  13.00, true, false, 4),
  ('cocktail', 'Espresso Martini',         'Vanilla vodka, Kahlúa, fresh-pulled espresso, three coffee beans',                         14.00, true, false, 5),
  ('cocktail', 'Garden Gimlet',            'St. Germain elderflower, cucumber, fresh lime, soda, mint sprig',                          12.00, true, false, 6);

-- Seed spirits
insert into menu_items (category, name, description, price, available, is_special, sort_order) values
  ('spirit', 'Bulleit Bourbon',      'High rye mash, spicy, oaky, hints of vanilla and dried fruit',         11.00, true, false, 1),
  ('spirit', 'Glenfiddich 12yr',     'Speyside single malt, pear, subtle oak, fresh and fruity finish',      14.00, true, false, 2),
  ('spirit', 'Patrón Silver',        '100% blue agave, crisp citrus, light pepper, smooth finish',           12.00, true, false, 3),
  ('spirit', 'Del Maguey Vida',      'Oaxaca, roasted agave, smoke, tropical fruit, mineral earthiness',     13.00, true, false, 4);

-- Seed food
insert into menu_items (category, name, description, price, badge, available, is_special, sort_order) values
  ('food', 'Truffle Parmesan Fries',  'Shoestring fries, black truffle oil, shaved parmesan, fresh herbs',                              12.00, null, true, false, 1),
  ('food', 'Charcuterie Board',       'Chef''s selection of cured meats, artisan cheeses, house pickles, whole grain mustard, crostini', 22.00, null, true, false, 2),
  ('food', 'Burrata & Heirloom',      'Fresh burrata, heirloom tomatoes, basil oil, flake salt, toasted sourdough',                     16.00, null, true, false, 3),
  ('food', 'Pan-Seared Salmon',       'Atlantic salmon, lemon beurre blanc, haricots verts, fingerling potatoes',                       28.00, null, true, false, 4),
  ('food', 'Bistro Burger',           '8oz house blend, aged cheddar, caramelized onion, bistro sauce, brioche bun, frites',            19.00, null, true, false, 5),
  ('food', 'Wild Mushroom Risotto',   'Arborio, mixed wild mushrooms, truffle oil, parmesan, fresh thyme · GF',                         22.00, 'GF', true, false, 6);

-- Seed N/A
insert into menu_items (category, name, description, price, available, is_special, sort_order) values
  ('na', 'Seedlip Spiced Sour',    'Seedlip Spice 94, fresh lemon, aquafaba foam, aromatic bitters',          9.00, true, false, 1),
  ('na', 'Cucumber Mint Cooler',   'Fresh cucumber, mint, elderflower, lime, sparkling water',                 7.00, true, false, 2),
  ('na', 'House Lemonade',         'Fresh-squeezed, honey sweetened · Ask about today''s flavor add-in',       5.00, true, false, 3);

-- Wine details
insert into wine_details (id, region, varietal, wine_type, price_glass, price_bottle)
select m.id,
  case m.name
    when 'Caymus Cabernet Sauvignon'    then 'Napa Valley, CA'
    when 'Meiomi Pinot Noir'            then 'California'
    when 'Decoy Merlot'                 then 'Sonoma County, CA'
    when 'Rombauer Chardonnay'          then 'Carneros, CA'
    when 'Kim Crawford Sauvignon Blanc' then 'Marlborough, NZ'
    when 'Whispering Angel Rosé'        then 'Provence, France'
    when 'La Marca Prosecco'            then 'Veneto, Italy'
  end,
  case m.name
    when 'Caymus Cabernet Sauvignon'    then 'Cabernet Sauvignon'
    when 'Meiomi Pinot Noir'            then 'Pinot Noir'
    when 'Decoy Merlot'                 then 'Merlot'
    when 'Rombauer Chardonnay'          then 'Chardonnay'
    when 'Kim Crawford Sauvignon Blanc' then 'Sauvignon Blanc'
    when 'Whispering Angel Rosé'        then 'Rosé Blend'
    when 'La Marca Prosecco'            then 'Glera'
  end,
  case m.name
    when 'Caymus Cabernet Sauvignon'    then 'red'
    when 'Meiomi Pinot Noir'            then 'red'
    when 'Decoy Merlot'                 then 'red'
    when 'Rombauer Chardonnay'          then 'white'
    when 'Kim Crawford Sauvignon Blanc' then 'white'
    when 'Whispering Angel Rosé'        then 'rose'
    when 'La Marca Prosecco'            then 'sparkling'
  end,
  m.price,
  case m.name
    when 'Caymus Cabernet Sauvignon'    then 88.00
    when 'Meiomi Pinot Noir'            then 52.00
    when 'Decoy Merlot'                 then 48.00
    when 'Rombauer Chardonnay'          then 70.00
    when 'Kim Crawford Sauvignon Blanc' then 48.00
    when 'Whispering Angel Rosé'        then 64.00
    when 'La Marca Prosecco'            then 44.00
  end
from menu_items m where m.category = 'wine';

-- Beer details
insert into beer_details (id, style, abv, origin, serve_type)
select m.id,
  case m.name
    when 'Guinness Draught'         then 'Irish Stout'
    when 'Southern Tier IPA'        then 'IPA'
    when 'Blue Moon Belgian White'  then 'Belgian Wheat'
    when 'Corona Extra'             then 'Lager'
    when 'Heineken'                 then 'Pale Lager'
    when 'Flying Bison Rusty Chain' then 'Red Ale'
  end,
  case m.name
    when 'Guinness Draught'         then 4.2
    when 'Southern Tier IPA'        then 6.8
    when 'Blue Moon Belgian White'  then 5.4
    when 'Corona Extra'             then 4.6
    when 'Heineken'                 then 5.0
    when 'Flying Bison Rusty Chain' then 5.5
  end,
  case m.name
    when 'Guinness Draught'         then 'Dublin, Ireland'
    when 'Southern Tier IPA'        then 'Lakewood, NY'
    when 'Blue Moon Belgian White'  then 'Golden, CO'
    when 'Corona Extra'             then 'Mexico'
    when 'Heineken'                 then 'Netherlands'
    when 'Flying Bison Rusty Chain' then 'Buffalo, NY'
  end,
  case m.name
    when 'Guinness Draught'        then 'draft'
    when 'Southern Tier IPA'       then 'draft'
    when 'Blue Moon Belgian White' then 'draft'
    when 'Corona Extra'            then 'bottle'
    when 'Heineken'                then 'bottle'
    when 'Flying Bison Rusty Chain'then 'bottle'
  end
from menu_items m where m.category = 'beer';

-- Row Level Security — allow public read, service role write
alter table menu_items   enable row level security;
alter table wine_details enable row level security;
alter table beer_details enable row level security;
alter table site_settings enable row level security;

create policy "Public read menu_items"    on menu_items   for select using (true);
create policy "Public read wine_details"  on wine_details for select using (true);
create policy "Public read beer_details"  on beer_details for select using (true);
create policy "Public read site_settings" on site_settings for select using (true);
