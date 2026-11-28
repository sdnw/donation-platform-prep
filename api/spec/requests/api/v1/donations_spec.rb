require "rails_helper"

RSpec.describe "POST /api/v1/donations", type: :request do
  let(:fund) { create(:fund) }
  let(:headers) { { "Idempotency-Key" => "abc-123" } }
  let(:payload) do
    {
      donation: {
        amount_cents: 5000,
        fund_id: fund.id,
        frequency: "one_time",
        donor: { name: "Kiki Cat", email: "kiki@example.com" }
      }
    }
  end

  before do
    stub_stripe_create
    stub_stripe_retrieve
  end

  def post_donation(body = payload, extra_headers = headers)
    post "/api/v1/donations", params: body, headers: extra_headers, as: :json
  end

  it "creates a pending donation and returns 201 with a client_secret" do
    post_donation

    expect(response).to have_http_status(:created)
    json = response.parsed_body
    expect(json["status"]).to eq("pending")
    expect(json["amount_cents"]).to eq(5000)
    expect(json["currency"]).to eq("usd")
    expect(json["donor"]["email"]).to eq("kiki@example.com")
    expect(json["client_secret"]).to eq("pi_test_1_secret_abc")
    expect(Donation.count).to eq(1)
    expect(Donor.count).to eq(1)
    expect(Donation.last.stripe_payment_intent_id).to eq("pi_test_1")
  end

  it "returns the same donation and client_secret when the same key is sent twice" do
    post_donation
    first_id = response.parsed_body["id"]

    post_donation

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["id"]).to eq(first_id)
    expect(response.parsed_body["client_secret"]).to eq("pi_test_1_secret_abc")
    expect(Donation.count).to eq(1)
    expect(stripe_create_request).to have_been_made.once
  end

  it "returns 400 when the Idempotency-Key header is missing" do
    post_donation(payload, {})

    expect(response).to have_http_status(:bad_request)
    expect(response.parsed_body["errors"]).to include("Idempotency-Key header is required")
    expect(Donation.count).to eq(0)
  end

  it "returns 422 and never calls Stripe when amount_cents is 0" do
    payload[:donation][:amount_cents] = 0

    post_donation

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body["errors"]).to include("Amount cents must be greater than 0")
    expect(Donation.count).to eq(0)
    expect(stripe_create_request).not_to have_been_made
  end

  it "returns 422 when the fund does not exist" do
    payload[:donation][:fund_id] = 0

    post_donation

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body["errors"]).to include("Fund must exist")
  end

  it "returns 422 when the donor email is missing" do
    payload[:donation][:donor].delete(:email)

    post_donation

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body["errors"]).to include("Donor email can't be blank")
    expect(Donation.count).to eq(0)
    expect(Donor.count).to eq(0)
  end

  it "returns 422 for a frequency we do not have" do
    payload[:donation][:frequency] = "weekly"

    post_donation

    expect(response).to have_http_status(:unprocessable_content)
    expect(Donation.count).to eq(0)
  end

  it "returns 502 and marks the donation failed when Stripe rejects the request" do
    stub_stripe_error

    post_donation

    expect(response).to have_http_status(:bad_gateway)
    expect(response.parsed_body["errors"].first).to include("Payment could not be started")
    expect(Donation.last.status).to eq("failed")
  end
end

RSpec.describe "GET /api/v1/donations/:id", type: :request do
  it "returns the donation status and no donor details" do
    donation = create(:donation, :succeeded)

    get "/api/v1/donations/#{donation.id}"

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to eq(
      "id" => donation.id,
      "status" => "succeeded",
      "amount_cents" => donation.amount_cents,
      "currency" => "usd",
      "frequency" => "one_time",
      "fund_id" => donation.fund_id
    )
  end

  it "returns 404 when the donation does not exist" do
    get "/api/v1/donations/0"

    expect(response).to have_http_status(:not_found)
    expect(response.parsed_body["errors"]).to include("Not found")
  end
end
