-- =============================================
-- Street League - Supabase Schema
-- הרץ את כל הקובץ הזה ב-SQL Editor של Supabase
-- =============================================

-- Leagues (קבוצות / ליגות)
create table if not exists leagues (
  slug       text primary key,
  name       text not null,
  pin_hash   text not null,
  created_at timestamptz default now()
);

-- Players (שחקנים)
create table if not exists players (
  id                 text primary key,
  league_id          text not null references leagues(slug) on delete cascade,
  name               text not null,
  photo              text default '',
  preferred_position text default 'MID',
  strong_foot        text default 'right',
  rating             integer default 1000,
  skills             jsonb default '{"pace":50,"shooting":50,"passing":50,"dribbling":50,"defending":50,"physical":50,"vision":50,"finishing":50}',
  stats              jsonb default '{"games":0,"wins":0,"losses":0,"draws":0,"goals":0}',
  created_at         timestamptz default now(),
  updated_at         timestamptz default now()
);

-- Matches (משחקים)
create table if not exists matches (
  id                  text primary key,
  league_id           text not null references leagues(slug) on delete cascade,
  date                timestamptz default now(),
  team_a_score        integer default 0,
  team_b_score        integer default 0,
  team_a_player_ids   jsonb default '[]',
  team_b_player_ids   jsonb default '[]',
  bench_player_id     text,
  created_at          timestamptz default now()
);

-- Match Players (סטטיסטיקות לשחקן לפי משחק)
create table if not exists match_players (
  id            text primary key,
  match_id      text not null references matches(id) on delete cascade,
  player_id     text not null references players(id) on delete cascade,
  league_id     text not null references leagues(slug) on delete cascade,
  team          text,
  goals         integer default 0,
  rating_before integer,
  rating_change integer,
  rating_after  integer
);

-- Rating History (היסטוריית דירוג)
create table if not exists rating_history (
  id            text primary key,
  player_id     text not null references players(id) on delete cascade,
  match_id      text references matches(id) on delete set null,
  league_id     text not null references leagues(slug) on delete cascade,
  date          timestamptz default now(),
  rating_before integer,
  rating_change integer,
  rating_after  integer,
  reason        text
);

-- =============================================
-- Row Level Security (RLS)
-- מאפשר גישה מלאה למפתח ה-anon (הציבורי)
-- האבטחה מתבצעת ברמת האפליקציה עם PIN
-- =============================================
alter table leagues       enable row level security;
alter table players       enable row level security;
alter table matches       enable row level security;
alter table match_players enable row level security;
alter table rating_history enable row level security;

create policy "anon_all" on leagues        for all to anon using (true) with check (true);
create policy "anon_all" on players        for all to anon using (true) with check (true);
create policy "anon_all" on matches        for all to anon using (true) with check (true);
create policy "anon_all" on match_players  for all to anon using (true) with check (true);
create policy "anon_all" on rating_history for all to anon using (true) with check (true);
