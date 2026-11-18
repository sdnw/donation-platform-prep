# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


funds = [
  { name: "General Fund", slug: "general", is_default: true },
  { name: "Camps",        slug: "camps" },
  { name: "Parks",        slug: "parks" },
  { name: "Shelters",     slug: "shelters" }
]

funds.each do |attrs|
  Fund.find_or_create_by!(slug: attrs[:slug]) do |fund|
    fund.name = attrs[:name]
    fund.is_default = attrs.fetch(:is_default, false)
  end
end

donors_data = [
    { email: 'test@test.com', name: 'Test Johnson' },
    { email: 'steven@test.com', name: 'Steven Dawn' },
    { email: 'kiki@example.com', name: 'Kiki Cat' },
    { email: 'yoshi@example.com', name: 'Yoshi Dog' },
    { email: 'maki@example.com', name: 'Maki Villatoro' }
]

donors = donors_data.map do |attrs|
    Donor.find_or_create_by!(email: attrs[:email]) do |donor|
      donor.name = attrs[:name]
    end
  end

  general = Fund.find_by!(slug: "general")
  camps   = Fund.find_by!(slug: "camps")
  parks   = Fund.find_by!(slug: "parks")

donations_data = [
    {
    idempotency_key: 'seed_donation_001',
    donor: donors[0],
    fund: general,
    amount_cents: 5000,
    currency: 'usd',
    status: :succeeded,
    frequency: :one_time,
    stripe_payment_intent_id: 'pi_seed_001',
    created_at: 20.days.ago
    },
    {
      idempotency_key: 'seed_donation_002',
      donor: donors[0],
      fund: camps,
      amount_cents: 2500, # $25.00
      currency: 'usd',
      status: :succeeded,
      frequency: :monthly,
      stripe_payment_intent_id: 'pi_seed_002',
      created_at: 10.days.ago
    },
    {
      idempotency_key: 'seed_donation_003',
      donor: donors[1],
      fund: parks,
      amount_cents: 10000, # $100.00
      currency: 'usd',
      status: :succeeded,
      frequency: :monthly,
      stripe_payment_intent_id: 'pi_seed_003',
      created_at: 5.days.ago
    },
    {
      idempotency_key: 'seed_donation_004',
      donor: donors[2],
      fund: general,
      amount_cents: 1500, # $15.00
      currency: 'usd',
      status: :pending,
      frequency: :one_time,
      stripe_payment_intent_id: nil,
      created_at: 1.day.ago
    },
    {
      idempotency_key: 'seed_donation_005',
      donor: donors[3],
      fund: camps,
      amount_cents: 7500, # $75.00
      currency: 'usd',
      status: :failed,
      frequency: :monthly,
      stripe_payment_intent_id: 'pi_seed_005',
      created_at: 2.hours.ago
    }
  ]

  donations_data.each do |attrs|
    Donation.find_or_create_by!(idempotency_key: attrs[:idempotency_key]) do |donation|
      donation.assign_attributes(attrs)
    end
  end
