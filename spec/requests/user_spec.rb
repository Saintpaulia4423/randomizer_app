require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:user) { FactoryBot.create(:user) }
  describe "GET new" do
    it "ページが表示されるか" do
      get new_user_path
      expect(response.body).to include("ユーザー登録")
    end
  end
  describe "GET show" do
    it "ログインしていなければアクセスできない" do
      get user_path(user.id)
      expect(response.status).to_not eq 200
    end
  end
end
