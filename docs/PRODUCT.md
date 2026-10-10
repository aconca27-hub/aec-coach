# Product spec: AEC Coach

## One line

Everfit-style coaching app where the programming, the knowledge, and the nutrition logic are Adolfo's, and clients pay a low monthly subscription to follow it with coach oversight.

## Who it is for

1. People Adolfo meets in person (dot card tap → landing page → app). Mostly desk workers who want to get strong and stop hurting from sitting.
2. Existing AEC Performance clients moving off spreadsheets and texts.
3. Later: people who find the X/YouTube content.

## Philosophy the app encodes (fill in, Adolfo)

- Strength base: [your progression model, e.g. linear → double progression → RPE blocks]
- Mobility for sitters: new ranges of motion trained as strength work, not stretching. [list the positions you prioritize: deep squat hold, hip airplanes, thoracic extension, ankle dorsiflexion, etc.]
- Nutrition: same food framework for gain and loss; the variable is [portions / calorie target / fasting window]. [state the rules]
- Fasting: [when you use it, for whom, limits]
- Knowledge days: short lesson plus one task, on a schedule (e.g. Mon/Thu).

## Tiers

| Tier | Price (placeholder) | What they get |
| --- | --- | --- |
| Free | $0 | Blog, email list, one sample week |
| Self-guided | $9.99/mo | Full program, knowledge days, logging, auto recommendations |
| Coached | $49.99/mo | Everything above plus Adolfo reviews inputs weekly and adjusts |

## User stories (MVP)

### US-1 Sign up and onboard

Prep: Supabase Auth configured, Stripe products created.
Steps:
1. Client taps link from dot card or site, lands on `/join`.
2. Enters email, gets magic link, signs in.
3. Onboarding form: goal (gain / lose / maintain), training days per week, equipment, injuries or limits, sitting hours per day, bodyweight, height, age.
4. Picks a tier; Stripe Checkout; returns to `/app`.
Acceptance:
- A new user with no subscription sees only the free sample week.
- Onboarding answers are stored once and editable from settings.
- No field is required that the program does not use.

### US-2 Daily view

Prep: program template seeded for the client's profile.
Steps:
1. Opens `/app/today`.
2. Sees today's session (exercises, sets, reps, target load or RPE), or rest-day mobility.
3. On knowledge days, sees the lesson card first, then the task.
4. Logs each set; logs bodyweight; logs a one-line check-in.
Acceptance:
- Today loads in under 1.5 s on a phone.
- A set can be logged in two taps.
- Logging works offline and syncs when back online (PWA).

### US-3 Recommendations

Prep: rules engine defined in `docs/ARCHITECTURE.md`.
Steps:
1. Weekly job reads the last 7 days of logs.
2. Applies Adolfo's rules (missed sessions, RPE drift, bodyweight trend vs goal).
3. Writes a recommendation to the client's feed and, for Coached tier, to Adolfo's review queue.
Acceptance:
- Every recommendation shows the rule that produced it.
- Coached-tier recommendations are not shown to the client until Adolfo approves or edits.

### US-4 Coach console

Steps:
1. Adolfo opens `/coach`.
2. Sees all clients, last check-in, flags (missed 2+ sessions, pain reported, weight off-trend).
3. Opens a client, edits next week's program, approves recommendations, sends a message.
Acceptance:
- Coach role is the only role that can read other users' rows.
- Every coach edit is logged with who and when.

### US-5 Billing

Acceptance:
- Cancel, upgrade, downgrade all happen in the Stripe Customer Portal.
- A failed payment downgrades to Free after the Stripe grace period, never earlier.
- Webhook signatures are verified; replayed events are ignored.

## Out of scope for MVP

Native iOS/Android apps, in-app video hosting (link YouTube), group chat, wearable sync, AI-written programs.

## Metrics

Weekly active loggers, 30-day retention by tier, conversion from `/join` to paid, coach review time per client.
