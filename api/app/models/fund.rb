class Fund < ApplicationRecord
  normalizes :slug, with: ->(slug) { slug.downcase.strip }
  normalizes :name, with: ->(name) { name.strip }

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }

  has_many :donations, dependent: :restrict_with_error

  scope :active, -> { where(active: true) }
end
