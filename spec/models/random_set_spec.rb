# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RandomSet, type: :model do
  describe "method処理の確認" do
    let(:set) { FactoryBot.create(:random_set) }
    let(:lot) { FactoryBot.create(:lottery, random_set_id: set.id) }
    it "remember forget test" do
      session = set.remember
      expect(set.session_digest).to eq(session)
      set.forget
      expect(set.session_digest).to eq(nil)
    end
    it "session_check test" do
      password = "test"
      expect(set.session_check(password)).to eq(true)
    end
    context "rate_pickup_rate_with_array_into_fixed_hash test" do
      it "invalid hash key" do
        set.update(rate: [ { invalid: 0 } ])
        expect(set.errors.full_messages[0]).to include("is invalid: Must include keys reality and value")
      end
      it "invalid hash value" do
        set.update(rate: [ { reality: "invalid", value: 0 } ])
        expect(set.errors.full_messages[0]).to include("is invalid: Only values")
      end
    end
  end
end
