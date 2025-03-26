require 'rails_helper'

RSpec.describe SessionHelper, type: :helper do
  describe "メソッド確認" do
    let!(:set) { FactoryBot.create(:random_set) }
    let!(:lot) { FactoryBot.create(:lottery, random_set_id: set.id) }
    describe "セッションについての確認" do
      before do
        allow(helper).to receive(:params).and_return({ id: set.id, session: { password: set.password } })
      end
      context "logged_in?" do
        it "そのままならfalseが返る" do
          expect(helper.logged_in?).to eq false
        end
      end
      context "get_random_set" do
        it "同じものが取得されるか" do
          helper.get_random_set
          expect(helper.instance_variable_get(:@random_set)).to eq set
        end
      end
      context "log_in" do
        it "sessionにsession_tokenが書き込まれているか確認" do
          helper.log_in(set)
          expect(helper.session[:session_token]).to eq set.session_digest
        end
      end
      context "remember" do
        it "remmberで記憶されるか" do
          helper.remember(set, "password")
          expect(helper.cookies[:session_token]).to_not eq ""
          expect(helper.cookies[:password_token]).to_not eq ""
        end
      end
      context "current_set_session" do
        it "通常のログイン挙動によりログインされるか" do
          helper.remember(set, "password")
          helper.log_in(set)
          expect(helper.logged_in?).to eq true
        end
      end
    end
  end
end
