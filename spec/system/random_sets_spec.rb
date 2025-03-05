require 'rails_helper'

RSpec.describe "RandomSets", type: :system do
  before do
    driven_by :selenium_headless
  end
  describe "random_set" do
    let!(:set) { FactoryBot.create(:random_set) }
    let!(:another_set) { FactoryBot.create(:random_set, name: "Another_test", dict: "in dict") }
    let!(:util_lot) { FactoryBot.create(:lottery, :with_pickup, :with_dict, random_set_id: set.id) }
    let!(:another_set_5lots) { FactoryBot.create_list(:lottery, 5, random_set_id: another_set.id) }
    describe "index" do
      before(:each) do
        visit random_sets_path
      end
      describe "表示の確認" do
        it "テストセットが表示されているか" do
          expect(page).to have_content(set.name)
          expect(page).to have_content(another_set.name)
          expect(page).to have_content(another_set.dict)
        end
      end
      describe "リンクの確認" do
        it "newに遷移できるか" do
          click_link "登録"
          expect(current_path).to eq new_random_set_path
        end
        it "lotteryから個別のrandom_setにアクセスできるか" do
          within "#random_set_#{set.id}" do
            click_link "選択"
          end
          expect(current_path).to eq random_set_path(set.id)
        end
      end
      describe "ransackの確認" do
        it "検索機能が利用できるか。another_setが消えているかで判定" do
          fill_in "q_name_cont",	with: "Test_Random" 
          find_field("q_name_cont").send_keys(:enter)
          expect(page).to have_content(set.name)
          expect(page).to_not have_content(another_set.name)
        end
        it "検索後、リセットが正常に働くか" do
          fill_in "q_name_cont", with: "Test_Random"
          find_field("q_name_cont").send_keys(:enter)
          expect(page).to_not have_content(another_set.name)
          # ransackの処理のため二回クリック
          click_link "リセット"
          click_link "リセット"
          expect(page).to have_content(another_set.name)
        end

        it "並び替え機能が利用できるか。（新規順→古い順で確認）" do
          visit random_sets_path
          within "#random-set-list" do
            elements = all("turbo-frame")
            expect(elements[0].text).to have_content(another_set.name)
            expect(elements[1].text).to have_content(set.name)
            # ransackの処理のため二回クリック
            find("a.sort_link.btn").click
            find("a.sort_link.btn").click
            elements = all("turbo-frame")
            expect(elements[0].text).to have_content(set.name)
            expect(elements[1].text).to have_content(another_set.name)
          end
        end
      end

      describe "modalの確認" do
        it "確認を押してmodalが表示され、その中にあるlotteryが表示されるかどうか" do
          within "#random_set_#{set.id}" do
            click_link "確認"
          end
          within ".modal" do
            expect(page).to have_content(set.name)
            expect(page).to have_content(util_lot.name)
            expect(page).to have_content("★0")
          end
        end
        it "別のsetを開いた際に情報が混同しないか" do
          within "#random_set_#{set.id}" do
            click_link "確認"
          end
          within ".modal" do
            expect(page).to have_content(set.name)
            # modal close処理。testでは3回クリックでないと反応しない。
            find("button.btn-close").click
            find("button.btn-close").click
            find("button.btn-close").click
          end
          within "#random_set_#{another_set.id}" do
            click_link "確認"
          end
          within ".modal" do
            expect(page).to_not have_content(set.name)
            expect(page).to have_content(another_set.name)
            expect(page).to have_content(another_set_5lots[0].name)
          end
        end
        it "複数のlotが存在する場合に並び替えができるか" do
          within "#random_set_#{another_set.id}" do
            click_link "確認"
          end
          within ".modal" do
            expect(page).to have_content(another_set.name)
            # table headerのため要素は[1]から
            elements = all("tr")
            expect(elements[5]).to have_content(another_set_5lots[4].name)
            expect(elements[1]).to have_content(another_set_5lots[0].name)
            elements[0].all("th")[4].click
            elements[0].all("th")[4].click
            elements = all("tr")
            expect(elements[5]).to have_content(another_set_5lots[0].name)
            expect(elements[1]).to have_content(another_set_5lots[4].name)
          end
        end
      end
    end
    describe "show" do
    end
    describe "new" do
    end
  end      
end
