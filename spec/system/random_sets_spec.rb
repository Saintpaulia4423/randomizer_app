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
                  visit random_set_path(set.id)
                  sleep 1
                  find("#chkLottery-#{util_lot.id}").check
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
            let!(:add_lot_default_pickup) { FactoryBot.create(:lottery, :with_pickup, name: "add_lot_with_pickup", random_set_id: set.id)}
            before do
              visit random_set_path(set.id)
            end
            describe "ピックアップ抽選についての確認" do
              it "ピックアップされたものが特に抽選されるか（失敗する可能性あり）" do
                fill_in "anyDrawNumber", with: draw_lots_num * 10
                # 有意に大きくするためピックアップ比率90:10とする
                fill_in "pick-#{add_lot_default_pickup.reality}", with: 90
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
        end
      end
      describe "showページの表示の確認" do
        let!(:nodata_set) { FactoryBot.create(:random_set, data: [] ) }
        context "情報が存在する場合の確認" do
          before do
            visit random_set_path(another_set.id)
          end
          it "表示内容の確認" do
            expect(page).to have_content(another_set.name)
            expect(page).to have_content(another_set.dict)
            within find("div[data-info-target=realityList]") do
              expect(page).to have_content("★#{another_set.data["rate"][0]["reality"]}")
              expect(find_field("reality-#{another_set.data["rate"][0]["reality"]}").value).to have_content(another_set.data["rate"][0]["value"])
              expect(page).to have_content("★#{another_set.data["rate"][1]["reality"]}")
              expect(find_field("reality-#{another_set.data["rate"][1]["reality"]}").value).to have_content(another_set.data["rate"][1]["value"])
              expect(page).to have_content("★#{another_set.data["rate"][2]["reality"]}")
              expect(find_field("reality-#{another_set.data["rate"][2]["reality"]}").value).to have_content(another_set.data["rate"][2]["value"])
            end
            within find("div[data-info-target=pickupList]") do
              expect(page).to have_content("★#{another_set.data["pickup"]["gainrate"][0]["reality"]}")
              expect(find_field("pick-#{another_set.data["pickup"]["gainrate"][0]["reality"]}").value).to have_content(another_set.data["pickup"]["gainrate"][0]["value"])
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
    end
  end      
end
