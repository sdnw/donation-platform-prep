require 'rails_helper'

RSpec.describe Donor, type: :model do
  it { should validate_presence_of(:email) }

  describe "name" do
    it { should validate_presence_of(:name) }
  end

  it "lowercases and strips the email" do
    donor = Donor.new(email: " Bob@Example.COM ")
    expect(donor.email).to eq("bob@example.com")
  end
  it { should allow_value("bob@example.com").for(:email) }
  it { should_not allow_value("not-an-email").for(:email) }
  it { should_not allow_value("bob@").for(:email) }

describe "email uniqueness" do
  subject { Donor.new(name: "Bob Jones", email: "bob@example.com") }

  before { Donor.create!(name: "Alice Smith", email: "alice@example.com") }

  it { should validate_uniqueness_of(:email).case_insensitive }
end
end
