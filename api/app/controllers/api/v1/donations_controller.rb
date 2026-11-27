module Api
  module V1
    class DonationsController < ApplicationController
      def create
        key = request.headers["Idempotency-Key"]
        return render_error("Idempotency-Key header is required", :bad_request) if key.blank?

        # A retry with the same key gets the first donation back instead of a new one.
        existing = Donation.find_by(idempotency_key: key)
        return render json: donation_json(existing), status: :ok if existing

        donation = build_donation(key)

        # Phase 3: Donations::Create will also make the Stripe PaymentIntent and return its client_secret.
        if donation.save
          render json: donation_json(donation), status: :created
        else
          render json: { errors: donation.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotUnique
        # Two requests with the same key passed the check above at the same moment.
        # The unique index let one win. Return the winner's donation.
        existing = Donation.find_by(idempotency_key: key)
        raise unless existing

        render json: donation_json(existing), status: :ok
      end

      private

      def build_donation(key)
        donor = Donor.find_or_initialize_by(email: donor_params[:email])
        donor.name = donor_params[:name] if donor.new_record?

        Donation.new(
          donor: donor,
          fund_id: donation_params[:fund_id],
          amount_cents: donation_params[:amount_cents],
          frequency: donation_params[:frequency] || :one_time,
          idempotency_key: key
        )
      end

      def donation_params
        params.require(:donation).permit(:amount_cents, :fund_id, :frequency)
      end

      def donor_params
        params.require(:donation).require(:donor).permit(:name, :email)
      end

      def donation_json(donation)
        {
          id: donation.id,
          amount_cents: donation.amount_cents,
          currency: donation.currency,
          status: donation.status,
          frequency: donation.frequency,
          fund_id: donation.fund_id,
          donor: {
            id: donation.donor.id,
            name: donation.donor.name,
            email: donation.donor.email
          }
        }
      end
    end
  end
end
