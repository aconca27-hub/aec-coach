# Architecture

## Principles

1. The database enforces access, not the app. Every table has RLS; the app never uses the service-role key in request handlers.
2. Server actions only. No public REST surface beyond Stripe webhooks and auth callbacks.
3. Rules, not models. Recommendations come from Adolfo's explicit rules so every output is explainable.
4. Everything testable: policies (pgTAP), logic (Vitest), flows (Playwright).

## Data model (v1)

| Table | Purpose | Owner column |
| --- | --- | --- |
| `profiles` | one per auth user: role (client / coach), goal, training days, equipment, limits, sitting hours | `user_id` |
| `subscriptions` | mirror of Stripe state: tier, status, current_period_end | `user_id` |
| `program_templates` | Adolfo's templates by goal and days/week | coach-only |
| `programs` | a client's active program (weeks, days, exercises, targets) | `user_id` |
| `sessions` | one row per scheduled day | `user_id` |
| `set_logs` | reps, load, RPE per set | `user_id` |
| `checkins` | bodyweight, note, pain flag | `user_id` |
| `lessons` | knowledge-day content, published flag | coach-only write, all read |
| `tasks` | the task attached to a lesson, with completion per user | `user_id` |
| `recommendations` | rule id, text, status (pending / approved / shown) | `user_id` |
| `coach_audit` | who changed what, when | coach-only |

Health-adjacent fields (injuries, pain flags, bodyweight) are stored in `profiles.limits` and `checkins` only, encrypted at rest by Supabase, exported or deleted on request from settings.

## Roles

- `client`: reads and writes own rows only.
- `coach`: reads all client rows, writes `programs`, `lessons`, `recommendations`, `coach_audit`. Granted by a row in `profiles` set manually in the dashboard, never by the app.

## Flows

Sign-up: `/join` → Supabase magic link → `profiles` row created by trigger → onboarding → Stripe Checkout → webhook writes `subscriptions` → `/app`.

Daily: `/app/today` server action reads `sessions` + `lessons` + `tasks` for today under the user's JWT → client logs → `set_logs` / `checkins` inserts.

Weekly recommendations: Supabase cron (pg_cron) calls an Edge Function with the service-role key, runs rules per client, inserts `recommendations` with `status = pending` for Coached tier, `status = shown` for Self-guided.

## Rules engine (seed list, Adolfo to expand)

| Rule id | Trigger | Output |
| --- | --- | --- |
| R1 missed | 2+ sessions missed in 7 days | Reduce next week to 3 days, keep main lifts |
| R2 rpe-high | Average RPE above target by 1+ for a lift two weeks running | Drop load 5% on that lift |
| R3 rpe-low | Average RPE below target by 1+ | Add one set or 2.5% load |
| R4 weight-flat-gain | Goal gain, weight flat 14 days | Add [X] to daily intake per Adolfo's rule |
| R5 weight-flat-loss | Goal lose, weight flat 14 days | Remove [X] or extend fasting window per rule |
| R6 pain | Pain flag on any check-in | Hold that movement, route to coach queue regardless of tier |

## Decisions log

| Date | Decision | Why |
| --- | --- | --- |
| 2026-10-10 | Next.js + Supabase + Stripe + Vercel | Smallest surface to secure, fastest to ship, strongest hiring signal |
| 2026-10-10 | No native apps in MVP | PWA covers phone use; native adds two more codebases to secure |
| 2026-10-10 | Rules engine, not LLM, for recommendations | Explainable, testable, and it is Adolfo's method that sells |
