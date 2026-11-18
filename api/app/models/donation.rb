class Donation < ApplicationRecord
  belongs_to :donor
  belongs_to :fund

  enum :status, [ :pending, :processing, :succeeded, :failed, :refunded ]
  enum :frequency, {
    one_time: 0,
    monthly: 1
  }

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
