# Roadmap

Dependency-ordered. A phase does not start until the one above it is done. Each phase lists who owns it, what it needs, and how we know it is done.

## What this repo is for

1. A real product: Adolfo's coaching method (strength, mobility for people who sit all day, goal-based nutrition) delivered as a low-cost monthly subscription, with coach oversight for the higher tier.
2. A QA portfolio: the repo shows how Adolfo builds quality in, not just tests at the end. Spec-first user stories, database-enforced security, automated policy checks in CI, a test pyramid, and AI reviewer agents that audit each other's work.

## How we work (every session)

1. Adolfo says which story to start, e.g. "Start US-1".
2. Claude branches, implements, writes tests, then runs the three reviewer agents in order (implementation, security, QA) and fixes until all PASS.
3. Claude opens a PR with the story id, reviewer findings fixed, and how to test.
4. Adolfo reviews on GitHub, clicks the Vercel preview, merges.
5. Accounts and secrets are Adolfo's: he creates the GitHub, Supabase, Vercel, and Stripe accounts and pastes keys into those dashboards. Claude never holds passwords or live keys.

## Phases

| # | Phase | Owner | Needs | Done when |
| --- | --- | --- | --- | --- |
| 0 | Scaffold: spec, architecture, security rules, agents, schema, CI | Claude | nothing | Committed (2026-10-10) |
| 1 | Philosophy capture | Adolfo | `docs/PHILOSOPHY.md` template | Sections 1, 2, 3, and 8 filled with numbers, not adjectives |
| 2 | Accounts and bootstrap | Adolfo creates accounts; Claude wires them | GitHub repo, Supabase project, Vercel project, Stripe test mode | Repo pushed, Next.js app deploys a preview, CI green |
| 3 | US-1 sign-up and onboarding | Claude | Phase 2 | Reviewers PASS, pgTAP and Playwright tests green, merged |
| 4 | Seed data from philosophy | Claude from Adolfo's tables | Phase 1 sections 4 to 7 | Exercise library, templates, lessons load from `supabase/seed/` with tests |
| 5 | US-2 daily view and logging (PWA, offline) | Claude | Phases 3 and 4 | Set logged in two taps, works offline, loads under 1.5 s on a phone |
| 6 | US-3 rules engine and recommendations | Claude | Phase 1 section 8 | Every rule is a pure function with a triggering and non-triggering test |
| 7 | US-4 coach console | Claude | Phase 6 | Coach sees flags, approves recommendations, every edit audited |
| 8 | US-5 billing | Claude, Adolfo sets prices | Stripe products | Checkout, portal, webhook signature and replay tests pass |
| 9 | Hardening and privacy | Claude, reviewed by Adolfo | Phases 3 to 8 | OWASP ASVS Level 1 checklist complete, export/delete account live, CSP verified |
| 10 | Landing page and dot card link | Claude builds, Adolfo supplies video and copy | Phase 9 | Dot card opens landing page, free blog/email capture, join flow |
| 11 | Beta: 5 to 10 people you know | Adolfo | Phase 10 | 4 weeks of logs, retention and bug list reviewed |

## Phase 1 detail (your part, start now)

1. Open `docs/PHILOSOPHY.md`.
2. Fill section 1 (principles) in plain words. Ten lines max.
3. Fill section 2 (intake to program mapping). This decides what onboarding asks.
4. Fill section 3 (progression) with numbers: sets, reps, load jumps, when to deload.
5. Fill section 8 (recommendation rules) as IF / THEN with numbers.
6. Sections 4 to 7 (exercise library, mobility, nutrition, knowledge days) can fill in while Phases 2 and 3 are built.
7. Voice notes are fine. Record yourself explaining a section, send the transcript, and Claude turns it into the tables.

## Phase 2 detail (accounts, about one hour)

1. GitHub: create private repo `aec-coach`. Tell Claude the name; Claude pushes Phase 0.
2. Supabase: new project at supabase.com, region US East. Copy the project URL and anon key into Vercel env vars (not into chat).
3. Vercel: import the GitHub repo. Every PR gets a preview URL.
4. Stripe: test mode only for now. Create two products (Self-guided, Coached) with monthly prices.
5. GitHub settings: enable branch protection on `main` (require PR, require CI green), enable Dependabot alerts and secret scanning.
