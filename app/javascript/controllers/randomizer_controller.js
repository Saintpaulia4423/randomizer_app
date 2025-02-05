import { Controller } from "@hotwired/stimulus"
import { Randomizer } from "randomizer"

// Connects to data-controller="random-sets"
export default class extends Controller {
  connect() {
    this.randomizer = new Randomizer();
    this.targetNum = document.getElementById("anyDrawNumber");
    this.seedCache;
    this.lotteries = [];
  }

  chkParameter() {
    // シード値
    let seed = document.getElementById("randomSeed");
    let seedNum = Number(seed.value);
    if (seedNum == "") {
      seed.value = this.randomizer.getSeed();
      this.seedCache = seed.value;
    } else if (seedNum != this.seedCache) {
      this.randomizer.setSeed(seedNum);
      this.seedCache = seedNum;
    }

    // 乱数精製方式
    let selectPattern;
    let radios = document.querySelectorAll("input[name=randomizerSwitched]");
    radios.forEach(radio => {
      if (radio.checked) {
        selectPattern = radio.value;
      }
    });

    return selectPattern;
  }
  setLotteriesAll() {
    let array = document.querySelectorAll("input[name=Lotteries]");
    array.forEach(lottery => {
      this.setLottery(lottery);
    });
  }
  setLotteriesChecked() {
    let array = document.querySelectorAll("input[name=Lotteries]");
    array.forEach(lottery => {
      if (lottery.checked) {
        this.setLottery(lottery);
      }
    });
  }
  setLotteriesUnChecked() {
    let array = document.querySelectorAll("input[name=Lotteries]");
    array.forEach(lottery => {
      if (!lottery.checked) {
        this.setLottery(lottery);
      }
    });
  }
  setLottery(lotteryObject) {
    let json = JSON.parse(lotteryObject.value);
    if (!this.lotteries[json.reality])
      this.lotteries[json.reality] = [];
    this.lotteries[json.reality].push(json)
  }

  draw(count = 0) {
    if (this.lotteries === "") {
      console.log("error:not set lotteries data.");
      return -1
    }
  }

  oneDraw() {
    this.setLotteriesAll();
    switch (this.chkParameter()) {
      case "MersseneTwister":
        this.randomizer.setResult(this.randomizer.nextMt().string);
        break;
      case "Xrandom":
        this.randomizer.setResult(this.randomizer.nextXs().string);
        break;
    }
  }
  tenDraw() {
    let array = [];
    this.setLotteriesAll();
    switch (this.chkParameter()) {
      case "MersseneTwister":
        array = this.randomizer.anyNextMt(10);
        break;
      case "Xrandom":
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
  }
  checkedDrawToTarget() {
    this.setLotteriesChecked();
    this.chkParameter();
  }
  uncheckedSpecifiedDraw() {
    this.setLotteriesUnChecked();
    this.chkParameter();

  }
  uncheckedDrawToTarget() {
    this.setLotteriesUnChecked();
    this.chkParameter();
    console.log("test");

    this.randomizer.setResult('<p value={name: "test"}>test</p>');
    this.randomizer.refresh();
  }

  chooseTarget() {

  }
  resetTartget() {

  }

  settingPickup() {

  }
  resetPickup() {

  }
}
