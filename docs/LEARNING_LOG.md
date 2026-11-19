# Learning Log

One entry per phase. Include: what you built, where you got stuck, which hint rung you needed, and one thing you would explain differently now.

> DRAFT written by Claude from our session. Read each entry, then reword it in your own words.
> Interviewers can tell when notes aren't yours. Replace anything that doesn't sound like you.

## Phase 0: Setup

**Built:** a Rails 8 API app with Postgres, RSpec, FactoryBot and shoulda-matchers, plus a Vite React app. One repo with `api/` and `web/` side by side.

**Got stuck:** I skipped `.gitignore` when generating the app, so `master.key` and logs went to a public GitHub repo. I had to rotate the credentials and add a proper `.gitignore`.

**Hint rung:** 5 (Claude fixed it).

**Explain differently now:** secrets never go in git. If one leaks, rotate it. Deleting the file isn't enough, because it stays in the git history.

## Phase 1: Data model

**Built:** Donor, Fund and Donation tables, models, validations, factories, specs and seeds.

**Got stuck:**
- Unique indexes. `unique: true` on a column line is ignored, so I had to use `t.index ..., unique: true`.
- Uniqueness specs need an existing record to collide with.
- The currency default in the database (`usd`) didn't match the validation (`USD`).

**Hint rung:** mostly 2-3 (a pointer, then the shape). Rung 4-5 for the Donation spec skeleton and fixing the seeds.

**Explain differently now:**
- **Integer cents:** floats can't hold money exactly. Stripe also uses cents.
- **Validation vs unique index:** a validation gives a friendly error, but two requests at the same moment can both pass it. The unique index is the real guarantee. I want both.
- **`stripe_payment_intent_id` is nullable:** we save the donation first, then Stripe creates the id. Postgres allows many NULLs in a unique index.
- **`restrict_with_error`:** deleting a fund or donor must never wipe money history.

## Phase gate: Phase 1

**Quiz (answer from memory, then check):**
1. Why is `amount_cents` an integer? (floats round badly)
2. What stops two donations with the same `idempotency_key`? (the unique index, and the validation gives the friendly error)
3. Why can many donations have a NULL `stripe_payment_intent_id`? (NULLs are distinct in a Postgres unique index)
4. What does the partial unique index on `is_default` allow? (many non-default funds, only one default)
5. Why `dependent: :restrict_with_error`? (never delete money history)

**Bug drill (do it yourself, 10 minutes):**
1. In a scratch migration, remove `null: false` from `amount_cents` and see which spec fails.
2. Drop the index on `donations.fund_id`, then run `Donation.where(fund_id: 1).explain` and see how the query plan changes.
3. Put both back.

**Talk-track (say it out loud, no notes):** draw the `donors`, `funds` and `donations` tables on paper, with the foreign keys and the two unique indexes on donations. Then explain why each constraint is there.
