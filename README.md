# Donation Platform

Rails API + React donation workflow, rebuilt for interview prep.

## Setup

```bash
# API (http://localhost:3000)
cd api
bundle install
bin/rails db:create db:migrate
bin/rails server

# Web (http://localhost:5173)
cd web
npm install
npm run dev
```

## Tests

```bash
cd api && bundle exec rspec
cd web && npm test   # added in Phase 4
```

## Architecture

<!-- YOUR TURN: sketch the browser, React app, Rails API, Postgres, Stripe, and the webhook path.
     Label each arrow (HTTP/JSON, Stripe.js, webhook POST). Then answer: why two separate apps? -->

TODO

## Data model

TODO (Phase 1)
