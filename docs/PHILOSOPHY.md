# Philosophy: Adolfo's method, written so it can become code

Every section says what it becomes in the app. Write in numbers wherever a number exists. "Add weight when it feels easy" cannot be coded; "add 2.5 kg when all sets hit the top of the rep range at RPE 8 or below" can.

## 1. Principles

Becomes: the About page, onboarding copy, and the tie-breaker when a rule is ambiguous.

1.
2.
3.
4.
5.

## 2. Intake to program mapping

Becomes: onboarding questions and `program_templates` selection logic.

| Goal | Days per week | Experience | Equipment | Template name | Notes |
| --- | --- | --- | --- | --- | --- |
| gain | 3 | beginner | full gym | | |
| gain | 4 | intermediate | full gym | | |
| lose | 3 | beginner | home / dumbbells | | |
| maintain | 2 | any | minimal | | |

Questions onboarding must ask (and why each one changes the program):

| Question | Answer options | What it changes |
| --- | --- | --- |
| Hours sitting per day | 0-4, 4-8, 8+ | |
| Injuries or limits | free text plus body-area picker | |
| | | |

### Screening: who gets routed to a professional before starting

Becomes: a hard gate in onboarding. These users see a message to clear the plan with their doctor and are flagged to the coach queue.

- Fasting is not offered to: pregnant or breastfeeding users, users on diabetes medication, users under 18, anyone who reports a history of disordered eating. (Adolfo: confirm and extend.)
- Pain reported at intake in: [areas]
-

## 3. Progression model

Becomes: `src/rules/progression.ts` and the weekly targets in each program.

| Phase | Weeks | Sets x reps | Intensity (RPE or %1RM) | Progress when | Progress by | Deload when |
| --- | --- | --- | --- | --- | --- | --- |
| Base | | | | | | |
| Build | | | | | | |
| Peak | | | | | | |

## 4. Exercise library

Becomes: `exercises` seed table and the exercise detail screen.

| Exercise | Pattern (squat / hinge / push / pull / carry / mobility) | Regression | Progression | 3 coaching cues | Video link |
| --- | --- | --- | --- | --- | --- |
| | | | | | |

## 5. Mobility for people who sit all day

Becomes: rest-day sessions and warm-up blocks, plus the knowledge-day curriculum.

| Position or range | Why sitters lose it | Test (how the client checks it) | Drill | Dose | Progress when |
| --- | --- | --- | --- | --- | --- |
| Deep squat hold | | | | | |
| Hip extension | | | | | |
| Thoracic extension | | | | | |
| Ankle dorsiflexion | | | | | |
| | | | | | |

## 6. Nutrition

Becomes: the nutrition targets screen and rules R4 and R5.

Framework in one paragraph (same foods for gain and loss; what changes):

| Goal | Starting target (calories, protein, or portion rule) | Adjust when | Adjust by |
| --- | --- | --- | --- |
| gain | | bodyweight flat for 14 days | |
| lose | | bodyweight flat for 14 days | |
| maintain | | drift more than [x] kg in 14 days | |

Fasting:

| Who it is offered to | Window | How it starts | When it stops |
| --- | --- | --- | --- |
| | | | |

## 7. Knowledge days

Becomes: `lessons` and their tasks, released on a schedule.

| Week | Day | Topic | Lesson (2-4 sentences) | Task (one action, checkable) |
| --- | --- | --- | --- | --- |
| 1 | Mon | Why sitting costs you hip extension | | Hold a half-kneeling stretch 2 x 60 s each side |
| 1 | Thu | | | |
| 2 | Mon | | | |

## 8. Recommendation rules

Becomes: the rules engine (`src/rules/*.ts`), one test file per rule. Format: IF condition with numbers THEN action with numbers, plus who sees it.

| Rule id | IF | THEN | Self-guided sees it immediately? | Coach review required? |
| --- | --- | --- | --- | --- |
| R1 | 2+ sessions missed in 7 days | reduce next week to 3 days, keep main lifts | yes | no |
| R2 | avg RPE 1+ above target on a lift, 2 weeks running | drop load 5% on that lift | yes | no |
| R3 | avg RPE 1+ below target | add 1 set or 2.5% load | yes | no |
| R4 | goal gain, bodyweight flat 14 days | [your rule] | | |
| R5 | goal lose, bodyweight flat 14 days | [your rule] | | |
| R6 | pain flag on any check-in | hold that movement | no | always |
| R7 | | | | |
