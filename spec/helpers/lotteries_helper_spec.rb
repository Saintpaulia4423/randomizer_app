# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LotteriesHelper, type: :helper do
  describe "get_realityname_list" do
    it "Array形式で情報が返ってくること" do
      expect(get_realityname_list().is_a?(Array)).to eq(true)
    end
  end
  describe "get_realityname" do
    context "egt_realityname_listとの関連した機能" do
      let(:items) { get_realityname_list() }
      it "それぞれにおいて情報が返ってくること" do
        items.each do |item|
          expect(get_realityname(item).is_a?(String)).to eq(true)          
        end
      end
    end
  end
end
