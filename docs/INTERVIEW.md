# Interview talk track

## What this repo is (say it in 30 seconds)

"AEC Coach is a subscription coaching app I'm building for my fitness business. I built it the way I'd want any team I lead to build software: every feature starts as a user story with acceptance criteria, security is enforced in the database instead of trusted to the app, and nothing merges unless CI and three AI reviewer agents, implementation, security, and QA, all pass. The QA reviewer's job is to verify the other two actually fixed what they flagged."

## What to click during a screen share (in this order)

1. `docs/PRODUCT.md`: user stories with prep, steps, acceptance criteria.
2. `supabase/migrations/..._init.sql`: row-level security on every table, default deny, soft-delete on history.
3. `tests/rls_isolation.sql`: proof that one client cannot read or write another client's data.
4. `.github/workflows/ci.yml`: the custom check that fails any migration with a table missing RLS.
5. `.claude/agents/`: the reviewer pipeline and how the QA agent audits the other two.
6. A merged PR: story id, reviewer findings, fixes, test evidence.

## Questions you will get, and the short answers

| Question | Answer |
| --- | --- |
| Why test RLS with pgTAP instead of only e2e? | Policies are the security boundary. Testing them at the database layer catches a bad policy even if the UI never exposes it. |
| How do you trust AI-written code? | I don't by default. Each change goes through three independent reviewer prompts plus CI, and the QA reviewer re-verifies fixes instead of accepting "fixed". I review and merge every PR myself. |
| What's your test pyramid here? | pgTAP for policies, Vitest for rules and validation, Playwright for the five user journeys. Most tests sit at the rules layer because that's where the business logic lives. |
| How do you handle payments securely? | Stripe Checkout and Portal only; card data never touches our servers. Webhooks verify signatures and dedupe on event id, and tier changes only come from verified webhooks. |
| What would you do with a team? | The same pipeline: story-first, a definition of done that includes security and isolation tests, and CI that enforces the rules nobody remembers at 5 pm. |
