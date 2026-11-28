module Api
  module V1
    class DonationsController < ApplicationController
      def show
        # An unknown id raises RecordNotFound, which ApplicationController turns into a 404.
        donation = Donation.find(params[:id])
        render json: status_json(donation), status: :ok
      end

      def create
        key = request.headers["Idempotency-Key"]
        return render_error("Idempotency-Key header is required", :bad_request) if key.blank?

        result = Donations::Create.call(params: donation_params, donor_params: donor_params, idempotency_key: key)

        if result.success?
          # 201 for a new donation, 200 when a retry gets the first one back.
          render json: donation_json(result.donation, client_secret: result.client_secret),
                 status: (result.created? ? :created : :ok)
        else
          # 422: the data is invalid. 502: Stripe could not be reached or refused the request.
          render json: { errors: result.errors },
                 status: (result.error_kind == :payment ? :bad_gateway : :unprocessable_content)
        end
      end

      private

      def donation_params
        params.require(:donation).permit(:amount_cents, :fund_id, :frequency)
      end

      def donor_params
        params.require(:donation).require(:donor).permit(:name, :email)
      end

      def donation_json(donation, client_secret: nil)
        json = {
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
        json[:client_secret] = client_secret if client_secret.present?
        json
      end

      # The ids in the URL are guessable, so the status page gets no donor details.
      def status_json(donation)
        {
          id: donation.id,
          status: donation.status,
          amount_cents: donation.amount_cents,
          currency: donation.currency,
          frequency: donation.frequency,
          fund_id: donation.fund_id
        }
      end
    end
  end
end
