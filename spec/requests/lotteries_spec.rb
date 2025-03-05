# frozen_string_literal: true

require 'rails_helper'
require "nokogiri"

RSpec.describe "Lotteries", type: :request do
  let!(:set) { FactoryBot.create(:random_set) }
  let!(:dict_lot) { FactoryBot.create(:lottery, :with_dict, random_set_id: set.id) }
  let!(:pickup_lot) { FactoryBot.create(:lottery, :with_pickup, random_set_id: set.id) }
  let!(:checked_lot) { FactoryBot.create(:lottery, :with_checked, random_set_id: set.id) }
  describe "lottery表示" do
    before do
      get random_set_path(set.id)
    end
    context "lotteryの表示の確認" do
      it "lottery_with_dictが正しく全て表示されている。" do
        target_lottery = Nokogiri::HTML(response.body).css("[data-randomizer-target=lotteries]")[0]
        test_pickup = target_lottery.css("span[data-value=0]").children.text
        test_name = target_lottery.css("td")[-2].text
        test_dict = target_lottery.css("td")[-1].text

        expect(test_pickup).to include("★0")
        expect(test_name).to include(dict_lot.name)
        expect(test_dict).to include(dict_lot.dict)
      end
      it "pickup lotteryでは正しくpick upが強調表示されている。(CSS.flip-opacityの有無で確認)" do
        target_lottery = Nokogiri::HTML(response.body).css("[data-randomizer-target=lotteries]")[1]
        target_pickup = target_lottery.css(".bi-stars")[0].attribute_nodes[0].value
        expect(target_pickup).to_not include("flip-opacity")
      end
      it "checked_lotteryでは正しくチェックされていいる。（checkedの有無で確認する）" do
        target_lottery = Nokogiri::HTML(response.body).css("[data-randomizer-target=lotteries]")[2]
        target_checkbox = target_lottery.css("[type=checkbox]")[0].attribute_nodes[3].value
        expect(target_checkbox).to include("checked")
      end
    end
  end
end
