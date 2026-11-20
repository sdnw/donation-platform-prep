require 'rails_helper'

RSpec.describe "Api::V1::Donations", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/api/v1/donations/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/api/v1/donations/create"
      expect(response).to have_http_status(:success)
    end
  end

end
