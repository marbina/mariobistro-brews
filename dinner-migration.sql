-- Mario Bistro Brews — Dinner Menu Migration
-- Run this in Supabase SQL Editor
-- Adds dinner categories to existing menu_items table

-- Update the category check constraint to include dinner categories
ALTER TABLE menu_items DROP CONSTRAINT IF EXISTS menu_items_category_check;
ALTER TABLE menu_items ADD CONSTRAINT menu_items_category_check 
  CHECK (category IN (
    'wine','beer','cocktail','spirit','food','na','special',
    'pizza','panini','small_plate','pasta','soup_salad',
    'dinner_special','brunch','beverage'
  ));

-- ── PIZZA ──────────────────────────────────────────────────────────
INSERT INTO menu_items (category, name, description, price, badge, available, is_special, sort_order) VALUES
  ('pizza', 'Margherita',      'Fresh mozzarella, sliced tomato, pesto',                                                                          12.50, null,        true, false, 1),
  ('pizza', 'The Gallo',       'Shredded mozzarella, ricotta cheese, hot Calabrese peppers, house red sauce, drizzled with EVOO',                  12.50, null,        true, false, 2),
  ('pizza', 'Meat Lovers',     'Choice of three: capicola, house made meatballs, sausage, pepperoni',                                             12.50, null,        true, false, 3),
  ('pizza', 'Pesto Chicken',   'Grilled chicken breast, pesto sauce, spinach, onion, garlic, and fresh mozzarella',                               12.50, null,        true, false, 4),
  ('pizza', 'Vegetarian',      'Zucchini, peppers, onions, mushrooms, and fresh mozzarella',                                                      12.50, 'Vegetarian', true, false, 5),
  ('pizza', 'White Garlic Aioli', 'Sauteed onions and garlic with melted mixed cheeses drizzled with EVOO',                                       12.50, null,        true, false, 6);

-- ── PANINIS ────────────────────────────────────────────────────────
INSERT INTO menu_items (category, name, description, price, badge, available, is_special, sort_order) VALUES
  ('panini', 'The Bronx',          'Stacked with the finest Italian deli meats: prosciutto parma, mortadella, capicola, olive tapenade, provolone cheese, roasted red pepper on ciabatta loaf, hot pressed',  20.00, 'Signature', true, false, 1),
  ('panini', 'La Mortadella',      'Fresh-cut mortadella, sun-dried tomato, pesto, arugula, fresh mozzarella on ciabatta loaf, hot pressed',                                                                   14.00, null,        true, false, 2),
  ('panini', 'The Fresco',         'Prosciutto, roasted red peppers, fresh mozzarella, pesto, hot pepper spread on ciabatta loaf, hot pressed',                                                                14.00, null,        true, false, 3),
  ('panini', 'Eggplant Caprese',   'Fried eggplant medallions, fresh tomato, mozzarella, pesto, balsamic glaze on ciabatta loaf, hot pressed',                                                                14.00, null,        true, false, 4),
  ('panini', 'Chicken Florentine', 'Grilled chicken breast with spinach and provolone cheese, balsamic glaze on ciabatta loaf, hot pressed',                                                                   16.00, null,        true, false, 5),
  ('panini', 'The Parma',          'Fried chicken breast or eggplant, prosciutto, provolone, tomato, house red sauce, pesto on ciabatta loaf, hot pressed',                                                   16.00, null,        true, false, 6),
  ('panini', 'Meatball Bomber',    'Mario''s famous meatballs with red sauce, ricotta cheese and hot pepper jam on a 6" roll',                                                                                 12.50, null,        true, false, 7),
  ('panini', 'Fried "Bologny"',    'Two thick slices of New Jersey-style pork roll, fried onions and roasted red pepper and cheese, on ciabatta roll, hot pressed',                                           12.00, null,        true, false, 8),
  ('panini', 'Build Your Own',     'Choice of tuna, chicken, ham or turkey on Costanza sub roll, served cold or hot pressed. Choice of lettuce, tomato, cheese. Add bacon $1.50',                             16.00, null,        true, false, 9);

-- ── SMALL PLATES ───────────────────────────────────────────────────
INSERT INTO menu_items (category, name, description, price, badge, available, is_special, sort_order) VALUES
  ('small_plate', 'Antipasto',              'Italian deli meats and cheeses served with dried fruits, nuts, and olives',                                                                              15.00, 'GF',   true, false, 1),
  ('small_plate', 'Arancini (3)',           'House-made fried risotto balls stuffed with traditional cheese and beef mix, served with house sauce and pesto',                                         10.00, null,   true, false, 2),
  ('small_plate', 'Meatball Aperitivo (3)', 'Mario''s house-made meatballs in red sauce, topped with grated parmesan, dollop of ricotta, served with a ciabatta roll',                              14.00, null,   true, false, 3),
  ('small_plate', 'Eggplant Stacker',       'Fried eggplant medallions layered with fresh mozzarella and tomato, accented with house pesto, served on a bed of greens',                             12.50, 'Veg',  true, false, 4),
  ('small_plate', 'Chicken Cutlet',         'Breaded and fried or pan seared, served with small plate or main course',                                                                               15.00, null,   true, false, 5),
  ('small_plate', 'Chicken Cutlet Parm',    'Breaded and fried chicken cutlet with red sauce and cheese',                                                                                            16.00, null,   true, false, 6),
  ('small_plate', 'Meatball in Red Sauce',  'Single house-made meatball in Mario''s red sauce',                                                                                                       4.00, null,   true, false, 7),
  ('small_plate', 'Sweet Potato Fries',     'House sweet potato fries',                                                                                                                               7.00, null,   true, false, 8);

-- ── PASTA ──────────────────────────────────────────────────────────
INSERT INTO menu_items (category, name, description, price, badge, available, is_special, sort_order) VALUES
  ('pasta', 'Pasta Your Way',    'Choose your pasta (spaghetti, fettuccine, penne, ravioli GF) and sauce (garden red, pesto, vodka, alfredo). GF pasta option +$3',   null, null, true, false, 1),
  ('pasta', 'Pasta as a Side',   'Any pasta with your choice of sauce served as a side',                                                                               5.00, null, true, false, 2);

-- ── SOUPS & SALADS ─────────────────────────────────────────────────
INSERT INTO menu_items (category, name, description, price, badge, available, is_special, sort_order) VALUES
  ('soup_salad', 'Seasonal Soup',           'Fresh made in house from Mario''s family recipes — ask your server for today''s selection',                                                     null,  null, true, false, 1),
  ('soup_salad', 'House Salad',             'Greens, red onion, tomato, served with our house balsamic vinaigrette',                                                                         5.00,  null, true, false, 2),
  ('soup_salad', 'Beet Salad',              'Sweet beets, peaches, clementines on mixed greens with goat cheese, walnuts, and balsamic dressing',                                           14.00, 'GF', true, false, 3),
  ('soup_salad', 'Calabrese Style Salad',   'Romaine lettuce, field greens, tomato, roasted red pepper, red onion, olives, and fresh mozzarella with house balsamic vinaigrette',           null,  null, true, false, 4),
  ('soup_salad', 'House Made Potato Salad', 'House made potato salad',                                                                                                                      4.00,  'GF', true, false, 5),
  ('soup_salad', 'House Made Pasta Salad',  'House made pasta salad',                                                                                                                       4.00,  null, true, false, 6);

-- ── DINNER SPECIALS ────────────────────────────────────────────────
INSERT INTO menu_items (category, name, description, price, badge, available, is_special, sort_order) VALUES
  ('dinner_special', 'Meat Special',        'Our weekly featured main course showcasing a meat or chicken dish — ask your server · Reservation recommended',       null, 'Weekly', true, true, 1),
  ('dinner_special', 'Fish Special',        'Our weekly special featuring the Chef''s fresh catch — ask your server · Reservation recommended',                    null, 'Weekly', true, true, 2),
  ('dinner_special', 'Vegetarian Special',  'Our weekly seasonal vegetarian creation — ask your server · Reservation recommended',                                  null, 'Weekly', true, true, 3);

-- ── BRUNCH ─────────────────────────────────────────────────────────
INSERT INTO menu_items (category, name, description, price, badge, available, is_special, sort_order) VALUES
  ('brunch', 'Classic Breakfast Sandwich', 'Two whole eggs scrambled on choice of bread & cheese. Add bacon, sausage or ham $1.50. GF wrap option',                   7.95,  'GF option', true, false, 1),
  ('brunch', 'Frittata',                   'Three egg omelette style with ricotta cheese, onion and your choice of zucchini or spinach. Your choice of bread',         12.00, 'GF option', true, false, 2),
  ('brunch', 'Breakfast Monster',          'Two eggs lightly scrambled, two thick slices of NJ style pork roll, on a ciabatta roll, choice of cheese. Add bacon $1.50', 11.00, null,       true, false, 3),
  ('brunch', 'The Sunnyside',              'Two fried eggplant medallions, tomato, pesto, fresh mozzarella on a bed of greens with a sunnyside up egg. Also served as a sandwich $14', 13.00, null, true, false, 4),
  ('brunch', '10" Breakfast Pizza',        'Fresh made in house dough, scrambled egg, bacon, sausage, two kinds of cheese in a light maple syrup',                     16.00, null,        true, false, 5),
  ('brunch', 'Mamma''s Breakfast',         'Choose 4: bacon, sausage, ham, mortadella, prosciutto, fresh mozzarella, ricotta cheese, seasonal fruit. Add two eggs $3', 12.00, null,        true, false, 6);

-- ── BEVERAGES ──────────────────────────────────────────────────────
INSERT INTO menu_items (category, name, description, price, badge, available, is_special, sort_order) VALUES
  ('beverage', 'Drip Coffee',            'House drip coffee',                                                    2.50, null, true, false, 1),
  ('beverage', 'Espresso',               'Single $3 · Double $4',                                               3.00, null, true, false, 2),
  ('beverage', 'Cappuccino / Latte',     'Espresso with steamed milk',                                          4.75, null, true, false, 3),
  ('beverage', 'Americano',              'Espresso with hot water',                                             4.00, null, true, false, 4),
  ('beverage', 'French Press Pot',       '2–3 cups',                                                            8.00, null, true, false, 5),
  ('beverage', 'Fountain Soda',          'Ask your server for available selections',                            3.00, null, true, false, 6),
  ('beverage', 'Bottled Drinks',         'Assorted bottled beverages',                                          2.50, null, true, false, 7),
  ('beverage', 'Orange or Apple Juice',  'Fresh pressed',                                                       3.00, null, true, false, 8),
  ('beverage', 'Mimosas',                'Single $8 · 200ml bottle $14 · $25 bottomless with morning favorite', 8.00, null, true, false, 9);

-- Update RLS policy to include new categories (already public read)
-- No changes needed — existing policy covers all rows
