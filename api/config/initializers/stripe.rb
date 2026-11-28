# The secret key comes from the environment and is never committed (.env is gitignored).
# Use a TEST-mode key (sk_test_...) in development.
Stripe.api_key = ENV["STRIPE_SECRET_KEY"] || (Rails.env.test? ? "sk_test_dummy_for_specs" : nil)

# Safe to retry on network errors because every PaymentIntent create carries an idempotency key.
Stripe.max_network_retries = 2
