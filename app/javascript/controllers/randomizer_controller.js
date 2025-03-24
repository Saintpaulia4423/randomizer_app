import { Controller } from "@hotwired/stimulus"
import { Toast } from "bootstrap";
import { Randomizer } from "randomizer"

// Connects to data-controller="random-sets"
export default class extends Controller {
  static targets = ["specifiedNumber", "seed", "randomizerSwitch", "lotteries", "lottery",
    "randomizerParmerter", "resultTable", "realityFrame", "pickupFrame", "valueFrame", "pickupedLottery",
    "realityTranslation", "lotStyle", "pickupStyle", "lotteriesValue", "setValue", "resetCount",
    "valueFrameResetPattern", "lotteryValueResetPattern"];
  TARGET_DRAW_DEAD_POINT = 10000000;
  connect() {
    this.randomizer = new Randomizer();
    this.targetNum;
    this.seedCache;
    this.lotteries = [];
    this.toast = new Toast(document.getElementById("toast"));
    console.log("connect")
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
    // 指定数
    this.targetNum = this.specifiedNumberTarget;

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
    this.randomizer.setPickRate(this.realityFrameTargets);
    this.randomizer.setRealityTranslation(this.realityTranslationTargets);

    // ピックアップ情報の提供
    this.randomizer.setPickupList(this.pickupFrameTargets);


    // スタイル情報の提供
    try {
      this.randomizer.setStyles(this.lotStyleTarget.dataset.style, this.pickupStyleTarget.dataset.style);
    } catch (e) {
      this.viewToast("想定されていない設定です。再度編集から実施しなおしてください。");
      throw new Error("セットアップ失敗");
    }
    // 個数情報の提供
    if (this.lotStyleTarget.dataset.style == "box") {
      this.randomizer.setValueList(this.valueFrameTargets, this.lotteriesValueTargets, this.setValueTarget, this.resetCountTarget);
      this.randomizer.setResetPattern(this.valueFrameResetPatternTarget, this.lotteryValueResetPatternTarget)
    }

    // 各種情報の確認
    if (this.lotStyleTarget.dataset.style == "box") {
      try {
        this.randomizer.chkValueList();
        this.randomizer.chkPickRate();
      } catch (e) {
        throw e
      }
    } else {
      this.randomizer.chkPickRate();
    }
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
    console.log(this.lotteriesTargets)
    this.resetLottery();
    array.forEach(lottery => {
      if (lottery.querySelector("[type=checkbox]").checked) {
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
      if (!lottery.querySelector("[type=checkbox]").checked) {
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
    json.pickup = !lotteryObject.children[1].children[0].className.includes("flip-opacity");
    json.target = !lotteryObject.children[2].children[0].className.includes("flip-opacity");
    json.value = Number(lotteryObject.querySelector("[data-randomizer-target=lotteriesValue").dataset.value)
    json.defaultValue = Number(lotteryObject.querySelector("[data-randomizer-target=lotteriesValue").dataset.defaultValue)
    json.name = lotteryObject.children[4].innerText;
    json.dict = lotteryObject.children[6].innerText;
    this.lotteries.push(json);
  }
  resetLottery() {
    this.lotteries = [];
  }

  // ドロー処理群
  oneDraw() {
    try {
      this.setLotteriesAll();
      this.setupParameter();
      this.randomizer.setResult(this.randomizer.next());
    } catch (e) {
      this.viewToast(e);
    }
    this.randomizer.writeResult();
  }
  anyDraw(event) {
    try {
      this.setLotteriesAll();
      this.setupParameter();
      this.randomizer.setResult(this.randomizer.anyNext(event.currentTarget.dataset.count));
    } catch (e) {
      this.viewToast(e);
    }
    this.randomizer.writeResult();
  }
  specifiedDraw() {
    try {
      this.setLotteriesAll();
      this.setupParameter();
      this.randomizer.setResult(this.randomizer.anyNext(this.specifiedNumberTarget.value));
    } catch (e) {
      this.viewToast(e);
    }
    this.randomizer.writeResult();
  }
  drawToTarget() {
    try {
      this.setLotteriesAll();
      this.setupParameter();
      this.targetDraw();
    } catch (e) {
      this.viewToast(e);
    }
    this.randomizer.writeResult();
  }
  checkedSpecifiedDraw() {
    try {
      console.log("test")
      this.setLotteriesChecked();
      this.setupParameter();
      this.randomizer.setResult(this.randomizer.anyNext(this.specifiedNumberTarget.value));
    } catch (e) {
      this.viewToast(e);
    }
    this.randomizer.writeResult();
  }
  checkedDrawTarget() {
    try {
      this.setLotteriesChecked();
      this.setupParameter();
      this.targetDraw();
    } catch (e) {
      this.viewToast(e);
    }
    this.randomizer.writeResult();
  }
  uncheckedSpecifiedDraw() {
    try {
      this.setLotteriesUnChecked();
      this.setupParameter();
      this.randomizer.setResult(this.randomizer.anyNext(this.specifiedNumberTarget.value));
    } catch (e) {
      this.viewToast(e);
    }
    this.randomizer.writeResult();
  }
  uncheckedDrawToTarget() {
    try {
      this.setLotteriesUnChecked();
      this.setupParameter();
      this.targetDraw();
    } catch (e) {
      this.viewToast(e);
    }
    this.randomizer.writeResult();
  }
  halfDraw() {
    let halfNum = Math.floor(this.setValueTarget.value / 2)
    if (halfNum <= 0) {
      this.viewToast("ボックスの数が無いか、無限のため引くことができません。", "半数引きエラー");
      return;
    }
    try {
      this.setLotteriesAll();
      this.setupParameter();
      this.randomizer.setResult(this.randomizer.anyNext(halfNum));
    } catch (e) {
      this.viewToast(e);
    }
    this.randomizer.writeResult();
  }
  allDraw() {
    let allNum = this.setValueTarget.value
    if (allNum <= 0) {
      this.viewToast("ボックスの数が無いか、無限のため引くことができません。", "全数引きエラー");
      return;
    }
    try {
      this.setLotteriesAll();
      this.setupParameter();
      this.randomizer.setResult(this.randomizer.anyNext(allNum));
    } catch (e) {
      this.viewToast(e);
    }
    this.randomizer.writeResult();
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
      let result = this.randomizer.setResult(this.randomizer.next())
      if (targetLotteriesList.some(element => element.name == result.name)) {
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
