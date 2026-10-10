# CLAUDE.md - standing rules for this repo

Read `docs/SECURITY.md` before writing any code. It is not optional.

## How work flows

1. Every feature starts from a user story in `docs/PRODUCT.md`. If the story is missing, write it first and get Adolfo's approval.
2. Implement on a branch. Write the tests with the code, not after.
3. Before opening a PR, run the three reviewer agents in `.claude/agents/` in this order: `implementation-reviewer`, `security-reviewer`, `qa-reviewer`. Each must return PASS. Fix findings and rerun until all three pass.
4. The PR description lists: story id, what changed, which reviewer findings were fixed, how to test.

## Hard rules

- No secrets in code, tests, fixtures, or docs. Use `.env.example` names.
- Every new table ships with RLS enabled and policies in the same migration, plus a pgTAP test proving a client cannot read another client's row.
- Every server action validates input with Zod and re-reads `auth.uid()`.
- No `any` in TypeScript. No `dangerouslySetInnerHTML`.
- No new dependency without a one-line justification in the PR.
- No em dashes in any text; use hyphens.

## Style

- Small PRs, one story each.
- Commit messages: `US-3: add rpe-high rule and tests`.
- Comments explain why, not what.

## Adolfo's context

Elite powerlifter and coach; the training and nutrition rules in `docs/ARCHITECTURE.md` are his method and are the product. When a rule is ambiguous, ask him rather than inventing.
