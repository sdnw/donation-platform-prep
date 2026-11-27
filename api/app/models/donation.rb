class Donation < ApplicationRecord
  # autosave: true validates a brand-new donor together with the donation, so a bad donor gives a 422, not a crash.
  belongs_to :donor, autosave: true
  belongs_to :fund

  # validate: true turns a bad value like "weekly" into a normal validation error (422) instead of a crash (500).
  enum :status, [ :pending, :processing, :succeeded, :failed, :refunded ], validate: true
  enum :frequency, {
    one_time: 0,
    monthly: 1
  }, validate: true

  validates :idempotency_key,
  presence: true,
  uniqueness: true

  validates :amount_cents,
  presence: true,
  numericality: { only_integer: true, greater_than: 0 }


  validates :currency,
  presence: true,
  inclusion: { in: %w[usd], message: "%{value} is not a supported currency" }

  scope :for_fund, ->(fund) { where(fund: fund) }
  scope :in_range, ->(range) { where(created_at: range) }
  scope :recurring, -> { where.not(frequency: :one_time) }
end
