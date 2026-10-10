# Security rules

These apply to every human and every agent that writes to this repository. A PR that violates one is blocked by the security reviewer agent and by CI.

## Secrets

1. No secret in the repo, ever. `.env.local` is gitignored; `.env.example` holds names only.
2. Secrets live in Vercel and Supabase project settings. Rotate any key that is ever pasted into a chat, a commit, or a screenshot.
3. The Supabase service-role key is used only in Edge Functions and the webhook handler. It never ships to the browser and never appears in a server action.
4. `gitleaks` runs in CI on every push; a hit fails the build.

## Database

1. RLS is enabled on every table before the first row is inserted. A migration that creates a table without `enable row level security` fails the pgTAP policy test.
2. Default deny. Policies grant `select/insert/update/delete` to `auth.uid() = user_id` for client tables; coach access is a separate policy checking `profiles.role = 'coach'`.
3. No `delete` policy for clients on `set_logs` and `checkins`; soft-delete via `deleted_at` so history cannot be wiped by a compromised session.
4. No raw SQL built from strings. Supabase client with parameters only.
5. Migrations are reviewed for: missing RLS, policies using `true`, functions marked `security definer` without a `search_path` set.

## Auth and sessions

1. Supabase Auth only; no custom password handling.
2. Magic-link and OAuth. If passwords are ever added: Supabase's bcrypt, minimum 12 chars, breached-password check on.
3. Coach role is assigned in the Supabase dashboard by Adolfo, never by an endpoint.
4. Server actions re-check `auth.uid()` on every call; never trust an id passed from the client.

## Input and output

1. Every server action validates input with a Zod schema. Unknown fields rejected.
2. Numeric limits on everything logged (load 0 to 1000 kg, reps 0 to 100, bodyweight 20 to 400 kg) so garbage cannot drive recommendations.
3. All user text is stored raw and rendered escaped; no `dangerouslySetInnerHTML` without a reviewer sign-off and a sanitizer.
4. Lessons (coach-authored markdown) are rendered through a sanitizing markdown pipeline with a strict allowlist.

## Payments

1. Stripe Checkout and Customer Portal only. No card fields in our UI.
2. Webhook handler verifies `Stripe-Signature`, stores `event.id`, and ignores duplicates.
3. Tier changes come only from verified webhook events, never from a client request.

## Headers and transport

1. HTTPS only (Vercel default). HSTS, `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin`, `Permissions-Policy` minimal.
2. Content-Security-Policy with nonces; no `unsafe-inline` scripts.
3. Rate limiting on auth and logging endpoints (Vercel middleware + Upstash or Supabase edge rate limit).

## Dependencies

1. Dependabot weekly; security updates auto-merged if tests pass.
2. `npm audit --audit-level=high` fails CI.
3. No dependency added without a line in the PR explaining why.

## Privacy

1. Collect only what the program uses (see PRODUCT.md). No contacts, location, or device identifiers.
2. Export-my-data and delete-my-account from settings, completing within 30 days, implemented before public launch.
3. Pain, injury, and bodyweight fields are treated as sensitive: never logged to analytics, never in error messages.

## Incident

If a breach is suspected: rotate all keys, revoke all sessions (Supabase dashboard), snapshot logs, write the timeline in `docs/incidents/`, notify affected users within 72 hours.
