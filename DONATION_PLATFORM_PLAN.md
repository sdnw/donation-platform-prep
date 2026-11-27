# Donation Platform Rebuild: Interview Study Plan

Target role: Developer Junior (Ruby on Rails / React), VA contract
Purpose: rebuild the Valley Youth House style donation workflow from scratch so every resume claim about it can be explained, demonstrated, and debugged live.

## How to use this plan

- The AI is a mentor and reviewer first and a code generator second. You write the core logic; it handles what is not the lesson.
- Every phase ends with three things: a talk-track you say out loud, a bug drill, and a short list of interview questions the phase prepares you for.
- Each phase is tagged with the job requirement it covers, shown as `JD:`.
- If time is short, do the Core phases (0 through 6) and only read the Stretch phases (7 through 10) so you can speak to them honestly.

## Interview timeline and scope (updated 2026-11-25)

Interview: Wednesday 2026-12-02, Developer Junior (Ruby on Rails / React). The format is a debugging situation, a conversation about how you work, and questions that validate your resume. That leaves seven days at about two hours a day, so this section replaces the pacing at the bottom of this file. The day-by-day schedule lives in the interview prep doc.

Where things stand: Phase 0 is done, Phase 1 is merged (its phase gate items are still open), and Phase 2 has started. `GET /funds` works and has a request spec. The donations controller and its request spec are still generated stubs.

This repo has two jobs now: refresh the donation workflow you will be asked to explain, and give you code to plant bugs in and to rewrite from a blank file. The main prep is repetition on Rails, Ruby, JavaScript, and React fundamentals using the drill page, so protect that time first.

| Tier | What | Deadline |
| --- | --- | --- |
| Build | Finish Phase 2 (`POST /donations`, `GET /donations/:id`, strong params, `rescue_from`, real request specs). Then the core of Phase 3: `Donations::Create`, `Idempotency-Key` handling with the unique index, Stripe stubbed with WebMock, specs for a repeated request | Fri 2026-11-27 |
| Thin | Phase 4 only: one donate form with controlled inputs, a fetch with loading and error states, and one React Testing Library test | Sat 2026-11-28 |
| Kata only | Phase 5 Redux: write a small reducer and selector from a blank file in a scratch folder. Do not wire Redux into the app | Sat 2026-11-28 |
| Explain only | Stripe webhook and event de-duplication, Phase 6 admin and reports, recurring gifts, Phases 7 to 9. Read the phase, answer the matching flashcards, say the talk-track aloud. Build the webhook only if you finish early | No build |
| Shrunk | Phase 10 becomes the README architecture sketch (the TODO in `README.md`) and `docs/BUGS.md` logging each planted bug | Mon 2026-11-30 |

Nothing is cut from what you can claim. You confirmed the original Valley Youth House workflow had Stripe, idempotency, webhooks, admin, reports, and recurring gifts, so you still explain every piece. "Explain only" means you do not rebuild it before the interview.

### Planted-bug drill

Use a throwaway branch so your real work stays clean. Switch to the bug branch, then ask Claude Code: "Plant one realistic bug in the donation request path. Do not tell me where and do not show the diff. Commit it on this branch."

```bash
git switch -c bug/planted-1
```

Find it out loud with the six steps: clarify, read the error, reproduce, isolate, one hypothesis and one change, verify and add a test. Then log it in `docs/BUGS.md` and clean up.

```bash
git switch phase-2/api
git branch -D bug/planted-1
```

### Write-from-blank kata

Pick something you already wrote, such as the `in_range` scope and its spec. Delete it on a throwaway branch, rewrite it from memory, then compare against the original.

```bash
git switch -c kata/scope-spec
```

```bash
git diff phase-2/api -- api/app/models/donation.rb api/spec/models/donation_spec.rb
```

Before you build `POST /donations`, note that the routes file defines only `show` and `create` for donations, while the generated controller and spec stubs reference `index`. Reconcile those yourself as part of Phase 2.

## Mentor protocol

The goal is junior-level competence you can demonstrate live, so the struggle of forming the solution stays with you.

### The loop for every task

1. **Attempt first.** Write your own version before asking for anything, even if it is messy or half working. Set a timer: 20 to 30 minutes of real effort before the first hint.
2. **Debug on your own first.** Read the error, check the log, use `debugger` or the console, form a hypothesis. This is the exact skill the interview tests.
3. **Ask for a hint, not an answer.** Use the hint ladder below and climb one rung at a time.
4. **Request review.** Once it works, ask for review on bugs, readability, and edge cases you missed. Ask for one alternative approach and the tradeoffs.
5. **Explain it back.** Say out loud what each part does and why. Anything you cannot explain is not done.
6. **Get quizzed.** Three questions from the mentor, plus one variation of the problem to solve without help.

### Hint ladder

| Rung | What you ask | What the mentor gives |
| --- | --- | --- |
| 1 | "What concept am I missing?" | The name of the concept and what to search for or read |
| 2 | "Point me to where the problem is." | The file, method, or line range, with a guiding question |
| 3 | "Explain the approach in words." | Plain-language steps, no code |
| 4 | "Show me a similar example." | Code for a different but parallel problem |
| 5 | "Show me the solution." | The code, explained line by line |

If you reach rung 5, close the answer and rewrite it from memory the next day. If you cannot, it goes back on the board.

### Who writes what

| Phase | You write (the lesson) | AI handles (not the lesson) |
| --- | --- | --- |
| 0 Setup | Architecture sketch in the README | App generation, gem and package config, linters |
| 1 Data model | Migrations, validations, associations, scopes, the first model spec | Seed data, factories, remaining spec skeletons as failing tests |
| 2 REST API | Routes, controllers, strong params, serializers, the first request spec | CORS and Devise config, remaining failing request specs |
| 3 Payments | Service objects, idempotency handling, webhook de-dup, status transitions, jobs | Stripe test fixtures, WebMock stubs, mailer templates |
| 4 React flow | Components, state, effects, API client, validation | Vite config, CSS scaffolding, test setup files |
| 5 Redux | Slices, thunks, selectors, reducer tests | Store wiring boilerplate |
| 6 Reporting and debugging | Queries, the raw SQL report, every bug fix | Planting the bugs, pagination plumbing |
| 7 SOAP | The Savon client class and fault handling | The fake SOAP service and recorded XML |
| 8 Docker and CI | Reading and explaining every line | Drafting the Dockerfile, compose file, and workflow |
| 9 AWS | Active Storage usage in the app | Bucket and IAM setup steps |
| 10 Packaging | Decisions doc, bug log, spoken walkthroughs | README formatting, diagram rendering |

Rule for anything the AI drafts, including config: read it line by line and ask about anything unfamiliar. Nothing gets committed that you cannot explain.

### Testing split

RSpec and Jest are on the job description, so tests are part of the lesson. Write the first spec of each kind yourself (model, request, service, component, reducer). After that the test-writer agent may write failing tests for you to make pass, and you review each one as if it were a pull request.

### Phase gate

A phase is done only when all of these are true:

- [ ] The talk-track is delivered out loud without notes
- [ ] The mentor's quiz is passed, with misses re-asked the next day
- [ ] One piece of core logic from the phase is rewritten from memory in a scratch file
- [ ] The bug drill is narrated start to finish
- [ ] A `docs/LEARNING_LOG.md` entry is added: what you built, where you got stuck, which hint rung you needed, and one thing you would explain differently now

Track the hint rung per task. If most tasks in a phase needed rung 4 or 5, repeat the core task as a variation before moving on. If you ever feel you are shipping code you could not have written or explained, stop and redo that piece yourself.

### Mentor prompt

Paste this at the start of each session, or save it as the project instructions file for your agents.

```text
You are my mentor and code reviewer for a Rails API and React donation platform I am rebuilding to prepare for a junior Ruby on Rails / React interview. Follow DONATION_PLATFORM_PLAN.md.

Rules:
1. Do not write core feature code for me. Core means anything in the "You write" column of the plan.
2. When I am stuck, ask what I have tried and what I think is happening before you help.
3. Use the hint ladder. Start at rung 1 and move up one rung only when I ask. Never skip to code.
4. You may write boilerplate, config, fixtures, and scaffolding from the "AI handles" column. Explain what you generated in two or three sentences.
5. When I show you my code, review it for bugs, readability, and missed edge cases. Ask me questions that lead me to the fix before telling me the fix. Offer one alternative approach and its tradeoffs.
6. Ask me "why" questions: why this structure, why this approach, what would break at ten times the volume.
7. After each task, quiz me with three interview-style questions and give me one variation to solve alone.
8. If I ask you to debug, first ask for the error, the stack trace, and my hypothesis.
9. If I ask for a full solution, give it, then tell me to rewrite it from memory tomorrow and remind me to log it.
10. Recommend only free learning resources.
11. Keep answers short. Point me to the Rails Guides or official docs section to read when a concept is new.
```

### Adjusting over time

Early phases (1 through 3): stay strict, since Rails fundamentals are what the interview probes hardest. Later phases and stretch work: let the AI draft more while you act as reviewer, because by then you can judge whether its output is good.

## Requirement coverage

| Job requirement | Where it is practiced |
| --- | --- |
| Ruby on Rails, MVC, ORM | Phases 1, 2, 3 |
| REST web services | Phase 2 |
| RDBMS (Postgres, SQL) | Phases 1, 6 |
| Object-oriented design, service orientation | Phase 3 |
| Debugging and correcting errors | Bug drill in every phase, Phase 6 |
| React, JavaScript, HTML5, CSS3 | Phase 4 |
| Redux | Phase 5 |
| RSpec, mocking | Phases 1, 2, 3 |
| Jest, front-end testing | Phases 4, 5 |
| Testing, deployment, support | Phases 6, 8 |
| Agile | Phase 0 and the working agreement below |
| Git, GitHub | Phase 0, every phase |
| SOAP web services | Phase 7 (stretch) |
| AWS | Phase 9 (stretch) |
| Docker, CI/CD | Phase 8 (stretch) |
| BPM / workflow concepts (Camunda) | Phase 3 state machine, Phase 10 note |

## Stack

- Rails 7.1 or newer in API mode, Ruby 3.3 or newer
- PostgreSQL
- Devise for admin authentication
- Stripe in test mode (PaymentIntents with the Payment Element, webhooks)
- Active Job with a queue adapter (Solid Queue or Sidekiq)
- RSpec, FactoryBot, WebMock
- React with Vite, Redux Toolkit, React Router
- Jest (or Vitest) with React Testing Library

## Working agreement (Agile practice)

`JD: Agile methodologies`

- One GitHub Project board with columns: Backlog, This Sprint, In Progress, In Review, Done.
- Each phase is one sprint. Each checkbox below becomes an issue with acceptance criteria.
- One feature branch per issue, a pull request for each, reviewer agent comments before merge.
- End each sprint with a five-minute spoken retro: what shipped, what broke, what you would do differently.

Interview payoff: when asked about Agile you can describe a concrete loop of ticket, branch, PR, review, merge, retro.

---

## Phase 0: Setup (Core)

`JD: Git, GitHub, Agile`

- [ ] Create the repo with `api/` and `web/` directories
- [ ] Generate the Rails API app with Postgres and RSpec
- [ ] Generate the React app with Vite
- [ ] Add a README with setup steps and an architecture sketch
- [ ] Create the project board and seed it with Phase 1 issues

```bash
mkdir donation-platform
cd donation-platform
git init
rails new api --api --database=postgresql --skip-test
npm create vite@latest web -- --template react
```

```bash
cd api
bundle add rspec-rails factory_bot_rails faker --group "development, test"
bundle add webmock shoulda-matchers --group test
bin/rails generate rspec:install
bin/rails db:create
```

Talk-track: explain why the API and the front end are separate apps and how they communicate.

---

## Phase 1: Data model (Core)

`JD: RDBMS, ORM, object-oriented design, RSpec`

Models to build:

- `Donor`: name, email (unique index)
- `Fund`: name, slug, active flag (designated funds)
- `Donation`: amount in cents, currency, status, frequency (one time or monthly), references donor and fund, Stripe payment intent id (unique index), idempotency key (unique index)
- `Tribute`: honoree name, type (in honor or in memory), notification email, belongs to donation
- `RecurringPlan`: Stripe subscription id, status, interval, belongs to donor
- `AdminUser`: Devise model

Tasks:

- [ ] Write migrations with foreign keys, null constraints, and indexes
- [ ] Add validations and associations
- [ ] Store money as integer cents and explain why
- [ ] Add scopes: `Donation.succeeded`, `Donation.for_fund(fund)`, `Donation.in_range(from, to)`, `Donation.recurring`
- [ ] Add a status enum: pending, processing, succeeded, failed, refunded
- [ ] Model specs for every validation, association, and scope
- [ ] Seed data with Faker

Talk-track: draw the schema from memory and explain each association and index.

Bug drill: remove a foreign key index, load a page that filters on it, and read the query plan with `EXPLAIN ANALYZE` in `psql`. Then remove a `null: false` constraint and show how bad data gets in.

Interview questions this prepares:

- What is the difference between a validation and a database constraint, and why have both?
- What does an index do and what does it cost?
- What is a scope and how is it different from a class method?

---

## Phase 2: REST API (Core)

`JD: REST web services, MVC, Rails`

Endpoints under `/api/v1`:

| Verb | Path | Purpose |
| --- | --- | --- |
| GET | `/funds` | List active funds |
| POST | `/donations` | Create a pending donation and a payment intent |
| GET | `/donations/:id` | Donation status for the confirmation page |
| POST | `/webhooks/stripe` | Receive Stripe events |
| GET | `/admin/donations` | Admin list with filters and pagination |
| GET | `/admin/reports/summary` | Totals by fund and date range |

Tasks:

- [ ] Versioned, namespaced routes
- [ ] Strong parameters on every write
- [ ] Consistent JSON shape and error format with correct status codes (201, 404, 422)
- [ ] Serializers so models are not dumped raw
- [ ] CORS configured for the React origin only
- [ ] Devise protecting the admin namespace
- [ ] Request specs for the happy path and each failure path

Talk-track: walk one request through router, controller, model, serializer, and response.

Bug drill: drop a field from the `permit` list and find it from the "Unpermitted parameter" log line. Swap two routes so the wrong action runs and find it with `bin/rails routes`.

Interview questions this prepares:

- What makes an API RESTful?
- When do you return 422 versus 400 versus 404?
- How do strong parameters protect you?

---

## Phase 3: Payments, idempotency, background jobs (Core)

`JD: service orientation, object-oriented design, mocking, debugging`

This phase closes the three gaps most likely to be probed: scopes (done in Phase 1), background jobs, and idempotency.

Tasks:

- [ ] `Donations::Create` service object: validates input, creates the donation, creates the Stripe PaymentIntent
- [ ] Client sends an `Idempotency-Key` header; the API stores it with a unique index and returns the original donation on a repeat request
- [ ] Pass the same key to Stripe so a retried request cannot create a second charge
- [ ] Webhook controller verifies the Stripe signature
- [ ] `ProcessedEvent` table with a unique index on the Stripe event id so a redelivered webhook is ignored
- [ ] `Donations::MarkSucceeded` and `Donations::MarkFailed` services called from the webhook
- [ ] Guard status transitions so only valid moves are allowed (pending to processing to succeeded or failed, succeeded to refunded)
- [ ] `ReceiptMailerJob` and `TributeNotificationJob` run through Active Job, with retries
- [ ] Recurring gifts through a Stripe subscription and its invoice webhooks
- [ ] Specs that stub Stripe with WebMock or instance doubles, including a duplicate request spec and a duplicate webhook spec

Talk-track, the most important one in the plan: "Here is exactly what stops a double charge." Cover the disabled button, the idempotency key and unique index, Stripe's own idempotency, and webhook de-duplication. State which of these you built on the original project and which you added in this rebuild.

Bug drill: send the same webhook twice with the de-dup check removed and watch two receipts go out. Raise an error inside a job and inspect the retry. Wrap a multi-step write without a transaction and leave half-written data.

Interview questions this prepares:

- Define idempotency in one sentence.
- Why does card data never reach your server, and why does that matter?
- What is the difference between a mock and a stub?
- Why move email sending to a background job?
- What happens if the webhook arrives before the browser redirect?

---

## Phase 4: React donation flow (Core)

`JD: React, JavaScript, HTML5, CSS3, Jest`

Tasks:

- [ ] Multi-step form: amount and frequency, fund selection, optional tribute, donor details, payment, confirmation
- [ ] Stripe Payment Element mounted with the client secret from the API
- [ ] API client module with one place for base URL, headers, and error handling
- [ ] Generate the idempotency key once per donation attempt and reuse it on retry
- [ ] Loading, error, and empty states for every request
- [ ] Client-side validation plus display of server validation errors
- [ ] Semantic HTML, labeled inputs, keyboard navigation, visible focus (government projects must meet Section 508)
- [ ] Component tests with React Testing Library: renders, validates, submits, shows an error

Talk-track: explain the component tree, where each piece of state lives, and why.

Bug drill: mutate an array in state, remove a `useEffect` dependency, remove the dependency array from a fetching effect, use the array index as a `key` on a reorderable list, and ignore `response.ok`. Find each using the console, Network tab, and React DevTools.

Interview questions this prepares:

- What triggers a re-render?
- What is a stale closure?
- Why does `fetch` not throw on a 500?

---

## Phase 5: Redux (Core)

`JD: React and Redux`

Tasks:

- [ ] Add Redux Toolkit and React Redux
- [ ] `donationSlice` holding the in-progress gift across steps: amount, frequency, fund, tribute, donor
- [ ] `fundsSlice` loaded with `createAsyncThunk`, with pending, fulfilled, and rejected states
- [ ] Memoized selectors, for example the summary line shown on the review step
- [ ] Admin dashboard filters kept in the store
- [ ] Reducer and selector unit tests in Jest
- [ ] Use Redux DevTools to step through the action log for one full donation

Talk-track: explain store, action, reducer, selector, and one-way data flow using this app, then connect it to the Flatiron keyboard cart. Be ready to say when Redux is not worth it.

Bug drill: write a plain reducer that mutates state outside of Toolkit and watch the component fail to update. Dispatch an action with a typo in its type and trace why nothing happens.

Interview questions this prepares:

- Why must reducers be pure?
- What does Redux Toolkit do for you compared with hand-written Redux?
- Local state, context, or Redux: how do you choose?

---

## Phase 6: Admin reporting, performance, debugging week (Core)

`JD: debugging and correcting errors, RDBMS, testing and support`

Tasks:

- [ ] Admin list with filters by fund, status, date range, and pagination
- [ ] Summary report: totals and counts by fund and by month using `group` and `sum`
- [ ] Write one report in raw SQL as well, and compare it with the Active Record version
- [ ] Introduce and then fix an N+1 on the admin list with `includes`
- [ ] Add request logging with a request id so one donation can be traced through the log
- [ ] Central error handling in the API (`rescue_from`) with a consistent JSON error body

Debugging week: have the scaffolder agent plant five bugs across the stack without telling you where. For each one, record yourself narrating the six steps: clarify, read the error, reproduce, isolate, hypothesize and test, verify and protect with a test.

Interview questions this prepares:

- How would you find a slow endpoint?
- Inner join versus left join?
- What does a database transaction guarantee?

---

## Phase 7: SOAP integration (Stretch)

`JD: SOAP web services, service orientation`

The employer matching lookup is the natural place for this.

- [ ] Read a WSDL and identify the operations, messages, and types
- [ ] Add the Savon gem and write `EmployerMatch::Lookup`, a client class that calls a SOAP operation and returns a plain Ruby object
- [ ] For a service to call, stand up a small local fake that returns a fixed SOAP envelope, or record a response and replay it with WebMock
- [ ] Handle a SOAP fault and a timeout
- [ ] Spec the client against the recorded XML
- [ ] Expose the result through your REST API so the React app never sees XML

Talk-track: compare SOAP and REST on contract (WSDL versus convention or OpenAPI), format (XML envelope versus JSON), transport, error handling (faults versus status codes), and where each still shows up. Be honest that this is study work and not production experience.

---

## Phase 8: Docker and CI (Stretch)

`JD: containerized applications, CI/CD, deployment`

- [ ] `Dockerfile` for the API
- [ ] `docker-compose.yml` running the API, Postgres, and the job worker
- [ ] GitHub Actions workflow that runs RSpec and Jest on every pull request
- [ ] Read one sample Jenkinsfile and map its stages to your workflow file

```bash
docker compose up --build
docker compose exec api bin/rails db:prepare
docker compose exec api bundle exec rspec
```

Talk-track: image versus container, why a pipeline runs tests before merge, and what Kubernetes and OpenShift add on top of containers. Framing: you have built this locally and want to grow into running it in production.

---

## Phase 9: AWS (Stretch)

`JD: AWS technologies`

- [ ] Active Storage with an S3 bucket for generated PDF receipts or tribute images
- [ ] Bucket kept private, files served through signed URLs
- [ ] IAM user limited to that one bucket
- [ ] Credentials kept in Rails encrypted credentials or environment variables, never in Git

Talk-track: how an upload travels from the browser to S3 and how least privilege applies.

---

## Phase 10: Polish and interview packaging (Core, final day)

- [ ] README covering architecture, data model diagram, setup, and test commands
- [ ] `docs/DECISIONS.md` with five short entries: why API mode, why integer cents, how double charges are prevented, why jobs for email, what you would change at ten times the volume
- [ ] `docs/BUGS.md` logging each planted bug: symptom, how you found it, fix, test added
- [ ] A five-minute spoken walkthrough of one donation from click to receipt, recorded and replayed
- [ ] A two-minute version of the same walkthrough
- [ ] One paragraph on how the status transitions in Phase 3 relate to workflow engines such as Camunda, which model the same idea as an explicit process diagram

## Suggested pacing

Superseded for the 2026-12-02 interview by "Interview timeline and scope" near the top of this file. The table below is the original open-ended pacing.

| Time available | What to do |
| --- | --- |
| 3 days | Phases 0 to 3 built, Phases 4 and 5 as a thin slice, read 7 and 8 |
| 5 to 7 days | Phases 0 to 6 built, Phase 7 built, read 8 and 9, then Phase 10 |
| 10 or more days | Everything, with a full debugging week |

## Free references

- Rails Guides: https://guides.rubyonrails.org
- Rails API docs: https://api.rubyonrails.org
- RSpec documentation: https://rspec.info/documentation
- Stripe documentation (PaymentIntents, webhooks, idempotent requests): https://docs.stripe.com
- React documentation: https://react.dev/learn
- Redux Essentials tutorial: https://redux.js.org/tutorials/essentials/part-1-overview-concepts
- Jest documentation: https://jestjs.io/docs/getting-started
- Testing Library documentation: https://testing-library.com/docs
- PostgreSQL tutorial: https://www.postgresql.org/docs/current/tutorial.html
- Docker getting started: https://docs.docker.com/get-started
