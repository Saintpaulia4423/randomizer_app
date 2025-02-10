import { Controller } from "@hotwired/stimulus"
import { Randomizer } from "randomizer"

// Connects to data-controller="random-sets"
export default class extends Controller {
  static targets = ["specifiedNumber", "seed", "randomizerSwitch", "lotteries", "randomizerParmerter"];
  connect() {
    this.randomizer = new Randomizer();
    this.targetNum = this.specifiedNumberTarget;
    this.seedCache;
    this.lotteries = [];
  }

  chkParameter() {
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
    return selectPattern;
  }
  setSeed() {
    this.randomizer.setSeed(Number(this.seedTarget.value));
  }
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
      if (lottery.checked) {
        this.setLottery(lottery);
      }
    });
    this.randomizer.setLotteriesArray(this.lotteries);
  }
  setLotteriesUnChecked() {
    let array = this.lotteriesTargets;
    this.resetLottery();
    array.forEach(lottery => {
      if (!lottery.checked) {
        this.setLottery(lottery);
      }
    });
    this.randomizer.setLotteriesArray(this.lotteries);
  }
  setLottery(lotteryObject) {
    let json = JSON.parse(lotteryObject.value);
    if (!this.lotteries[json.reality])
      this.lotteries[json.reality] = [];
    this.lotteries[json.reality].push(json)
  }
  resetLottery() {
    this.lotteries = [];
  }

  draw(count = 0) {
    if (this.lotteries === "") {
      console.log("error:not set lotteries data.");
      return -1
    }
  }

  oneDraw() {
    this.setLotteriesAll();
    console.log(this.randomizer.next(this.chkParameter()));

    console.log(this.lotteries)
    console.log(this.lotteries.length)
  }
  tenDraw() {
    let array = [];
    this.setLotteriesAll();
    switch (this.chkParameter()) {
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
    this.chkParameter();
    console.log(this.lotteries[1].length)
  }
  drawToTarget() {
    this.setLotteriesAll();
    this.chkParameter();
  }
  checkedSpecifiedDraw() {
    this.setLotteriesChecked();
    this.chkParameter();
    this.randomizer.setRange(0, 100)
    for (let i = 0; i <= 10; i++)
      console.log(this.randomizer.next());
  }
  checkedDrawTarget() {
    this.setLotteriesChecked();
    this.chkParameter();
  }
  uncheckedSpecifiedDraw() {
    this.setLotteriesUnChecked();
    this.chkParameter();
    console.log(this.lotteries.length)
    console.log(this.lotteries.forEach(element => { console.log(element + ":" + element.length) }))
  }
  uncheckedDrawToTarget() {
    this.setLotteriesUnChecked();
    this.chkParameter();
    console.log("test");

    this.randomizer.setResult('<p value={name: "test"}>test</p>');
    this.randomizer.refresh();
  }

  chooseTarget() {
    console.log("テスト");
  }
  resetTarget() {
    this.randomizer.setRange(50, 100);
    console.log(this.randomizer.next())
  }

  settingPickup() {

  }
  resetPickup() {

  }

  resetResult() {
    console.log("リセット！");
  }
}
