require 'rails_helper'

RSpec.describe Donation, type: :model do
  it "has a valid factory" do
    expect(build(:donation)).to be_valid
  end

  describe "associations" do
    # TODO 1: one-line shoulda matchers for belongs_to :donor and :fund
    it { should belong_to(:donor) }
    it { should belong_to(:fund) }
  end



  describe "defaults" do
    # TODO 2: a new Donation starts as pending and one_time
    describe 'enums' do
      it 'defines status values' do
        expect(Donation.statuses).to eq({
          'pending' => 0,
          'processing' => 1,
          'succeeded' => 2,
          'failed' => 3,
          'refunded' => 4
        })
      end

      it 'defines frequency values' do
        expect(Donation.frequencies).to eq({
          'one_time' => 0,
          'monthly' => 1
        })
      end
    end
  end

  describe "amount_cents" do
    # TODO 3: must be present
    # TODO 4: must be a whole number (1.5 is invalid)
    # TODO 5: must be greater than 0 (0 and -100 are invalid)

    subject(:donation) { build(:donation, amount_cents: 1000) }

    it 'is valid with a positive whole number' do
      expect(donation).to be_valid
    end

    it 'is invalid when nil' do
      donation.amount_cents = nil
      expect(donation).not_to be_valid
      expect(donation.errors[:amount_cents]).to include("can't be blank")
    end

    it 'is invalid with a decimal number' do
      donation.amount_cents = 10.50
      expect(donation).not_to be_valid
      expect(donation.errors[:amount_cents]).to include('must be an integer')
    end

    it 'is invalid when equal to 0' do
      donation.amount_cents = 0
      expect(donation).not_to be_valid
      expect(donation.errors[:amount_cents]).to include('must be greater than 0')
    end

    it 'is invalid when negative' do
      donation.amount_cents = -500
      expect(donation).not_to be_valid
      expect(donation.errors[:amount_cents]).to include('must be greater than 0')
    end
    end


  describe "currency" do
    # TODO 6: "usd" is allowed, "eur" is not
    subject(:donation) { build(:donation, currency: 'usd') }

    it 'is valid when currency is usd' do
      expect(donation).to be_valid
    end

    it 'is invalid when currency is missing' do
      donation.currency = nil
      expect(donation).not_to be_valid
      expect(donation.errors[:currency]).to include("can't be blank")
    end

    it 'is invalid when currency is not usd' do
      donation.currency = 'eur'
      expect(donation).not_to be_valid
      expect(donation.errors[:currency]).to include("eur is not a supported currency")
    end
  end


  describe "idempotency_key" do
    # TODO 7: must be present
    # TODO 8: must be unique (hint: same pattern as Donor email uniqueness)
    subject { build(:donation) }

    before { create(:donation) }

    it { should validate_presence_of(:idempotency_key) }
    it { should validate_uniqueness_of(:idempotency_key) }
  end



  describe "database guarantees" do
    # TODO 9: two donations with the same stripe_payment_intent_id
    #         raise ActiveRecord::RecordNotUnique
    # TODO 10: many donations with a nil stripe_payment_intent_id are
    it 'raises ActiveRecord::RecordNotUnique when two donations have the same stripe_payment_intent_id' do
      create(:donation, stripe_payment_intent_id: 'pi_12345')

      expect { create(:donation, stripe_payment_intent_id: 'pi_12345') }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'allows many donations with a nil stripe_payment_intent_id' do
      create_list(:donation, 2, stripe_payment_intent_id: nil)

      expect(Donation.count).to eq(2)
    end
  end
end
