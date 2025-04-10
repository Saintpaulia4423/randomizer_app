require 'rails_helper'

RSpec.describe "StaticPages", type: :request do
  describe "GET static_pages" do
      describe "ページの表示確認" do
      it "home" do
        get home_path
        expect(response.body).to include("使ってみる")
      end
      it "guide" do
        get guide_path
        expect(response.body).to include("他の設定について")
      end
    end
  end
end
