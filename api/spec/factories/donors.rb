FactoryBot.define do
  factory :donor do
    name { Faker::Name.name }
    sequence(:email) { |n| "donor#{n}@example.com" }
  end
end
