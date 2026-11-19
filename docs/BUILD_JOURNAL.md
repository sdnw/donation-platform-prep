# Build Journal

What we did, and **why**, phase by phase. Read it at the end of the day.
Kept by Claude. Your own words go in `LEARNING_LOG.md`.

Interview: about 2026-11-20. Mode: accelerated (you try for 10-15 min, I fill in the blanks).

---

## Phase 0: Setup (Nov 16)

| What we did | Why |
| --- | --- |
| Rails 8.1 API app in `api/`, Postgres 16 | API-only: React is the front end, so no views are needed |
| RSpec, FactoryBot, Faker, WebMock, shoulda-matchers | Interviewers expect tests. WebMock blocks real Stripe calls in tests |
| Vite React app in `web/` | Separate front end that talks to the API |
| Flattened the repo (no folder inside a folder) | One repo, two apps side by side is the normal layout |
| `DONATION_PLATFORM_PLAN.md`, `README.md`, `docs/LEARNING_LOG.md` | The plan and the notes live with the code |

**The mistake that taught us the most:** `--skip-git` skipped `.gitignore`, so `master.key`, logs and
cache were pushed to a public repo.
- Fix: add `.gitignore`, rotate the credentials, confirm the old key is dead.
- On Nov 18 the local `master.key` went missing, so we regenerated it.
- Lesson: secrets never go in git. A leaked key means rotate, not just delete.

---

## Phase 1: Data model (Nov 16-18)

### Donors and Funds (branch `phase-1/donor-and-fund`, merged as PR #2)

**Migrations** (the database is the last line of defense):
- `null: false` on required fields: a row without a name or email makes no sense.
- Unique indexes on `donors.email`, `funds.slug` and `funds.name`: no duplicates, even under concurrency.
- Partial unique index on `funds.is_default` (`where: is_default = true`): at most **one** default fund.
  The default fund is the General Fund. Donors who don't pick a fund get it.
- Gotcha: `unique: true` on a column line is silently ignored. Use `t.index ..., unique: true`.

**Models:**
- `normalizes` lowercases and strips email and slug, so `Camp` and `camp` are the same thing.
- Fund `name` is only stripped, because it's a display name and keeps its capitals.
- `uniqueness: { case_sensitive: false }` gives friendly errors.

**Validation vs unique index (know this cold):**
- Validation = friendly error message, but two requests at the same moment can both pass it.
- Unique index = the database guarantee. This is what actually stops duplicates.
- You want both.

**Specs and factories:**
- shoulda matchers (`validate_presence_of`, `validate_uniqueness_of(...).case_insensitive`) keep specs short.
- Uniqueness specs need an existing record (`before { create(:fund) }`).
- Factories use sequences so every record is unique.
- `config.include FactoryBot::Syntax::Methods` lets you write `create` instead of `FactoryBot.create`.

### Donations (branch `phase-1/donation`)

**Migration decisions:**
| Decision | Reason |
| --- | --- |
| `amount_cents` as an integer | Floats have rounding errors with money. Stripe also uses cents |
| `currency` default `usd` (lowercase) | Matches what Stripe expects |
| `status` and `frequency` as integers, default 0 | Rails enums store numbers |
| `idempotency_key` required and **unique** | The same request sent twice can never create two donations |
| `stripe_payment_intent_id` **nullable** but unique | We save the donation first, then Stripe makes the id. Postgres allows many NULLs in a unique index |
| Foreign keys on `donor_id` and `fund_id` | The database refuses a donation for a donor or fund that doesn't exist |
| Indexes on `donor_id` and `fund_id` | Fast "all donations for this fund" queries |

**Model:**
- `belongs_to :donor` and `:fund`.
- `enum :status` (pending, processing, succeeded, failed, refunded) and `enum :frequency` (one_time, monthly).
  Rails gives free helpers like `Donation.succeeded` and `donation.pending?`.
- Rails 8 needs the new syntax: `enum :status, [...]`. The old `enum status: [...]` was removed.
- Currency validation allows `usd` only. It had to match the database default or every default donation would fail.

**Spec and factory:**
- Factory builds a valid donation with a donor, a fund, 5000 cents and a unique key. Traits: `:succeeded`, `:monthly`.
- Specs: associations, enum values, amount rules, currency, key presence and uniqueness, and the database guarantees.
- Database-guarantee tests prove the **index** works, not just the validation.
- Result: 32 examples, 0 failures. Pushed to GitHub.

---

## Mistakes and what they taught

| Mistake | Lesson |
| --- | --- |
| Index lines replaced column lines in a migration | Columns and indexes are separate lines |
| `default: ''` with `null: false` | An empty string defeats `null: false`. Use a real default or none |
| Spec file placed in `app/models/` | Specs live in `spec/` |
| Uniqueness spec with no existing record | The matcher needs a record to collide with |
| Currency validation `USD` vs default `usd` | Validations and DB defaults must agree |
| Used `valid?` on one object and read `errors` on another | Keep the object in a variable |
| Unsaved editor changes (dot on the tab) | Check the tab before asking me to review |
| `git push` on a new branch | First push needs `--set-upstream origin <branch>` |

## Git notes
- The contribution graph only counts commits on the default branch.
- Use "Create a merge commit" (not squash) so the commit dates are kept.
- Commit email must belong to your GitHub account.

---

## Interview talking points so far
1. **Why integer cents?** Floats can't represent money exactly.
2. **Validation vs unique index?** Friendly errors vs a real guarantee under concurrency.
3. **Why is `stripe_payment_intent_id` nullable?** We save first, Stripe creates the id after.
4. **What stops a double charge?** The unique `idempotency_key`. (Phase 3 builds the rest.)
5. **Why a partial index for the default fund?** It allows many non-default rows and only one default.

6. **Why `restrict_with_error` on `has_many :donations`?** Deleting a fund or donor must never wipe money history.
7. **Why are seeds safe to run twice?** `find_or_create_by!` on a fixed key (slug, email, idempotency key).

## Phase 1 status (Nov 18)
- [x] `has_many :donations, dependent: :restrict_with_error` on Donor and Fund
- [x] Scopes `for_fund`, `in_range`, `recurring` (`succeeded` is free from the enum), with specs
- [x] Seeds: 4 funds (General Fund is the default), 5 donors, 5 donations
- [x] PR #3 for `phase-1/donation`
- [ ] Optional spec: a new Donation starts pending and one_time
- [ ] Phase gate: draw the schema from memory, answer the quiz, write `LEARNING_LOG.md`

---

## Scope decision: MVP matched to the resume (Nov 18)

**Resume claim:** "Delivered nonprofit WordPress platforms (Rise Above Opioids, Valley Youth House) with custom taxonomies and content carousels; built the Valley Youth House donation workflow that processed a $100,000 donation during its first holiday campaign."

| Resume bullet | Where it lands in the rebuild |
| --- | --- |
| Built the donation workflow | Phases 2 and 3: donate form, create donation, pay, confirm |
| Processed a $100,000 donation | Phase 3: integer cents, idempotency, status changes |
| Custom taxonomies | Funds (Camps, Parks, Shelters) categorize donations |
| Content carousels | Small React piece, only if time allows |

**Nothing is cut.** You confirmed the original VYH app had all of these: Stripe payments, double-charge prevention, webhooks, admin login and donation list, reports, and monthly (recurring) gifts. So you must be able to explain each one.

**Build order, by interview value** (deep first, thin after):
| Order | Build | Depth |
| --- | --- | --- |
| 1 | Phase 2: `GET /funds`, `POST /donations`, `GET /donations` | Full |
| 2 | Phase 3: `Donations::Create`, Stripe PaymentIntent, idempotency key, webhook that flips pending to succeeded and ignores repeats | Full. The most important talk-track |
| 3 | React donate form: fund dropdown, amount, submit | Thin |
| 4 | Admin: Devise login, donation list with filters | Thin |
| 5 | Reports: totals by fund and date range | Thin, one endpoint |
| 6 | Recurring gifts: Stripe subscription, `RecurringPlan` | Thin, and explain it |

**How the original was built (from you, Nov 18):** the Valley Youth House website is WordPress, but the donation platform was built in **Rails and React**, because they wanted more control than a WordPress setup gives.

**Say this in the interview:**
> "The site is WordPress, but I built the donation workflow as a separate Rails and React app, because the team wanted more control than WordPress gives. This repo is my from-scratch rebuild of it."

**Confirmed by you (Nov 18):** all of it was in the original: Stripe, idempotency, webhooks, admin, reports and recurring gifts. So the rebuild covers your real work, and you can say "I built this" for each piece. Still be ready to say what you did yourself on each piece.

**Quiz answer to remember:** `POST /donations` needs an `Idempotency-Key` header so a retried or double-clicked request can't create a second charge.
