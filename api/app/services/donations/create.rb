module Donations
  # Creates a pending donation, then asks Stripe for a PaymentIntent.
  #
  #   result = Donations::Create.call(params: ..., donor_params: ..., idempotency_key: ...)
  #   result.donation, result.client_secret, result.created?, result.success?, result.errors, result.error_kind
  #
  # Order matters: the donation is saved BEFORE Stripe is called, so a PaymentIntent
  # can never exist without a donation row that matches it.
  class Create
    Result = Struct.new(:donation, :client_secret, :created, :errors, :error_kind, keyword_init: true) do
      def created? = created
      def success? = errors.blank?
    end

    def self.call(**kwargs)
      new(**kwargs).call
    end

    def initialize(params:, donor_params:, idempotency_key:)
      @params = params
      @donor_params = donor_params
      @idempotency_key = idempotency_key
    end

    def call
      existing = Donation.find_by(idempotency_key: @idempotency_key)
      return replay(existing) if existing

      donation = build_donation
      return invalid(donation) unless donation.save

      charge(donation, created: true)
    rescue ActiveRecord::RecordNotUnique
      # Two requests with the same key passed the check above at the same moment.
      # The unique index let one win. Return the winner's donation.
      existing = Donation.find_by(idempotency_key: @idempotency_key)
      raise unless existing

      replay(existing)
    end

    private

    def build_donation
      donor = Donor.find_or_initialize_by(email: @donor_params[:email])
      donor.name = @donor_params[:name] if donor.new_record?

      Donation.new(
        donor: donor,
        fund_id: @params[:fund_id],
        amount_cents: @params[:amount_cents],
        frequency: @params[:frequency] || :one_time,
        idempotency_key: @idempotency_key
      )
    end

    # The first gift is a one-off PaymentIntent. Monthly plans would use a Stripe subscription (not built).
    # The same idempotency key goes to Stripe, so a retry cannot create a second PaymentIntent either.
    def charge(donation, created:)
      intent = Stripe::PaymentIntent.create(
        { amount: donation.amount_cents, currency: donation.currency, metadata: { donation_id: donation.id } },
        { idempotency_key: @idempotency_key }
      )
      donation.update!(stripe_payment_intent_id: intent.id)

      Result.new(donation: donation, client_secret: intent.client_secret, created: created, errors: [])
    rescue Stripe::StripeError => e
      donation.failed!
      Result.new(donation: donation, created: created, errors: [ "Payment could not be started: #{e.message}" ],
                 error_kind: :payment)
    end

    # A retry with the same key: hand back the first donation instead of making a new one.
    def replay(donation)
      # The first attempt saved the donation but never reached Stripe (for example a crash). Finish the job.
      return charge(donation, created: false) if donation.pending? && donation.stripe_payment_intent_id.blank?

      secret = donation.stripe_payment_intent_id.present? ? retrieve_secret(donation) : nil
      Result.new(donation: donation, client_secret: secret, created: false, errors: [])
    rescue Stripe::StripeError => e
      Result.new(donation: donation, created: false, errors: [ "Payment could not be loaded: #{e.message}" ],
                 error_kind: :payment)
    end

    def retrieve_secret(donation)
      Stripe::PaymentIntent.retrieve(donation.stripe_payment_intent_id).client_secret
    end

    def invalid(donation)
      Result.new(donation: donation, created: false, errors: donation.errors.full_messages, error_kind: :validation)
    end
  end
end
