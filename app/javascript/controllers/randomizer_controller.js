import { Controller } from "@hotwired/stimulus"
import { Toast } from "bootstrap";
import { Randomizer } from "randomizer"

// Connects to data-controller="random-sets"
export default class extends Controller {
  static targets = ["specifiedNumber", "seed", "randomizerSwitch", "lotteries", "lottery", "randomizerParmerter", "resultTable", "realityPickRate", "pickUpRate", "pickupedLottery", "realityTranslation"];
  TARGET_DRAW_DEAD_POINT = 10000000;
  connect() {
    this.randomizer = new Randomizer();
    this.targetNum = this.specifiedNumberTarget;
    this.seedCache;
    this.lotteries = [];
    this.toast = new Toast(document.getElementById("toast"));
  }

  // randomizer実行前初期化処理
  setupParameter() {
    // シード値
    if (Number(this.seedTarget.value) == "") {
      this.seedTarget.value = this.randomizer.getSeed();
      this.randomizer.setSeed(Number(this.seedTarget.value));
      this.seedCache = this.seedTarget.value;
    } else if (this.seedTarget.value != this.seedCache) {
      this.randomizer.setSeed(Number(this.seedTarget.value));
      this.seedCache = this.seedTarget.value;
    }

    // 乱数精製方式
    let selectPattern;
    let radios = this.randomizerSwitchTargets;
    radios.forEach(radio => {
      if (radio.checked) {
        selectPattern = radio.value;
      }
    });
    this.randomizer.setMode(selectPattern);

    // resultターゲット情報の提供
    this.randomizer.setResultTable(this.resultTableTarget);

    // レアリティ情報の提供
    this.randomizer.setPickRate(this.realityPickRateTargets);
    this.randomizer.setRealityTranslation(this.realityTranslationTargets);
    this.randomizer.chkPickRate();

    // ピックアップ情報の提供
    this.randomizer.setPickupList(this.pickUpRateTargets);
    this.randomizer.chkPickupList();

    return selectPattern;
  }

  // get・setter処理群
  setSeed() {
    this.randomizer.setSeed(Number(this.seedTarget.value));
  }
  // lotteries情報セット処理群
  setLotteriesAll() {
    let array = this.lotteriesTargets;
    this.resetLottery();
    array.forEach(lottery => {
      this.setLottery(lottery);
    });
    this.randomizer.setLotteriesArray(this.lotteries);
  }
  setLotteriesChecked() {
    let array = this.lotteriesTargets;
    this.resetLottery();
    array.forEach(lottery => {
      if (lottery.children[0].children[0].checked) {
        this.setLottery(lottery);
      }
    });
    this.randomizer.setLotteriesArray(this.lotteries);
  }
  setLotteriesUnChecked() {
    let array = this.lotteriesTargets;
    this.resetLottery();
    array.forEach(lottery => {
      if (!lottery.children[0].children[0].checked) {
        this.setLottery(lottery);
      }
    });
    this.randomizer.setLotteriesArray(this.lotteries);
  }
  setLottery(lotteryObject) {
    // チェックボックス　ピックアップ 指定引 reality name dict
    let json = {};
    json.id = Number(lotteryObject.children[1].children[0].dataset.pickupId);
    json.reality = Number(lotteryObject.children[3].children[0].dataset.value);
    json.pickup = lotteryObject.children[1].children[0].className.includes("bi-stars");
    json.target = lotteryObject.children[2].children[0].className.includes("bi-hand-index-fill");
    json.name = lotteryObject.children[4].innerText;
    json.dict = lotteryObject.children[5].innerText;
    this.lotteries.push(json);
  }
  resetLottery() {
    this.lotteries = [];
  }

  // ドロー処理群
  oneDraw() {
    this.setLotteriesAll();
    this.setupParameter();
    this.randomizer.setResult(this.randomizer.next());
    this.randomizer.writeResult();
  }
  anyDraw(event) {
    this.setLotteriesAll();
    this.setupParameter();
    this.randomizer.setResult(this.randomizer.anyNext(event.currentTarget.dataset.count));
    this.randomizer.writeResult();
  }
  specifiedDraw() {
    this.setLotteriesAll();
    this.setupParameter();
    this.randomizer.setResult(this.randomizer.anyNext(this.specifiedNumberTarget.value));
    this.randomizer.writeResult();
  }
  drawToTarget() {
    this.setLotteriesAll();
    this.setupParameter();
    const targetLotteriesList = this.lotteries.filter(element => element.target)
    if (targetLotteriesList == "") {
      this.viewToast("指定引き対象が存在しません。選択してから実行してください。", "指定引きエラー");
      return -1;
    }
    let loop = 0;
    for (let i = 1; loop == 0; i++) {
      if (i >= this.TARGET_DRAW_DEAD_POINT) {
        this.viewToast("指定引きを実行しましたが、" + this.TARGET_DRAW_DEAD_POINT.toLocaleString() + "回までに発見されませんでした。", "指定引きエラー");
        loop = -1;
      }
      let lotNumber = this.randomizer.next();
      let lot = this.randomizer.getLottery(lotNumber);
      this.randomizer.setResult(lotNumber);
      if (targetLotteriesList.some(element => element.name == lot.name)) {
        this.viewToast("指定引きが完了しました。試行回数：" + i.toLocaleString(), "指定引き成功");
        loop = 1;
      }
    }
    this.randomizer.writeResult();
  }
  checkedSpecifiedDraw() {
    this.setLotteriesChecked();
    this.setupParameter();
    this.randomizer.setRange(0, 100)
    for (let i = 0; i <= 10; i++)
      console.log(this.randomizer.next());
  }
  checkedDrawTarget() {
    this.setLotteriesChecked();
    this.setupParameter();
  }
  uncheckedSpecifiedDraw() {
    this.setLotteriesUnChecked();
    this.setupParameter();
  }
  uncheckedDrawToTarget() {
    this.setLotteriesUnChecked();
    this.setupParameter();
    console.log("test");

    this.randomizer.setResult('<p value={name: "test"}>test</p>');
    this.randomizer.refresh();
  }

  // 指定引・ピックアップ処理群
  chooseTarget() {
    console.log("テスト");
  }
  resetTarget() {
    this.randomizer.setRange(50, 100);
    console.log(this.randomizer.next())
  }

  // 結果表示部処理群
  resetResult() {
    this.randomizer.resetResult();
  }
  viewToast(message, title = "info") {
    const header = document.getElementById("toastHeader");
    const body = document.getElementById("toastBody");

    header.innerText = title;
    body.innerText = message;
    this.toast.show();
  }
}
