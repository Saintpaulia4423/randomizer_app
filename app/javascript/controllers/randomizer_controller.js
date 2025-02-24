import { Controller } from "@hotwired/stimulus"
import { Toast } from "bootstrap";
import { Randomizer } from "randomizer"

// Connects to data-controller="random-sets"
export default class extends Controller {
  static targets = ["specifiedNumber", "seed", "randomizerSwitch", "lotteries", "lottery",
    "randomizerParmerter", "resultTable", "realityPickRate", "pickUpRate", "pickupedLottery",
    "realityTranslation", "lotStyle", "pickupStyle"];
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

    // スタイル情報の提供
    try {
      this.randomizer.setStyles(this.lotStyleTarget.dataset.style, this.pickupStyleTarget.dataset.style);
    } catch (e) {
      this.viewToast("想定されていない設定です。再度編集から実施しなおしてください。");
      throw new Error("セットアップ失敗");
    }

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
    if (this.lotteries == "") {
      throw new Error("チェックされたデータがありません。");
    }
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
    if (this.lotteries == "") {
      throw new Error("チェックされてないデータがありません。");
    }
    this.randomizer.setLotteriesArray(this.lotteries);
  }
  setLottery(lotteryObject) {
    // チェックボックス　ピックアップ 指定引 reality name dict
    let json = {};
    json.id = Number(lotteryObject.children[1].children[0].dataset.pickupId);
    json.reality = Number(lotteryObject.children[3].children[0].dataset.value);
    json.pickup = lotteryObject.children[1].children[0].className.includes("flip-opacity");
    json.target = lotteryObject.children[2].children[0].className.includes("flip-opacity");
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
    this.targetDraw();
    this.randomizer.writeResult();
  }
  checkedSpecifiedDraw() {
    try {
      this.setLotteriesChecked();
      this.setupParameter();
      this.randomizer.setResult(this.randomizer.anyNext(this.specifiedNumberTarget.value));
      this.randomizer.writeResult();
    } catch (e) {
      this.viewToast(e);
    }
  }
  checkedDrawTarget() {
    try {
      this.setLotteriesChecked();
      this.setupParameter();
      this.targetDraw();
      this.randomizer.writeResult();
    } catch (e) {
      this.viewToast(e);

    }
  }
  uncheckedSpecifiedDraw() {
    try {
      this.setLotteriesUnChecked();
      this.setupParameter();
      this.randomizer.setResult(this.randomizer.anyNext(this.specifiedNumberTarget.value));
      this.randomizer.writeResult();
    } catch (e) {
      this.viewToast(e);
    }
  }
  uncheckedDrawToTarget() {
    try {
      this.setLotteriesUnChecked();
      this.setupParameter();
      this.targetDraw();
      this.randomizer.writeResult();
    } catch (e) {
      this.viewToast(e);
    }
  }
  // 指定引き用処理
  targetDraw() {
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
