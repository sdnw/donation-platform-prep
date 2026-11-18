FactoryBot.define do
  factory :fund do
    sequence(:name) { |n| "Fund #{n}" }
    sequence(:slug) { |n| "fund-#{n}" }
    active { true }
    is_default { false }

    trait :default do
      name { "General Fund" }
      slug { "general" }
      is_default { true }
    end

    trait :inactive do
      active { false }
    end
  end
end
