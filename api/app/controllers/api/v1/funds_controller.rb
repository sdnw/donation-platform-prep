module Api
  module V1
    class FundsController < ApplicationController
      def index
        funds = Fund.active.order(:name).select(:id, :name, :slug, :is_default)

        render json: funds, status: :ok
      end
    end
  end
end
