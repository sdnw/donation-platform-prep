# Fake Stripe replies for specs. WebMock answers, so nothing leaves the machine.
module StripeStubs
  PAYMENT_INTENTS_URL = "https://api.stripe.com/v1/payment_intents".freeze
  JSON_HEADERS = { "Content-Type" => "application/json" }.freeze

  def stub_stripe_create(id: "pi_test_1", secret: "pi_test_1_secret_abc")
    stub_request(:post, PAYMENT_INTENTS_URL)
      .to_return(status: 200, headers: JSON_HEADERS,
                 body: { id: id, object: "payment_intent", client_secret: secret }.to_json)
  end

  def stub_stripe_retrieve(id: "pi_test_1", secret: "pi_test_1_secret_abc")
    stub_request(:get, "#{PAYMENT_INTENTS_URL}/#{id}")
      .to_return(status: 200, headers: JSON_HEADERS,
                 body: { id: id, object: "payment_intent", client_secret: secret }.to_json)
  end

  # A 400 is not retried by the Stripe client, so specs stay fast.
  def stub_stripe_error(message: "bad request")
    stub_request(:post, PAYMENT_INTENTS_URL)
      .to_return(status: 400, headers: JSON_HEADERS,
                 body: { error: { type: "invalid_request_error", message: message } }.to_json)
  end

  def stripe_create_request
    a_request(:post, PAYMENT_INTENTS_URL)
  end
end
