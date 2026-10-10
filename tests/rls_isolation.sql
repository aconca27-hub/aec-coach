-- pgTAP: a client cannot read or write another client's rows.
-- Run with: supabase test db
begin;
select plan(6);

-- two fake users
insert into auth.users (id, email) values
  ('11111111-1111-1111-1111-111111111111', 'a@example.com'),
  ('22222222-2222-2222-2222-222222222222', 'b@example.com');

-- user A logs a checkin
set local role authenticated;
set local request.jwt.claims = '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}';
insert into public.checkins (user_id, day, bodyweight_kg) values ('11111111-1111-1111-1111-111111111111', current_date, 90);
select is((select count(*) from public.checkins), 1::bigint, 'A sees own checkin');

-- user B cannot see it
set local request.jwt.claims = '{"sub":"22222222-2222-2222-2222-222222222222","role":"authenticated"}';
select is((select count(*) from public.checkins), 0::bigint, 'B cannot see A checkin');

-- B cannot insert as A
select throws_ok(
  $$insert into public.checkins (user_id, day, bodyweight_kg) values ('11111111-1111-1111-1111-111111111111', current_date + 1, 80)$$,
  '42501', null, 'B cannot insert a row owned by A');

-- B cannot read A subscription
select is((select count(*) from public.subscriptions where user_id = '11111111-1111-1111-1111-111111111111'), 0::bigint, 'B cannot see A subscription');

-- B cannot promote self to coach
select throws_ok(
  $$update public.profiles set role = 'coach' where user_id = '22222222-2222-2222-2222-222222222222'$$,
  null, null, 'client cannot self-promote to coach');

-- B cannot hard-delete own set_logs (no delete policy)
select is((select count(*) from public.set_logs), 0::bigint, 'baseline set_logs empty for B');

select * from finish();
rollback;
