require 'rails_helper'

RSpec.describe SessionHelper, type: :helper do
  describe "メソッド確認" do
    let!(:set) { FactoryBot.create(:random_set) }
    let!(:lot) { FactoryBot.create(:lottery, random_set_id: set.id) }
    let!(:user) { FactoryBot.create(:user) }
    describe "random_set" do
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
            expect(helper.session[:set_session_token]).to eq set.session_digest
          end
        end
        context "remember" do
          it "remmberで記憶されるか" do
            helper.remember(set, "password")
            expect(helper.cookies[:set_session_token]).to_not eq ""
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
    describe "user" do
      before do
        allow(helper).to receive(:params).and_return({ id: user.id, session: { password: user.password } })
      end
      context "user_log in" do
        it "ログイン後、トークンが登録されているか" do
          helper.user_log_in(user)
          expect(helper.session[:user_session_token]).to eq user.session_digest 
        end
      end
      context "user_logged_in?" do
        it "そのままなら失敗する" do
          expect(helper.user_logged_in?).to eq false
        end
      end
      context "user_remember" do
        it "user_rememberで記録されるか" do
          helper.user_remember(user)
          expect(helper.cookies[:user_id]).to eq user.id
        end
      end
      context "user_log_out" do
        it "ログイン後、ログアウトすると情報が消えているか" do
          helper.user_remember(user)
          helper.user_log_in(user)
          expect(helper.session[:user_session_token]).to eq user.session_digest
          expect(helper.cookies[:user_id]).to eq user.id
          expect(helper.user_logged_in?).to eq true
          helper.user_log_out
          expect(helper.session[:user_session_token]).to_not eq user.session_digest
          expect(helper.cookies[:user_id]).to_not eq user.id
          expect(helper.user_logged_in?).to eq false
        end
      end
    end
    describe "混合時の干渉確認" do
      context "keep_reset_session" do
        it "userログイン中にrandom_setにログインしてもuserログイン情報があるか" do
          allow(helper).to receive(:params).and_return({ id: user.id, session: { password: user.password } })
          helper.user_remember(user)
          helper.user_log_in(user)
          expect(helper.user_logged_in?).to eq true
          expect(helper.session[:user_session_token]).to eq user.session_digest
          expect(helper.cookies[:user_id]).to eq user.id

          allow(helper).to receive(:params).and_return({ id: set.id, session: { password: set.password } })
          helper.remember(set, set.password)
          helper.log_in(set)
          expect(helper.user_logged_in?).to eq true
          expect(helper.session[:user_session_token]).to eq user.session_digest
          expect(helper.cookies[:user_id]).to eq user.id
          expect(helper.logged_in?).to eq true
          expect(helper.session[:set_session_token]).to eq set.session_digest
          expect(helper.cookies[:set_id]).to eq set.id
        end
        it "random_setログイン中にuserにログインしてもrandom_setログイン情報があるか" do
          allow(helper).to receive(:params).and_return({ id: set.id, session: { password: set.password } })
          helper.remember(set, set.password)
          helper.log_in(set)
          expect(helper.logged_in?).to eq true
          expect(helper.session[:set_session_token]).to eq set.session_digest
          expect(helper.cookies[:set_id]).to eq set.id

          allow(helper).to receive(:params).and_return({ id: user.id, session: { password: user.password } })
          helper.user_remember(user)
          helper.user_log_in(user)
          expect(helper.user_logged_in?).to eq true
          expect(helper.session[:user_session_token]).to eq user.session_digest
          expect(helper.cookies[:user_id]).to eq user.id
          expect(helper.logged_in?).to eq true
          expect(helper.session[:set_session_token]).to eq set.session_digest
          expect(helper.cookies[:set_id]).to eq set.id
        end
      end
    end
  end
end
