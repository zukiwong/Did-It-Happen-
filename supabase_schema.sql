-- Run this in Supabase Dashboard → SQL Editor
-- ============================================================
-- TABLE: investigation_records
-- End-to-end encrypted investigation records.
-- Server cannot read payload — only the user with the passphrase can.
--
-- id      = SHA-256(user passphrase), hex string (64 chars)
-- payload = AES-256-GCM encrypted JSON, base64 encoded
--           Decrypted content: { results, evidences, entry_type, completed_at }
-- ============================================================
create table if not exists investigation_records (
  id         text primary key,           -- SHA-256(passphrase), not the passphrase itself
  payload    text not null,              -- AES-256-GCM ciphertext, base64
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- RLS: anyone can read/write by id — the id itself is the protection layer
-- (Without knowing the passphrase you cannot compute the id to look it up)
alter table investigation_records enable row level security;

create policy "Anyone can insert investigation record"
  on investigation_records for insert
  with check (true);

create policy "Anyone can read investigation record by id"
  on investigation_records for select
  using (true);

create policy "Anyone can update investigation record by id"
  on investigation_records for update
  using (true);

-- Auto-update updated_at on change
create or replace function update_investigation_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace trigger investigation_records_updated_at
  before update on investigation_records
  for each row execute function update_investigation_updated_at();

-- ============================================================
-- Storage bucket: evidence-files (create manually in Dashboard)
-- Naming convention: {first 8 chars of record id}_{uuid}.enc
-- Files are client-side AES-256-GCM encrypted before upload
-- ============================================================

-- ============================================================

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
