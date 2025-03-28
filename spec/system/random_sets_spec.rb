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

    # 各種確認において利用される定数
    # セット内容
    let(:target_lot) { all("tr[data-randomizer-target=lotteries]") }
    # 結果確認
    let(:result_table) { "table[data-randomizer-target=resultTable]" }
    # 大量のドロー
    let(:draw_lots_num) { 999 }

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
          fill_in "q_name_cont", with: "Test_Random"
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
            elements[0].all("th")[3].click
            elements[0].all("th")[3].click
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
              sleep 0.5
              within result_table do
                expect(page).to_not have_content("100")
              end
            end
            it "指定数引きにより規定数引けるか" do
              fill_in "anyDrawNumber", with: draw_lots_num
              # 全てから指定数引く
              find(:xpath, "//button[@data-action='click->randomizer#specifiedDraw']").click
              within result_table do
                value = all("td")[2].text
                expect(value).to have_content(draw_lots_num)
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
                find("#chkLottery-#{checked_lot.id}").check
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
                find("#chkLottery-#{another_set_5lots[0].id}").check
                find("#chkLottery-#{another_set_5lots[1].id}").check
                find("#chkLottery-#{another_set_5lots[2].id}").check
                within target_lot[0] do
                  all("td[data-controller=flip]")[1].double_click
                end
                sleep 0.5
                find(:xpath, "//button[@data-action='click->randomizer#checkedDrawTarget']").click
                sleep 0.5
                within result_table do
                  expect(page).to have_content(another_set_5lots[0].name)
                  expect(page).to_not have_content(another_set_5lots[3].name)
                  expect(page).to_not have_content(another_set_5lots[4].name)
                end
              end

              it "チェックなしの指定数引きで指定数ひけるか（999）。また、チェックされているlotは出現しないか" do
                checked_lot = another_set_5lots[0]
                find("#chkLottery-#{checked_lot.id}").check
                fill_in "anyDrawNumber", with: draw_lots_num
                find(:xpath, "//button[@data-action='click->randomizer#uncheckedSpecifiedDraw']").click
                expect(find("#chkLottery-#{checked_lot.id}")).to be_checked
                within result_table do
                  expect(page).to_not have_content(checked_lot.name)
                  expect(page).to have_content(another_set_5lots[1].name)
                  expect(page).to have_content(another_set_5lots[2].name)
                  expect(page).to have_content(another_set_5lots[3].name)
                  expect(page).to have_content(another_set_5lots[4].name)
                end
              end
              it "チェックなしの指定引きで指定されたものが引けるか" do
                find("#chkLottery-#{another_set_5lots[0].id}").check
                find("#chkLottery-#{another_set_5lots[1].id}").check
                find("#chkLottery-#{another_set_5lots[2].id}").check
                within target_lot[3] do
                  all("td[data-controller=flip]")[1].double_click
                end
                sleep 0.5
                find(:xpath, "//button[@data-action='click->randomizer#uncheckedDrawToTarget']").click
                within result_table do
                  expect(page).to_not have_content(another_set_5lots[0].name)
                  expect(page).to have_content(another_set_5lots[3].name)
                end
              end
            end

            context "チェックの対象が存在しない場合の確認" do
              context "全てチェックなしパターン" do
                let(:err_message_checkless) { "チェックされたデータがありません" }

                it "指定数引きでエラーメッセージが出る" do
                  find(:xpath, "//button[@data-action='click->randomizer#checkedSpecifiedDraw']").click
                  expect(page).to have_content(err_message_checkless)
                end
                it "指定物引きでエラーメッセージが出る" do
                  within target_lot[0] do
                    all("td[data-controller=flip]")[1].double_click
                    expect(page).to_not have_css("span.bi-hand-index-fill.flip-opacity")
                  end
                  find(:xpath, "//button[@data-action='click->randomizer#checkedDrawTarget']").click
                  expect(page).to have_content(err_message_checkless)
                end
              end
              context "全てチェックありパターン" do
                before(:each) do
                  util_lot.update(default_check: true)
                  visit random_set_path(set.id)
                end
                let(:err_message_uncheckless) { "チェックされてないデータがありません" }
                it "指定数引きでエラーメッセージが出る。" do
                  puts find("#chkLottery-#{util_lot.id}").checked?
                  expect(find("#chkLottery-#{util_lot.id}")).to be_checked
                  find(:xpath, "//button[@data-action='click->randomizer#uncheckedSpecifiedDraw']").click
                  expect(page).to have_content(err_message_uncheckless)
                end
                it "指定物引きでエラーメッセージが出る" do
                  puts find("#chkLottery-#{util_lot.id}").checked?
                  expect(find("#chkLottery-#{util_lot.id}")).to be_checked
                  within target_lot[0] do
                    all("td[data-controller=flip]")[1].double_click
                    expect(page).to_not have_css("span.bi-hand-index-fill.flip-opacity")
                  end
                  find(:xpath, "//button[@data-action='click->randomizer#uncheckedDrawToTarget']").click
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
          it "シードを設定したとき、同じようにドローされる" do
            visit random_set_path(another_set.id)
            find("[data-count='100']").click
            result = 0
            within result_table do
              result = all("td")[2].text.to_i
            end
            sleep 1
            find(:xpath, "//button[@data-action='click->randomizer#resetResult']").click
            sleep 1
            within result_table do
              within "tbody.table-group-divider" do
                expect(page).to have_content("")
              end
            end
            find(:xpath, "//button[@data-action='click->randomizer#setSeed']").click
            find("[data-count='100']").click
            within result_table do
              expect(result).to eq all("td")[2].text.to_i
            end
          end
        end
        describe "各種乱数機能の検証" do
          context "メルセンヌツイスタ" do
            before do
              choose("checkMT")
            end
            it "通常通り引けるか" do
              find(:xpath, "//button[@data-action='click->randomizer#oneDraw']").click
              within result_table do
                expect(page).to have_content(util_lot.name)
              end
            end
            it "シードが固定できるか" do
              visit random_set_path(another_set.id)
              choose("checkMT")
              find("[data-count='100']").click
              result = 0
              within result_table do
                result = all("td")[2].text.to_i
              end
              sleep 1
              find(:xpath, "//button[@data-action='click->randomizer#resetResult']").click
              find(:xpath, "//button[@data-action='click->randomizer#setSeed']").click
              find("[data-count='100']").click
              within result_table do
                expect(result).to eq all("td")[2].text.to_i
              end
            end
          end
          context "XorShift " do
            before do
              choose("checkXorShift")
            end
            it "通常通り引けるか" do
              find(:xpath, "//button[@data-action='click->randomizer#oneDraw']").click
              within result_table do
                expect(page).to have_content(util_lot.name)
              end
            end
            it "シードが固定できるか" do
              visit random_set_path(another_set.id)
              choose("checkXorShift")
              find("[data-count='100']").click
              result = 0
              within result_table do
                result = all("td")[2].text.to_i
              end
              sleep 1
              find(:xpath, "//button[@data-action='click->randomizer#resetResult']").click
              find(:xpath, "//button[@data-action='click->randomizer#setSeed']").click
              find("[data-count='100']").click
              within result_table do
                expect(result).to eq all("td")[2].text.to_i
              end
            end
          end
          context "線形合同方式" do
            before do
              choose("checkLCGs")
            end
            it "通常通り引けるか" do
              find(:xpath, "//button[@data-action='click->randomizer#oneDraw']").click
              within result_table do
                expect(page).to have_content(util_lot.name)
              end
            end
            it "シードが固定できるか" do
              visit random_set_path(another_set.id)
              choose("checkLCGs")
              find("[data-count='100']").click
              result = 0
              within result_table do
                result = all("td")[2].text.to_i
              end
              find(:xpath, "//button[@data-action='click->randomizer#resetResult']").click
              find(:xpath, "//button[@data-action='click->randomizer#setSeed']").click
              find("[data-count='100']").click
              within result_table do
                expect(result).to eq all("td")[2].text.to_i
              end
            end
          end
          context "Math.Random（シード固定不可のため、一部テストなし）" do
            before do
              choose("checkMathRandom")
            end
            it "通常通り引けるか" do
              find(:xpath, "//button[@data-action='click->randomizer#oneDraw']").click
              within result_table do
                expect(page).to have_content(util_lot.name)
              end
            end
          end
        end
        describe "レアリティ抽選率について" do
          let!(:add_lot) { FactoryBot.create(:lottery, name: "add_lot_with_set", reality: 1, random_set_id: set.id) }
          let!(:add_lot_no_set) { FactoryBot.create(:lottery, name: "add_lot_no_set", reality: 3, random_set_id: set.id) }
          before do
            visit random_set_path(set.id)
          end
          describe "レアリティ抽選率の確認" do
            context "非常に低い確率で失敗する（確率論的に80%＜5%となる可能性はゼロではない）" do
              it "基本的に高確率のものを引いているか（失敗可能性あり）" do
                fill_in "anyDrawNumber", with: draw_lots_num * 10
                find(:xpath, "//button[@data-action='click->randomizer#specifiedDraw']").click
                high_rate_num = -1
                low_rate_num = -1
                within result_table do
                  results = all("tr")
                  results.each do |element|
                    result_lot = element.all("td")
                    next if result_lot.empty?
                    case result_lot[1].text
                    when util_lot.name
                      high_rate_num = result_lot[2].text.to_i
                    when add_lot.name
                      low_rate_num = result_lot[2].text.to_i
                    end
                  end
                end
                expect(high_rate_num).to_not eq -1
                expect(low_rate_num).to_not eq -1
                expect(high_rate_num).to be > low_rate_num
              end
              it "未設定のものも引けるか（失敗可能性あり）" do
                fill_in "anyDrawNumber", with: draw_lots_num * 10
                find(:xpath, "//button[@data-action='click->randomizer#specifiedDraw']").click
                high_rate_num = -1
                low_rate_num = -1
                within result_table do
                  results = all("tr")
                  results.each do |element|
                    result_lot = element.all("td")
                    next if result_lot.empty?
                    case result_lot[1].text
                    when util_lot.name
                      high_rate_num = result_lot[2].text.to_i
                    when add_lot_no_set.name
                      low_rate_num = result_lot[2].text.to_i
                    end
                  end
                end
                expect(high_rate_num).to_not eq -1
                expect(low_rate_num).to_not eq -1
                expect(high_rate_num).to be > low_rate_num
              end
            end
          end
          describe "一時的なレアリティ追加についての確認" do
            # add_lot_no_setのレアリティのもの
            let(:add_reality) { "★3" }
            before do
              find(:xpath, "//button[@data-action='info#addRealityModal']").click
              sleep 1
              within ".modal" do
                select add_reality
                # 大きな値を入れる
                fill_in "addReality", with: 10000
                click_button "追加"
              end
            end
            it "新規のレアリティの追加ができるか" do
              within find("div[data-info-target=realityList]") do
                expect(page).to have_content(add_reality)
              end
            end
            it "追加したレアリティにより確率が大きく変わるか（失敗する可能性あり）" do
              fill_in "anyDrawNumber", with: draw_lots_num * 10
              find(:xpath, "//button[@data-action='click->randomizer#specifiedDraw']").click
              within result_table do
                results = all("tr")
                results.each do |element|
                  result_lot = element.all("td")
                  next if result_lot.empty?
                  case result_lot[1].text
                  when add_lot_no_set.name
                    high_rate_num = result_lot[2].text.to_i
                  when util_lot.name
                    low_rate_num = result_lot[2].text.to_i
                  end
                end
              end
            end
          end
          describe "ピックアップ抽選率の確認" do
            let!(:add_lot_default_pickup) { FactoryBot.create(:lottery, :with_pickup, name: "add_lot_with_pickup", random_set_id: set.id) }
            before do
              visit random_set_path(set.id)
            end
            describe "ピックアップ抽選についての確認" do
              it "ピックアップされたものが特に抽選されるか（失敗する可能性あり）" do
                fill_in "anyDrawNumber", with: draw_lots_num * 10
                # 有意に大きくするためピックアップ比率90:10とする
                fill_in "pickup-#{add_lot_default_pickup.reality}", with: 90
                find(:xpath, "//button[@data-action='click->randomizer#specifiedDraw']").click
                within result_table do
                  results = all("tr")
                  results.each do |element|
                    result_lot = element.all("td")
                    next if result_lot.empty?
                    case result_lot[1].text
                    when add_lot_default_pickup.name
                      high_rate_num = result_lot[2].text.to_i
                    when util_lot.name
                      low_rate_num = result_lot[2].text.to_i
                    end
                  end
                end
              end
              context "一時追加についての確認" do
                let!(:add_lot_for_add_pickup) { FactoryBot.create(:lottery, :with_pickup, name: "add_lot_reality_1_with_pickup", reality: 1, random_set_id: set.id) }
                let!(:add_lot_for_add_nopickup) { FactoryBot.create(:lottery, name: "add_lot_reality_1_with_pickup", reality: 1, random_set_id: set.id) }
                let(:add_reality) { "★1" }
                before do
                  visit random_set_path(set.id)
                  # ピックアップの確認のため、レアリティを増加
                  fill_in "reality-#{add_lot_for_add_pickup.reality}", with: 10000
                  find(:xpath, "//button[@data-action='info#addPickupModal']").click
                  # modal fadeの待機時間
                  sleep 1
                  within ".modal" do
                    select add_reality
                    # 大きな値を入れる
                    fill_in "addReality", with: 90
                    find(:xpath, "//button[@data-action='click->info#add']").click
                  end
                end
                it "ピックアップを追加できるか" do
                  within find("div[data-info-target=pickupList]") do
                    expect(page).to have_content(add_reality)
                  end
                end
                it "追加したピックアップにより正常に動作するか" do
                  expect(page).to have_css("div.modal", visible: false)
                  fill_in "anyDrawNumber", with: draw_lots_num * 10
                  find(:xpath, "//button[@data-action='click->randomizer#specifiedDraw']").click
                  within result_table do
                    results = all("tr")
                    results.each do |element|
                      result_lot = element.all("td")
                      next if result_lot.empty?
                      case result_lot[1].text
                      when add_lot_for_add_pickup.name
                        high_rate_num = result_lot[2].text.to_i
                      when add_lot_for_add_nopickup.name
                        low_rate_num = result_lot[2].text.to_i
                      end
                    end
                  end
                end
              end
            end
          end
          describe "追加以外の機能のついて" do
            context "レアリティ抽選率" do
              it "数値変更後、リセットできるか" do
                original_value = set.rate[0]["value"].to_i
                reality = set.rate[0]["reality"].to_i
                within find("#pickList") do
                  fill_in "reality-0", with: original_value + 1
                  expect(find("input[name=reality-0]").value.to_i).to eq original_value + 1
                  find("button[data-action='info#reset']").click
                  expect(find("input[name=reality-0]").value.to_i).to eq original_value
                end
              end
            end
            context "ピックアップ確率" do
              it "数値変更後、リセットできるか" do
                original_value = set.pickup_rate[0]["value"].to_i
                reality = set.pickup_rate[0]["reality"].to_i
                within find("#pickupList") do
                  fill_in "pickup-0", with: original_value + 1
                  expect(find("input[name=pickup-0]").value.to_i).to eq original_value + 1
                  find("button[data-action='info#reset']").click
                  expect(find("input[name=pickup-0]").value.to_i).to eq original_value
                end
              end
            end
            context "レアリティ別個数" do
              let!(:add_box_set) { FactoryBot.create(:random_set, :box) }
              let!(:add_box_lot) { FactoryBot.create(:lottery, :value_10, random_set_id: add_box_set.id) }
              before do
                visit random_set_path(add_box_set.id)
              end
              it "数値変更後、リセットできるか" do
                original_value = add_box_set.value_list[0]["value"].to_i
                reality = add_box_set.value_list[0]["reality"].to_i
                within find("#valueList") do
                  fill_in "value-0", with: original_value + 1
                  expect(find("input[name=value-0]").value.to_i).to eq original_value + 1
                  find("button[data-action='info#reset']").click
                  expect(find("input[name=value-0]").value.to_i).to eq original_value
                end
              end
              it "一時的な固定ができているか" do
                original_value = add_box_set.value_list[0]["value"].to_i
                reality = add_box_set.value_list[0]["reality"].to_i
                within find("#valueList") do
                  fill_in "value-0", with: original_value + 1
                  find("button[data-action='info#fix']").click
                  expect(find("input[name=value-0]").value.to_i).to eq original_value + 1
                  find("button[data-action='info#reset']").click
                  expect(find("input[name=value-0]").value.to_i).to eq original_value + 1
                end
              end
            end
          end
        end
        describe "boxの確認" do
          context "boxが無限状態" do
            let!(:inf_set) { FactoryBot.create(:random_set, :infinityValue, :infinityBox) }
            let!(:inf_lot) { FactoryBot.create(:lottery, random_set_id: inf_set.id) }
            before do
              visit random_set_path(inf_set.id)
            end
            it "大量に引き続けることができるか" do
              fill_in "anyDrawNumber", with: draw_lots_num
              find(:xpath, "//button[@data-action='click->randomizer#specifiedDraw']").click
              within result_table do
                expect(page).to have_content(draw_lots_num)
              end
            end
            it "lot valueに個数を付与した時にその数までしか引けないこと" do
              count = 9
              find(:xpath, "//span[@data-action='dblclick->number-change#change']").double_click
              within ".modal" do
                expect(page).to have_content("個数の変更")
                fill_in "lotDefault", with: count
                fill_in "lotValue", with: count
                # 反応しないことがあるので、予備として2回押させる。
                click_button "更新"
                begin
                  click_button "更新"
                  click_button "更新"
                rescue
                end
              end
              expect(page).to_not have_content("個数の変更")
              expect(page).to have_css("[data-value='#{count}']")
              expect(page).to have_css("[data-default-value='#{count}']")
              expect(page).to have_content(count)
              find(:xpath, "//button[@data-count='10']").click
              within result_table do
                expect(page).to have_content(inf_lot.name)
                expect(page).to have_content(count)
              end
            end
            it "reality frameの個数を超過しないこと" do
              count = 9
              fill_in "value-0", with: count
              find(:xpath, "//button[@data-count='10']").click
              # javascriptの処理待機時間
              sleep 1
              within result_table do
                expect(page).to have_content(inf_lot.name)
                expect(page).to have_content(count)
              end
            end
            describe "ボックスリセット時の処理について" do
              before do
                inf_set.update(default_value: 50)
                visit random_set_path(inf_set.id)
              end
              context "リセットしない場合" do
                it "レアリティ別個数がリセットされないこと" do
                  count = 9
                  find("input[name=valueFrameResetPattern]").click
                  expect(find("input[name=valueFrameResetPattern]")).to_not be_checked
                  fill_in "value-0", with: count
                  find(:xpath, "//button[@data-count='100']").click
                  within result_table do
                    expect(page).to have_content(inf_lot.name)
                    expect(page).to have_css("[data-value='#{count}']")
                  end
                end
                it "lotがリセットされないこと" do
                  count = 9
                  find("input[name=valueFrameResetPattern]").click
                  expect(find("input[name=valueFrameResetPattern]")).to_not be_checked
                  find(:xpath, "//span[@data-action='dblclick->number-change#change']").double_click
                  within ".modal" do
                    expect(page).to have_content("個数の変更")
                    fill_in "lotDefault", with: count
                    fill_in "lotValue", with: count
                    # 反応しないことがあるので、予備として2回押させる。
                    click_button "更新"
                    begin
                      click_button "更新"
                      click_button "更新"
                    rescue
                    end
                  end
                  expect(page).to_not have_content("個数の変更")
                  expect(page).to have_css("[data-value='#{count}']")
                  expect(page).to have_css("[data-default-value='#{count}']")
                  expect(page).to have_content(count)
                  find(:xpath, "//button[@data-count='10']").click
                  within result_table do
                    expect(page).to have_content(inf_lot.name)
                    expect(page).to have_content(count)
                  end
                end
                context "リセットする場合" do
                  it "レアリティ別個数がリセットされて100ヒットになること" do
                    count = 10
                    find("input[name=valueFrameResetPattern]").click
                    expect(find("input[name=valueFrameResetPattern]")).to_not be_checked
                    fill_in "value-0", with: count
                    find(:xpath, "//button[@data-count='100']").click
                    expect(find("input[data-randomizer-target='resetCount']").value).to_not eq(0)
                    within result_table do
                      expect(page).to have_content(inf_lot.name)
                      # ボックスは0になるとストップがかかるので、100回引いても10回で打ち止め
                      expect(page).to have_css("[data-value='#{count}']")
                    end
                  end
                end
              end
            end
            describe "boxについての確認" do
              let(:count) { 10 }
              context "一時的な変更の場合" do
                it "一時的な変更を固定できるか" do
                  fill_in "boxValue", with: count
                  find(:xpath, "//button[@data-action='info#fixBox']").click
                  expect(page).to have_css("[data-default-value='#{count}']")
                  expect(page).to have_css("[value='#{count}']")
                  find(:xpath, "//button[@data-action='info#resetBox']").click
                  expect(find("input[data-randomizer-target=setValue]").value.to_i).to eq count
                end
                it "boxの数が有限の場合、その数まで引けるか" do
                  fill_in "boxValue", with: count
                  find(:xpath, "//button[@data-action='info#fixBox']").click
                  expect(page).to have_css("[data-default-value='#{count}']")
                  expect(page).to have_css("[value='#{count}']")
                  find(:xpath, "//button[@data-count='100']").click
                  # ボックスが零になるとリセットがかかるので、残数0のリセット10になる。
                  expect(find("input[data-randomizer-target='setValue']").value.to_i).to_not eq(0)
                  within result_table do
                    expect(page).to have_content(100)
                  end
                end
              end
              context "恒久的な変更" do
                before do
                  inf_set.update(default_value: count)
                end
                it "boxの数が有限の場合、その数まで引けるか" do
                  find(:xpath, "//button[@data-count='100']").click
                  # ボックスが零になるとリセットがかかるので、残数0のリセット10になる。
                  expect(find("input[data-randomizer-target='setValue']").value.to_i).to_not eq(0)
                  within result_table do
                    expect(page).to have_content(100)
                  end
                end
              end
            end
          end
        end
        describe "lotteriesについてのvalueの確認" do
          let!(:inf_set) { FactoryBot.create(:random_set, :infinityValue, :infinityBox) }
          let!(:inf_lot) { FactoryBot.create(:lottery,  random_set_id: inf_set.id) }
          before do
            visit random_set_path(inf_set.id)
          end
          it "lotの数値変更後にリセットできるか" do
            inf_lot.update(value: 100)
            visit random_set_path(inf_set.id)
            expect(page).to have_css("[data-value='#{inf_lot.value}']")
            count = 10
            find(:xpath, "//span[@data-action='dblclick->number-change#change']").double_click
            within ".modal" do
              expect(page).to have_content("個数の変更")
              fill_in "lotValue", with: count
              # 反応しないことがあるので、予備として2回押させる。
              click_button "更新"
              begin
                click_button "更新"
                click_button "更新"
              rescue
              end
            end
            expect(page).to_not have_content("個数の変更")
            expect(page).to have_css("[data-value='#{count}']")
            find(:xpath, "//button[@data-action='click->number-change#reset']").click
            expect(page).to have_css("[data-value='#{inf_lot.value}']")
          end
        end
      end
      describe "showページの表示の確認" do
        let!(:nodata_set) { FactoryBot.create(:random_set, rate: [], pickup_rate: []) }
        context "情報が存在する場合の確認" do
          before do
            visit random_set_path(another_set.id)
          end
          it "表示内容の確認" do
            expect(page).to have_content(another_set.name)
            expect(page).to have_content(another_set.dict)
            within find("div[data-info-target=realityList]") do
              expect(page).to have_content("★#{another_set.rate[0]["reality"]}")
              expect(find_field("reality-#{another_set.rate[0]["reality"]}").value).to have_content(another_set.rate[0]["value"])
              expect(page).to have_content("★#{another_set.rate[1]["reality"]}")
              expect(find_field("reality-#{another_set.rate[1]["reality"]}").value).to have_content(another_set.rate[1]["value"])
              expect(page).to have_content("★#{another_set.rate[2]["reality"]}")
              expect(find_field("reality-#{another_set.rate[2]["reality"]}").value).to have_content(another_set.rate[2]["value"])
            end
            within find("div[data-info-target=pickupList]") do
              expect(page).to have_content("★#{another_set.pickup_rate[0]["reality"]}")
              expect(find_field("pickup-#{another_set.pickup_rate[0]["reality"]}").value).to have_content(another_set.pickup_rate[0]["value"])
            end
          end
        end
        context "情報が存在しない場合の確認" do
          before do
            visit random_set_path(nodata_set.id)
          end
          it "表示内容の確認" do
            nodata_message_in_info = "設定がありません。編集にて設定を追加してください。"
            nodata_message_in_lotteries = "登録がありません"
            expect(page).to have_content(nodata_set.name)
            expect(page).to have_content(nodata_message_in_info)
            expect(page).to have_content(nodata_message_in_lotteries)
          end
        end
      end
    end
    describe "new" do
      describe "newページの確認" do
        before do
          visit new_random_set_path
        end
        it "作成ができるか" do
          name = "test_head"
          dict = "test_body"
          password = "test_leg"
          fill_in "random_set_name", with: name
          fill_in "random_set_dict", with: dict
          fill_in "random_set_password", with: password
          click_button "作成"
          expect(page).to have_selector('input[value=' + name + ']')
          expect(page).to have_content(dict)
        end
        it "作成後、編集ページに遷移するか" do
          name = "test_head"
          dict = "test_body"
          password = "test_leg"
          fill_in "random_set_name", with: name
          fill_in "random_set_dict", with: dict
          fill_in "random_set_password", with: password
          click_button "作成"
          expect(current_path).to eq edit_random_set_path(RandomSet.last.id)
        end
      end
    end
    describe "edit" do
      describe "遷移の確認" do
        it "edit pageに到達できるか" do
          visit login_path(set.id)
          fill_in "session_password", with: set.password
          click_button "検証"
          expect(current_path).to eq edit_random_set_path(set.id)
        end
        it "パスワードが誤りの場合、遷移しないか" do
          visit random_set_path(set.id)
          click_link "編集"
          expect(page).to have_content("編集パスワード入力")
          # パスワードを入力していない場合
          click_button "検証"
          expect(current_path).to_not eq edit_random_set_path(set.id)
          # パスワードが異なる場合
          fill_in "session_password", with: "invalid_password"
          click_button "検証"
          expect(page).to have_content("パスワードが異なります")
          expect(current_path).to_not eq edit_random_set_path(set.id)
        end
      end
      describe "random_setの更新の確認" do
        before do
          visit login_path(set.id)
          sleep 1
          fill_in "session_password", with: set.password
          click_button "検証"
        end
        it "更新を行えるか" do
          name = "change_name"
          dict = "change_dict"
          fill_in "random_set_name", with: name
          fill_in "random_set_dict", with: dict
          within "#random_set_edit_forms" do
            click_button "更新"
          end
          click_link "ランダマイザーへ"
          expect(page).to have_content(name)
          expect(page).to have_content(dict)
        end
        it "更新をリセットできるか" do
          name = "unset_name"
          dict = "unset_dict"
          name_target = "input#random_set_name"
          dict_target = "textarea#random_set_dict"
          fill_in "random_set_name", with: name
          fill_in "random_set_dict", with: dict
          expect(find(name_target).value).to eq name
          expect(find(dict_target).value).to eq dict
          within "#random_set_edit_forms" do
            click_link "リセット"
          end
          expect(find(name_target).value).to_not eq name
          expect(find(dict_target).value).to_not eq dict
        end
        describe "information項目の確認" do
          let(:info_turbo) { "turbo-frame#random_set_information" }
          let(:new_reality) { "★10" }
          let(:new_reality_raw) { "10" }
          let(:test_value) { 42 }
          context "レアリティ抽選率" do
            let(:filter_list) { "turbo-frame#pickList" }
            it "項目を追加ができるか" do
              find(info_turbo).find(filter_list).find(".card-header").find(".btn.btn-primary").click
              expect(page).to have_content("新規")
              within ".modal" do
                select new_reality
                fill_in "random_set[value]", with: test_value
                begin
                  find("input[name='commit']").click
                  find("input[name='commit']").click
                  find("input[name='commit']").click
                rescue
                end
                sleep 1
              end
              expect(page).to_not have_content("新規")
              within filter_list do
                expect(page).to have_content(new_reality)
                expect(find(:xpath, "//input[@data-reality='#{new_reality_raw}']").value.to_i).to eq test_value
              end
            end
            it "項目の変更ができるか" do
              find(filter_list).find(".card-body").all(".input-group")[0].find(".btn.btn-primary.bi").click
              expect(page).to have_content("レアリティ情報の変更")
              within ".modal" do
                fill_in "random_set[value]", with: test_value
                begin
                  find("input[name='commit']").click
                  find("input[name='commit']").click
                  find("input[name='commit']").click
                rescue
                end
                sleep 1
              end
              expect(page).to_not have_content("レアリティ情報の変更")
              within filter_list do
                expect(find(".card-body").all(".input-group")[0].find("input[name=reality-#{set.rate[0]["reality"]}]").value.to_i).to eq test_value
              end
            end
            it "項目の削除ができるか" do
              delete_target = "★0"
              find(filter_list).find(".card-body").all(".input-group")[0].find(".btn.btn-danger.bi").click
              page.accept_alert
              within filter_list do
                expect(page).to_not have_content(delete_target)
              end
            end
          end
          context "ピックアップ確率" do
            let(:filter_list) { "turbo-frame#pickupList" }
            it "項目を追加ができるか" do
              find(info_turbo).find(filter_list).find(".card-header").find(".btn.btn-primary").click
              expect(page).to have_content("新規")
              within ".modal" do
                select new_reality
                fill_in "random_set[value]", with: test_value
                begin
                  find("input[name='commit']").click
                  find("input[name='commit']").click
                  find("input[name='commit']").click
                rescue
                end
                sleep 1
              end
              expect(page).to_not have_content("新規")
              within filter_list do
                expect(page).to have_content(new_reality)
                expect(find(:xpath, "//input[@data-reality='#{new_reality_raw}']").value.to_i).to eq test_value
              end
            end
            it "項目の変更ができるか" do
              find(filter_list).find(".card-body").all(".input-group")[0].find(".btn.btn-primary.bi").click
              expect(page).to have_content("レアリティ情報の変更")
              within ".modal" do
                fill_in "random_set[value]", with: test_value
                begin
                  find("input[name='commit']").click
                  find("input[name='commit']").click
                  find("input[name='commit']").click
                rescue
                end
                sleep 1
              end
              expect(page).to_not have_content("レアリティ情報の変更")
              within filter_list do
                expect(find(".card-body").all(".input-group")[0].find("input[name=pickup-#{set.pickup_rate[0]["reality"]}]").value.to_i).to eq test_value
              end
            end
            it "項目の削除ができるか" do
              delete_target = "★0"
              find(filter_list).find(".card-body").all(".input-group")[0].find(".btn.btn-danger.bi").click
              page.accept_alert
              within filter_list do
                expect(page).to_not have_content(delete_target)
              end
            end
          end
          context "レアリティ別個数" do
            before do
              set.update(FactoryBot.attributes_for(:random_set, :box))
              visit edit_random_set_path(set.id)
            end
            let(:filter_list) { "turbo-frame#valueList" }
            it "項目を追加ができるか" do
              find(info_turbo).find(filter_list).find(".card-header").find(".btn.btn-primary").click
              expect(page).to have_content("新規")
              within ".modal" do
                select new_reality
                fill_in "random_set[value]", with: test_value
                begin
                  find("input[name='commit']").click
                  find("input[name='commit']").click
                  find("input[name='commit']").click
                rescue
                end
                sleep 1
              end
              expect(page).to_not have_content("新規")
              within filter_list do
                expect(page).to have_content(new_reality)
                expect(find(:xpath, "//input[@data-reality='#{new_reality_raw}']").value.to_i).to eq test_value
              end
            end
            it "項目の変更ができるか" do
              find(filter_list).find(".card-body").all(".input-group")[0].find(".btn.btn-primary.bi").click
              expect(page).to have_content("レアリティ情報の変更")
              within ".modal" do
                fill_in "random_set[value]", with: test_value
                begin
                  find("input[name='commit']").click
                  find("input[name='commit']").click
                  find("input[name='commit']").click
                rescue
                end
                sleep 1
              end
              expect(page).to_not have_content("レアリティ情報の変更")
              within filter_list do
                expect(find(".card-body").all(".input-group")[0].find("input[name=value-#{set.value_list[0]["reality"]}]").value.to_i).to eq test_value
              end
            end
            it "項目の削除ができるか" do
              delete_target = "★0"
              find(filter_list).find(".card-body").all(".input-group")[0].find(".btn.btn-danger.bi").click
              page.accept_alert
              within filter_list do
                expect(page).to_not have_content(delete_target)
              end
            end
          end
          context "ボックス全体数" do
            before do
              set.update(FactoryBot.attributes_for(:random_set, :box))
              visit edit_random_set_path(set.id)
            end
            it "数値を変更する" do
              count = 100
              fill_in "random_set[default_value]", with: count
              within info_turbo do
                click_button "変更"
                expect(find("#random_set_default_value").value.to_i).to eq count
              end
            end
          end
        end
      end
      describe "lotteryの確認" do
        let!(:simple_lot) { FactoryBot.create(:lottery, random_set_id: set.id) }
        let(:c_name) { "Changed_name" }
        let(:c_dict) { "Changed_dict" }
        let(:c_reality) { "★5" }
        let(:c_value) { 65536 }
        before do
          visit login_path(set.id)
          sleep 1
          fill_in "session_password", with: set.password
          click_button "検証"
        end
        it "更新ができるか" do
          within "turbo-frame[id=lottery_#{simple_lot.id}]" do
            find("#lottery_edit_#{simple_lot.id}").click
          end
          within ".modal" do
            expect(page).to have_content("#{simple_lot.name}の編集")
            fill_in "lottery_name", with: c_name
            fill_in "lottery_dict", with: c_dict
            fill_in "lottery_value", with: c_value
            select c_reality
            find("#lottery_default_check").check
            find("#lottery_default_pickup").check
            expect(page).to_not have_css("flip-opacity")
            click_button "更新"
          end
          expect(page).to have_content("#{Lottery.find(simple_lot.id).name}は更新されました")
          within "turbo-frame[id=lottery_#{simple_lot.id}]" do
            expect(page).to have_content(c_name)
            expect(page).to have_content(c_dict)
            expect(page).to have_content(c_value)
            expect(page).to have_content(c_reality)
            expect(page).to_not have_css("color-blue")
            expect(page).to_not have_css("flip-opacity")
          end
        end
        it "削除できるか" do
          expect(page).to have_content(simple_lot.name)
          find("#lottery_delete_#{simple_lot.id}").click
          page.accept_alert
          expect(page).to have_content("削除しました")
          expect(page).to_not have_content(simple_lot.name)
        end
        it "追加できるか" do
          expect(page).to_not have_content(c_name)
          find(".bi.bi-plus-circle").click
          within ".modal" do
            fill_in "lottery_name", with: c_name
            fill_in "lottery_dict", with: c_dict
            fill_in "lottery_value", with: c_value
            select c_reality
            find("#lottery_default_check").check
            find("#lottery_default_pickup").check
            expect(page).to_not have_css("flip-opacity")
            click_button "作成"
          end
          expect(page).to have_content("作成しました")
          within "turbo-frame[id=lottery_#{Lottery.last.id}]" do
            expect(page).to have_content(c_name)
            expect(page).to have_content(c_dict)
            expect(page).to have_content(c_value)
            expect(page).to have_content(c_reality)
            expect(page).to_not have_css("color-blue")
            expect(page).to_not have_css("flip-opacity")
          end
        end
      end
    end
  end
end
