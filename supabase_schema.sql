-- Run this in Supabase Dashboard → SQL Editor

create table if not exists couple_sessions (
  id          uuid primary key default gen_random_uuid(),
  invite_code text unique not null,
  entry_type  text not null,         -- 'partner' | 'self'
  answers_a   jsonb,                 -- creator's answers: { "c1": true, "b2": false, ... }
  answers_b   jsonb,                 -- partner's answers
  created_at  timestamptz default now()
);

-- Enable realtime for live sync
alter publication supabase_realtime add table couple_sessions;

-- Anyone can create / read / update sessions (no auth for MVP)
alter table couple_sessions enable row level security;

create policy "Anyone can insert"
  on couple_sessions for insert
  with check (true);

create policy "Anyone can read by invite code"
  on couple_sessions for select
  using (true);

create policy "Anyone can update answers"
  on couple_sessions for update
  using (true);

-- Auto-delete sessions older than 7 days (keep it clean)
-- Requires pg_cron extension — enable in Supabase Dashboard → Extensions if needed
-- select cron.schedule('cleanup-sessions', '0 3 * * *',
--   $$ delete from couple_sessions where created_at < now() - interval '7 days' $$);
