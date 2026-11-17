class Donor < ApplicationRecord
  normalizes :email, with: ->(email) { email.downcase.strip }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: { case_sensitive: false }
  validates :name, presence: true
end
