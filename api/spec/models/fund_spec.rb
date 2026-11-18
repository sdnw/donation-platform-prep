require 'rails_helper'

RSpec.describe Fund, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:slug) }

  describe "normalization" do
    it "strips spaces from the name but keeps capitals" do
      expect(Fund.new(name: " Camp Fowler ").name).to eq("Camp Fowler")
    end

    it "lowercases and strips the slug" do
      expect(Fund.new(slug: " Camp-Fowler ").slug).to eq("camp-fowler")
    end
  end

  describe "uniqueness" do
    subject { build(:fund) }

    before { create(:fund) }

    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should validate_uniqueness_of(:slug).case_insensitive }
  end

  describe "default fund" do
    it "allows only one default fund" do
      create(:fund, :default)
      expect { create(:fund, :default, name: "Other", slug: "other") }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "allows many non-default funds" do
      create_list(:fund, 2)
      expect(Fund.count).to eq(2)
    end
  end
end
