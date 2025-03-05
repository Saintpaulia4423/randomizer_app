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
  end
end
