-- AEC Coach initial schema. Every table: RLS on, default deny, owner policies.

create type user_role as enum ('client', 'coach');
create type goal_type as enum ('gain', 'lose', 'maintain');
create type tier_type as enum ('free', 'self_guided', 'coached');
create type rec_status as enum ('pending', 'approved', 'shown', 'dismissed');

-- Helper: is the current user a coach
create or replace function public.is_coach()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles p
    where p.user_id = auth.uid() and p.role = 'coach'
  );
$$;

create table public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role user_role not null default 'client',
  display_name text,
  goal goal_type,
  training_days smallint check (training_days between 1 and 7),
  equipment text[],
  limits text,
  sitting_hours smallint check (sitting_hours between 0 and 20),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.profiles enable row level security;
create policy "profiles: own read" on public.profiles for select using (auth.uid() = user_id or public.is_coach());
create policy "profiles: own insert" on public.profiles for insert with check (auth.uid() = user_id and role = 'client');
create policy "profiles: own update" on public.profiles for update using (auth.uid() = user_id) with check (auth.uid() = user_id and role = (select role from public.profiles where user_id = auth.uid()));

create table public.subscriptions (
  user_id uuid primary key references public.profiles(user_id) on delete cascade,
  stripe_customer_id text unique,
  stripe_subscription_id text unique,
  tier tier_type not null default 'free',
  status text not null default 'inactive',
  current_period_end timestamptz,
  updated_at timestamptz not null default now()
);
alter table public.subscriptions enable row level security;
create policy "subscriptions: own read" on public.subscriptions for select using (auth.uid() = user_id or public.is_coach());
-- No client insert/update/delete. Only the Stripe webhook (service role) writes here.

create table public.stripe_events (
  id text primary key,
  received_at timestamptz not null default now()
);
alter table public.stripe_events enable row level security;
-- No policies: service role only.

create table public.lessons (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body_md text not null,
  task text,
  published boolean not null default false,
  created_at timestamptz not null default now()
);
alter table public.lessons enable row level security;
create policy "lessons: read published" on public.lessons for select using (published or public.is_coach());
create policy "lessons: coach write" on public.lessons for all using (public.is_coach()) with check (public.is_coach());

create table public.programs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(user_id) on delete cascade,
  name text not null,
  weeks jsonb not null,
  active boolean not null default true,
  created_at timestamptz not null default now()
);
alter table public.programs enable row level security;
create policy "programs: own read" on public.programs for select using (auth.uid() = user_id or public.is_coach());
create policy "programs: coach write" on public.programs for all using (public.is_coach()) with check (public.is_coach());

create table public.sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(user_id) on delete cascade,
  program_id uuid references public.programs(id) on delete set null,
  scheduled_for date not null,
  plan jsonb not null,
  completed_at timestamptz,
  unique (user_id, scheduled_for)
);
alter table public.sessions enable row level security;
create policy "sessions: own read" on public.sessions for select using (auth.uid() = user_id or public.is_coach());
create policy "sessions: own complete" on public.sessions for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "sessions: coach write" on public.sessions for all using (public.is_coach()) with check (public.is_coach());

create table public.set_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(user_id) on delete cascade,
  session_id uuid not null references public.sessions(id) on delete cascade,
  exercise text not null,
  set_no smallint not null check (set_no between 1 and 50),
  reps smallint not null check (reps between 0 and 100),
  load_kg numeric(6,2) not null check (load_kg between 0 and 1000),
  rpe numeric(3,1) check (rpe between 1 and 10),
  logged_at timestamptz not null default now(),
  deleted_at timestamptz
);
alter table public.set_logs enable row level security;
create policy "set_logs: own read" on public.set_logs for select using ((auth.uid() = user_id and deleted_at is null) or public.is_coach());
create policy "set_logs: own insert" on public.set_logs for insert with check (auth.uid() = user_id);
create policy "set_logs: own soft delete" on public.set_logs for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
-- No delete policy: history is soft-deleted only.

create table public.checkins (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(user_id) on delete cascade,
  day date not null,
  bodyweight_kg numeric(5,2) check (bodyweight_kg between 20 and 400),
  note text check (char_length(note) <= 500),
  pain boolean not null default false,
  created_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (user_id, day)
);
alter table public.checkins enable row level security;
create policy "checkins: own read" on public.checkins for select using ((auth.uid() = user_id and deleted_at is null) or public.is_coach());
create policy "checkins: own insert" on public.checkins for insert with check (auth.uid() = user_id);
create policy "checkins: own update" on public.checkins for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create table public.task_completions (
  user_id uuid not null references public.profiles(user_id) on delete cascade,
  lesson_id uuid not null references public.lessons(id) on delete cascade,
  completed_at timestamptz not null default now(),
  primary key (user_id, lesson_id)
);
alter table public.task_completions enable row level security;
create policy "task_completions: own" on public.task_completions for all using (auth.uid() = user_id or public.is_coach()) with check (auth.uid() = user_id);

create table public.recommendations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(user_id) on delete cascade,
  rule_id text not null,
  body text not null,
  status rec_status not null default 'pending',
  created_at timestamptz not null default now(),
  reviewed_by uuid references public.profiles(user_id),
  reviewed_at timestamptz
);
alter table public.recommendations enable row level security;
create policy "recommendations: own read shown" on public.recommendations for select using ((auth.uid() = user_id and status in ('shown','dismissed')) or public.is_coach());
create policy "recommendations: own dismiss" on public.recommendations for update using (auth.uid() = user_id and status = 'shown') with check (auth.uid() = user_id and status = 'dismissed');
create policy "recommendations: coach write" on public.recommendations for all using (public.is_coach()) with check (public.is_coach());

create table public.coach_audit (
  id bigint generated always as identity primary key,
  coach_id uuid not null references public.profiles(user_id),
  action text not null,
  target_table text not null,
  target_id text not null,
  diff jsonb,
  at timestamptz not null default now()
);
alter table public.coach_audit enable row level security;
create policy "coach_audit: coach read" on public.coach_audit for select using (public.is_coach());
create policy "coach_audit: coach insert" on public.coach_audit for insert with check (public.is_coach() and coach_id = auth.uid());

-- Create a profile row for every new auth user
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (user_id) values (new.id);
  insert into public.subscriptions (user_id) values (new.id);
  return new;
end;
$$;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
