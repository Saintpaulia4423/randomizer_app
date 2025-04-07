require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "new" do
    let!(:set) { FactoryBot.create(:random_set) }
    let!(:lot) { FactoryBot.create_list(:lottery, 5, random_set_id: set.id) }
    context "Randomset" do
      it "ログイン画面は表示されるか" do
        get login_path(id: set.id, session_mode: "random_set", title: "編集パスワード入力")
        expect(response.body).to include("編集パスワード入力")
        expect(response.body).to include('input class="form-control"')
      end
    end
  end
end
