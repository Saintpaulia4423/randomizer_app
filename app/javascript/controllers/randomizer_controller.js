import { Controller } from "@hotwired/stimulus"
import { Randomizer } from "randomizer"

// Connects to data-controller="random-sets"
export default class extends Controller {
  static targets = ["specifiedNumber", "seed", "randomizerSwitch", "lotteries", "lottery", "randomizerParmerter", "resultTable", "realityPickRate", "pickUpRate", "pickupedLottery", "realityTranslation"];
  connect() {
    this.randomizer = new Randomizer();
    this.targetNum = this.specifiedNumberTarget;
    this.seedCache;
    this.lotteries = [];
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
  draw(count = 0) {
    if (this.lotteries === "") {
      console.log("error:not set lotteries data.");
      return -1
    }
  }

  oneDraw() {
    this.setLotteriesAll();
    this.setupParameter();
    let nextValue = this.randomizer.next();
    // console.log(nextValue)
    let lot = this.randomizer.getLottery(nextValue);
    // console.log(lot);
    this.randomizer.setResult(lot);
    // this.randomizer.testRandomizerResult(lot);
    this.randomizer.result.calResultAccessory();
    console.log(this.randomizer.result.cache);
    this.randomizer.result.testConvert();
    // console.log(this.randomizer.result.convert())
  }
  tenDraw() {
    let array = [];
    this.setLotteriesAll();
    switch (this.setupParameter()) {
      case "MersseneTwister":
        array = this.randomizer.anyNextMt(10);
        break;
      case "XorShift":
        array = this.randomizer.anyNextXs(10);
        break;
    }
    console.log(array);
  }
  specifiedDraw() {
    this.setLotteriesAll();
    this.setupParameter();
    console.log(this.lotteries[1].length)
  }
  drawToTarget() {
    this.setLotteriesAll();
    this.setupParameter();
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

}
