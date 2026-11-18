FactoryBot.define do
  factory :donation do
    donor
    fund
    amount_cents { 5000 }
    currency { "usd" }
    status { :pending }
    frequency { :one_time }
    sequence(:idempotency_key) { |n| "key-#{n}" }
    stripe_payment_intent_id { nil }

    trait :succeeded do
      status { :succeeded }
      sequence(:stripe_payment_intent_id) { |n| "pi_test_#{n}" }
    end

    trait :monthly do
      frequency { :monthly }
    end
  end
end
