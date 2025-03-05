# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RandomSetsHelper, type: :helper do
  describe "get_infomation_conversionの各種テスト" do
    context "入力された情報が返ってくること" do
      it "type情報" do
        expect(get_infomation_conversion("mix").is_a?(String)).to eq(true)
        expect(get_infomation_conversion("box").is_a?(String)).to eq(true)
      end
    end
  end
end
