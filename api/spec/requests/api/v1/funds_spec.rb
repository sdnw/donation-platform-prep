require "rails_helper"

RSpec.describe "GET /api/v1/funds", type: :request do
  it "returns only the active funds" do
    # TODO 1: create 2 active funds and 1 inactive fund
    active_fund_1 = create(:fund, :default)
    active_fund_2 = create(:fund)
    create(:fund, :inactive)

    # TODO 2: make the request with `get "/api/v1/funds"`
    get "/api/v1/funds"

    # TODO 3: expect status 200
    expect(response).to have_http_status(:ok)

    # TODO 4: expect only the 2 active funds back, with the keys id, name, slug, is_default
    json = JSON.parse(response.body)

    expect(json.size).to eq(2)
    expect(json).to contain_exactly(
      {
        "id" => active_fund_1.id,
        "name" => active_fund_1.name,
        "slug" => active_fund_1.slug,
        "is_default" => true
      },
      {
        "id" => active_fund_2.id,
        "name" => active_fund_2.name,
        "slug" => active_fund_2.slug,
        "is_default" => false
      }
    )
  end
end
