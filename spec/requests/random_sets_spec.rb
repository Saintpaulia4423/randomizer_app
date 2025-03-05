# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "RandomSets", type: :request do
  describe "GET /random_sets" do
    let!(:set) { FactoryBot.create(:random_set) }
    let!(:lot) { FactoryBot.create_list(:lottery, 5, random_set_id: set.id)}
    before do
      get random_set_path(set.id)
    end
    context "基本表示" do
      it "http status code 200となる" do
        expect(response).to have_http_status(:success)
      end
      it "タイトルがセット名と同じになる" do
        title = Nokogiri::HTML(response.body).title
        expect(title).to include(set.name)
      end
      it "lotteryがすべて含まれる" do
        set.lotteries.each do |lottery| 
          expect(response.body).to include(lottery.name)
        end
      end
    end
  
    context "各種カードの確認" do
      it "セット情報" do
        expect(response.body).to include("セット情報")
      end
      it "ランダマイザー" do
        expect(response.body).to include("ランダマイザー")
      end
      it "結果表示" do
        expect(response.body).to include("結果表示")
      end
      it "セット内容" do
        expect(response.body).to include("セット内容")
      end
    end



    context "例外処理" do
      it "存在しないidに対しては404となる。(今回はid:0で検証)" do
        get random_set_path(id: 0)
        expect(response).to have_http_status(:missing)
      end
    end
  end
end
