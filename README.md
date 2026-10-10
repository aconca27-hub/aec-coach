# AEC Coach

Coaching app built on the AEC Performance training philosophy: strength-first programming, mobility for people who sit all day, and nutrition by goal (gain or lose on the same food framework). Clients get a daily task plus a knowledge drop on scheduled days, log inputs, and receive programmed recommendations from the coach.

Built by Adolfo (AEC Holdings) as a production product and as a QA-first portfolio repository: every feature ships with tests, every PR passes an automated security review, and the database is locked down with row-level security from day one.

## Status

Phase 0: scaffold, spec, security rules, agent review pipeline. No application code yet.

## Stack (decided)

| Layer | Choice | Why |
| --- | --- | --- |
| Frontend | Next.js 15 (App Router), TypeScript, Tailwind | One codebase for web and PWA on phones; strong hiring signal |
| Backend | Next.js server actions + Supabase | No separate API server to secure |
| Database | Supabase Postgres with row-level security | Every table has RLS; clients can only ever read their own rows |
| Auth | Supabase Auth (email magic link, Apple, Google) | No passwords stored by us |
| Payments | Stripe Checkout + Customer Portal | Card data never touches our servers |
| Hosting | Vercel | Preview deploy per PR |
| Tests | Vitest (unit), Playwright (e2e), pgTAP (RLS policies) | QA depth is the portfolio |
| CI | GitHub Actions: lint, typecheck, tests, CodeQL, Dependabot, secret scan | Nothing merges red |

## Repository map

- `docs/PRODUCT.md` — what the app does, user stories, acceptance criteria
- `docs/ARCHITECTURE.md` — data model, flows, decisions
- `docs/SECURITY.md` — the rules every contributor and every agent follows
- `CLAUDE.md` — standing instructions for Claude Code sessions in this repo
- `.claude/agents/` — reviewer agents (security, implementation, QA) that check each other's work
- `supabase/migrations/` — schema with RLS policies
- `.github/workflows/` — CI

## Local setup (once code lands)

```
cp .env.example .env.local   # fill from Supabase and Stripe dashboards; never commit
npm install
npx supabase start
npm run dev
```
