require 'rails_helper'

RSpec.describe "Users", type: :system do
  before do
    driven_by :selenium_headless
  end

  let!(:set) { FactoryBot.create(:random_set) }
  let!(:util_lot) { FactoryBot.create(:lottery, :with_pickup, :with_dict, random_set_id: set.id) }
  let!(:user) { FactoryBot.create(:user) }
  describe "headerの表示確認" do
    before do
      visit root_path
    end
    it "ログインしていなければログインの表示" do
      expect(page).to have_content("ログイン")
    end
    it "ログインしていればuser_idが表示される" do
      visit login_path(id: 0, session_mode: "user", title: "ユーザーログイン")
      fill_in "session[user_id]", with: user.user_id
      fill_in "session[password]", with: user.password
      find(:xpath, "//input[@type='submit']").click
      visit root_path
      expect(page).to have_content(user.user_id)
    end
  end
  describe "new" do
    it "newページに遷移できる" do
      visit root_path
      click_link "ログイン"
      expect(page).to have_content("ユーザーログイン")
      within ".modal" do
        click_link "こちら"
      end
      expect(page).to have_content("ユーザー登録")
      expect(current_path).to eq new_user_path
    end
    it "newで新たなユーザーが作成できる" do
      new_user = { user_id: "new_user", password: "password" }
      visit new_user_path
      fill_in "user[user_id]", with: new_user[:user_id]
      fill_in "user[password]", with: new_user[:password]
      find(:xpath, "//input[@type='submit']").click
      expect(page).to have_content("ユーザー情報")
      expect(page).to have_content(new_user[:user_id])
    end
  end
  describe "show" do
    before do
      visit login_path(id: 0, session_mode: "user", title: "ユーザーログイン")
      fill_in "session[user_id]", with: user.user_id
      fill_in "session[password]", with: user.password
      find(:xpath, "//input[@type='submit']").click
    end
    describe "user機能の確認" do
      it "ログアウトができるか" do
        visit user_path(user.id)
        expect(page).to have_content("ユーザー情報")
        expect(current_path).to eq user_path(user.id)
        click_button "ログアウト"
        page.accept_alert
        expect(page).to have_content("ログイン")
        expect(current_path).to eq root_path
      end
      it "ユーザーを削除できるか" do
        visit user_path(user.id)
        expect(page).to have_content("ユーザー情報")
        expect(current_path).to eq user_path(user.id)
        click_button "ユーザーの削除"
        page.accept_alert
        expect(page).to have_content("ログイン")
        result = User.find_by(id: user.id)
        expect(result).to eq nil
      end
    end
    describe "userとrandom_setの連動の確認" do
      it "favoriteがなければ定型文が表示される" do
        visit user_path(user.id)
        expect(page).to have_content("まだお気に入りが登録されていません。")
      end
      it "favoriteがあればそのset.nameが表示され、お気に入り数が表示されるか" do
        user.add_favorite(set)
        added_set = RandomSet.find(set.id)
        visit user_path(user.id)
        within "turbo-frame[id=favorite]" do
          expect(page).to_not have_content("まだお気に入りが登録されていません。")
          expect(page).to have_content(added_set.name)
          expect(page).to have_content(added_set.favorities_count)
        end
      end
      it "favoriteが削除できるか" do
        user.add_favorite(set)
        visit user_path(user.id)
        within "turbo-frame[id=favorite]" do
          expect(page).to have_content(set.name)
          find("#favorite_delete_button_#{set.id}").click
          page.accept_alert
          expect(page).to_not have_content(set.name)
        end
      end
      it "createdがなければ定型文が評される" do
        visit user_path(user.id)
        expect(page).to have_content("まだセットを作成したことがありません。")
      end
      it "createdがあれば表示される" do
        user.add_random_set(set)
        visit user_path(user.id)
        within "turbo-frame[id=created]" do
          expect(page).to have_content(set.name)
          expect(page).to have_content(set.favorities_count)
        end
      end
      it "createdのにおいてfavorite数が表示される" do
        user.add_random_set(set)
        user.add_favorite(set)
        added_set = RandomSet.find(set.id)
        visit user_path(user.id)
        within "turbo-frame[id=created]" do
          expect(page).to have_content(added_set.name)
          expect(page).to have_content(added_set.favorities_count)
        end
      end
    end
  end
end
