require "rails_helper"

RSpec.describe Donations::Create do
  let(:fund) { create(:fund) }
  let(:amount) { 5000 }
  let(:params) { ActionController::Parameters.new(amount_cents: amount, fund_id: fund.id, frequency: "one_time").permit! }
  let(:donor_params) { ActionController::Parameters.new(name: "Kiki Cat", email: "kiki@example.com").permit! }
  let(:key) { "abc-123" }

  def call_service
    described_class.call(params: params, donor_params: donor_params, idempotency_key: key)
  end

  it "saves a pending donation, stores the PaymentIntent id and returns the client_secret" do
    stub_stripe_create

    result = call_service

    expect(result).to be_success
    expect(result).to be_created
    expect(result.donation).to be_persisted
    expect(result.donation.status).to eq("pending")
    expect(result.donation.stripe_payment_intent_id).to eq("pi_test_1")
    expect(result.client_secret).to eq("pi_test_1_secret_abc")
  end

  it "sends Stripe the same idempotency key" do
    stub_stripe_create

    call_service

    expect(stripe_create_request.with(headers: { "Idempotency-Key" => key })).to have_been_made.once
  end

  context "when the input is invalid" do
    let(:amount) { 0 }

    it "saves nothing and never calls Stripe" do
      result = call_service

      expect(result).not_to be_success
      expect(result.error_kind).to eq(:validation)
      expect(result.errors).to include("Amount cents must be greater than 0")
      expect(Donation.count).to eq(0)
      expect(Donor.count).to eq(0)
      expect(stripe_create_request).not_to have_been_made
    end
  end

  it "makes one donation and one Stripe create call when the same key is sent twice" do
    stub_stripe_create
    stub_stripe_retrieve

    first = call_service
    second = call_service

    expect(second).not_to be_created
    expect(second.donation).to eq(first.donation)
    expect(second.client_secret).to eq("pi_test_1_secret_abc")
    expect(Donation.count).to eq(1)
    expect(stripe_create_request).to have_been_made.once
  end

  context "when Stripe rejects the request" do
    before { stub_stripe_error }

    it "marks the donation failed and returns an error" do
      result = call_service

      expect(result).not_to be_success
      expect(result.error_kind).to eq(:payment)
      expect(result.donation.reload.status).to eq("failed")
    end
  end
end
