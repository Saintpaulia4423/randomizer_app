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
            # modal close処理。testでは3回クリックでないと反応しない。ifを使い、存在しない場合のエラーを回避
            close_button = "button.btn-close"
            find(close_button).click if page.has_selector?(close_button)
            find(close_button).click if page.has_selector?(close_button)
            find(close_button).click if page.has_selector?(close_button)
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
      before do
        visit random_set_path(set.id)
      end
      describe "randomizerの確認" do
        let(:result_table) { "table[data-randomizer-target=resultTable]" }
        let(:draw_lots_num) { 999 }
        let(:target_lot) { all("tr[data-randomizer-target=lotteries]") }
        describe "draw機能の確認" do
          # lotが一つのため、結果は固定
          it "drawによりresultの値が変更されるか" do
            # １回引く
            find(:xpath, "//button[@data-action='click->randomizer#oneDraw']").click
            within result_table do
              expect(page).to have_content(util_lot.name)
              expect(page).to have_content("★0")
              expect(page).to have_content("1")
            end
          end
          context "各種drawによりヒット数の検査" do
            it "10回、100回引いて、その数が登場するか" do
              # 10回引く
              find("[data-count='10']").click
              within result_table do
                expect(page).to have_content("10")
              end
              # 100回引く
              find("[data-count='100']").click
              within result_table do
                # 前項の10回引く試験との合算による
                expect(page).to have_content("110")
              end
            end
            it "引いた結果を削除できるか" do
              # 100回引く
              find("button[data-count='100']").click
              within result_table do
                expect(page).to have_content("100")
              end
              # 結果リセット
              find(:xpath, "//button[@data-action='click->randomizer#resetResult']").click
              within result_table do
                expect(page).to_not have_content("100")
              end
            end
            it "指定数引きにより規定数引けるか" do
              fill_in "anyDrawNumber", with: draw_lots_num
              # 全てから指定数引く
              find(:xpath, "//button[@data-action='click->randomizer#specifiedDraw']").click
              within result_table do
                expect(page).to have_content(draw_lots_num)
              end
            end
          end
          context "targetを指定する" do
            before do
              visit random_set_path(another_set.id)
            end
            it "指定引きができるか" do
              target_lot_grabicon = all("td[data-controller=flip]")
              within target_lot[0] do
                target_lot_grabicon[1].double_click
                within target_lot_grabicon[1] do
                  expect(page).to_not have_css("flip-opacity")
                end
              end
              # 指定のものが出るまで引く
              find(:xpath, "//button[@data-action='click->randomizer#drawToTarget']").click
              within result_table do
                expect(page).to have_content(another_set_5lots[0].name)
                expect(page).to have_content("1")
              end
            end
            it "指定引きで他のlotが出現しない（ヒット数＝ドロー数となることで判定する" do
              target_lot_grabicon = all("td[data-controller=flip]")
              # binding.irb
              within target_lot[0] do
                target_lot_grabicon[1].double_click
              end
              # 回数はlot名称と照合する可能性がある。
              draw_count = 9
              for i in 1..draw_count
                # チェックされたものから指定数引く
                find(:xpath, "//button[@data-action='click->randomizer#drawToTarget']").click
              end
              within result_table do
                expect(page).to have_content(another_set_5lots[0].name)
                expect(page).to have_content(draw_count)
              end
            end
          end
          describe "checkの有無の確認" do
            before do
              visit random_set_path(another_set.id)
            end
            context "check有無の確認" do
              it "チェックありの指定数引きで指定数ひけるか（999）。また、チェックされてないlotは出現しないか" do
                checked_lot = another_set_5lots[0]
                find("#chkLottery-#{checked_lot.id}").click
                fill_in "anyDrawNumber", with: draw_lots_num
                find(:xpath, "//button[@data-action='click->randomizer#checkedSpecifiedDraw']").click
                within result_table do
                  expect(page).to have_content(checked_lot.name)
                  expect(page).to have_content(draw_lots_num)
                  expect(page).to_not have_content(another_set_5lots[1].name)
                  expect(page).to_not have_content(another_set_5lots[2].name)
                  expect(page).to_not have_content(another_set_5lots[3].name)
                  expect(page).to_not have_content(another_set_5lots[4].name)
                end
              end
              it "チェックありの指定引きで指定されたものが引けるか" do
                find("#chkLottery-#{another_set_5lots[0].id}").click
                find("#chkLottery-#{another_set_5lots[1].id}").click
                find("#chkLottery-#{another_set_5lots[2].id}").click
                within target_lot[0] do
                  all("td[data-controller=flip]")[1].double_click
                end
                find(:xpath, "//button[@data-action='click->randomizer#checkedDrawTarget']").click
                within result_table do
                  expect(page).to have_content(another_set_5lots[0].name)
                  expect(page).to_not have_content(another_set_5lots[3].name)
                  expect(page).to_not have_content(another_set_5lots[4].name)
                end
              end

              it "チェックなしの指定数引きで指定数ひけるか（999）。また、チェックされているlotは出現しないか" do
                checked_lot = another_set_5lots[0]
                find("#chkLottery-#{checked_lot.id}").click
                fill_in "anyDrawNumber", with: draw_lots_num
                find(:xpath, "//button[@data-action='click->randomizer#uncheckedSpecifiedDraw']").click
                within result_table do
                  expect(page).to_not have_content(checked_lot.name)
                  expect(page).to have_content(another_set_5lots[1].name)
                  expect(page).to have_content(another_set_5lots[2].name)
                  expect(page).to have_content(another_set_5lots[3].name)
                  expect(page).to have_content(another_set_5lots[4].name)
                end
              end
              it "チェックなしの指定引きで指定されたものが引けるか" do
                find("#chkLottery-#{another_set_5lots[0].id}").click
                sleep 0.1
                find("#chkLottery-#{another_set_5lots[1].id}").click
                sleep 0.1
                find("#chkLottery-#{another_set_5lots[2].id}").click
                within target_lot[3] do
                  all("td[data-controller=flip]")[1].double_click
                end
                find(:xpath, "//button[@data-action='click->randomizer#uncheckedDrawToTarget']").click
                within result_table do
                  expect(page).to_not have_content(another_set_5lots[0].name)
                  expect(page).to have_content(another_set_5lots[3].name)
                end
              end
            end

            context "チェックの対象が存在しない場合の確認" do
              let(:err_message_checkless) { "チェックされたデータがありません" }
              it "チェックなしの場合、エラーメッセージが出る" do
                find(:xpath, "//button[@data-action='click->randomizer#checkedSpecifiedDraw']").click
                expect(page).to have_content(err_message_checkless)
                within target_lot[0] do
                  all("td[data-controller=flip]")[1].double_click
                end
                find(:xpath, "//button[@data-action='click->randomizer#checkedDrawTarget']").click
                expect(page).to have_content(err_message_checkless)
              end
              let(:err_message_uncheckless) { "チェックされてないデータがありません" }
              it "チェックありの場合、エラーメッセージが出る。" do
                visit random_set_path(set.id)
                find("#chkLottery-#{util_lot.id}").click
                sleep 0.3
                find(:xpath, "//button[@data-action='click->randomizer#uncheckedSpecifiedDraw']").click
                within "div.toast" do
                  expect(page).to have_content(err_message_uncheckless)
                end
                within target_lot[0] do
                  all("td[data-controller=flip]")[1].double_click
                end
                find(:xpath, "//button[@data-action='click->randomizer#uncheckedDrawToTarget']").click
                within "div.toast" do
                  expect(page).to have_content(err_message_uncheckless)
                end
              end
            end
          end
        end
        describe "シード機能の確認" do
          # メルセンヌ数とGIMPSに敬意を表して
          let(:seed) { 1398269 }
          it "未設定時に自動的に入力されるか" do
            find(:xpath, "//button[@data-action='click->randomizer#oneDraw']").click
            value = find("#randomSeed").value
            expect(value).to_not eq("")
          end
          it "シード値を入力したときに勝手に変更されない" do
            fill_in "randomSeed", with: seed
            find(:xpath, "//button[@data-action='click->randomizer#oneDraw']").click
            value = find("#randomSeed").value
            expect(value.to_i).to eq(seed)
          end
        end
      end
    end
    describe "new" do
    end
  end      
end
