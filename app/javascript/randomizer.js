// randomizer機能
import { MersenneTwister } from "mt";

// result表示、統括
class RandomizerResult {
  RATIO_POINT = 5;
  constructor() {
    this.randomizeResult = "";
    this.cache = [];
    this.sum = 0;
    this.objectList;
    this.translationList = [];
  }

  // ResultTable処理
  setResultTarget(object) {
    if (typeof object != "object") {
      console.error("ranodmizer Result Error:非オブジェクトがアタッチされようとしましたが、拒絶されました。");
      return -1;
    }
    this.objectList = object;
  }
  setTranslation(List) {
    this.translationList = List;
  }
  getResultTables() {
    if (this.objectList == "") {
      console.error("ranodmizer Result Error:結果表示オブジェクトがアタッチされていません。");
      return -1;
    }
    return this.objectList
  }

  // 描画処理
  reset() {
    this.cache = [];
    this.refresh();
  }
  // 表示されている内容を削除する。
  refresh() {
    let resultLength = this.objectList.children[1].children.length;
    for (let i = 0; i != resultLength; i++) {
      this.objectList.deleteRow(-1);
    }
  }

  // テキスト処理
  setText(string) {
    this.cache = this.cache + string;
  }
  // resultTable用に変換を行う。
  convert(object, target = this.objectList.children[1]) {
    // Reality Name hit数 ヒット割合
    let newRow = target.insertRow();
    let cellIndex = 0;
    let nCReality = newRow.insertCell(cellIndex++);
    let nCName = newRow.insertCell(cellIndex++);
    let nCHit = newRow.insertCell(cellIndex++);
    let nCRatio = newRow.insertCell(cellIndex++);

    let nCRChild = nCReality.appendChild(document.createElement("span"));
    nCRChild.dataset.value = object.reality;
    nCRChild.innerText = this.translationList[object.reality].innerText;
    nCName.innerText = object.name;
    let nCHChild = nCHit.appendChild(document.createElement("span"));
    nCHChild.dataset.value = object.value;
    nCHChild.innerText = object.value;
    let nCRaChild = nCRatio.appendChild(document.createElement("span"));
    let ratioValue = (object.ratio * 100).toPrecision(this.RATIO_POINT);
    nCRaChild.dataset.value = ratioValue;
    nCRaChild.innerText = ratioValue + "%";
  }

  setCache(object) {
    let cacheIndex = this.cache.findIndex(element => element.id == object.id);
    if (cacheIndex == -1) {
      object.value = 1;
      this.cache.push(object);
    } else {
      this.cache[cacheIndex].value++;
    }
  }
  calResultAccessory() {
    if (this.cache == "") {
      console.error("randomizer Result Error:キャッシュ情報が書き込まれる前に計算が実行されました。");
      return -1;
    }
    this.sum = this.cache.reduce((value, element) => value + element.value, 0);
    this.cache.map((element, index) => {
      this.cache[index].ratio = (element.value / this.sum).toPrecision(this.RATIO_POINT);
    });
  }

  // test用処理
  testSetResult(input) {
    this.testInput = input;
  }
  testResult(input) {
    console.log(input)
    // console.log(this.testInput);
  }
  testConvert(input) {
    this.refresh();
    this.cache.map(element => this.convert(element));
  }
}

// Xrandom方式の乱数精製
class XorShift {
  DEFAULT_SEED2 = 108101012;
  constructor(seed1 = new Date().getTime(), seed2 = this.DEFAULT_SEED2) {
    console.log("Xrandom connect")
    this.state1 = seed1;
    this.state2 = seed2;
  }

  chkSeed() {
    return this.state1;
  }
  setSeed(seed) {
    this.state1 = seed;
    this.state2 = this.DEFAULT_SEED2;
  }

  next() {
    let s1 = this.state1;
    let s2 = this.state2;
    this.state1 = s2;
    s1 ^= s1 << 23;
    this.state2 = s1 ^ s2 ^ (s1 >> 17) ^ (s2 >> 26);
    return (this.state2 + s2) / 0xFFFFFFFF;
  }

  nextInt() {
    let min, max;
    switch (arguments.length) {
      case 0:
        return this.next();
      case 1:
        min = 0;
        max = arguments[0];
        break;
      case 2:
        min = arguments[1];
        max = arguments[0];
        break;
    }
  }
}

// Randomizer本体部
export class Randomizer {
  constructor() {
    this.metw = new MersenneTwister();
    this.rd = new XorShift();
    this.result = new RandomizerResult();
    this.min = 0;
    this.max = 0;
    this.lotteries = [];
    this.randomCalicurationMode = "MersseneTwister";
    this.realityRates = [];
    this.pickupRates = [];
    this.matchedList = [];
    this.unmatchedList = [];
    this.pickupList = [];
    this.sumProbability;
    this.subProbability;
    this.floatCheck = false;
  }

  // get・setter処理群
  setSeed(seed) {
    this.metw.setSeed(seed);
    this.rd.setSeed(seed);
  }
  getSeed() {
    return this.rd.chkSeed();
  }
  setLotteriesArray(lotteries) {
    this.lotteries = lotteries;
  }
  setRange(min = 0, max = 0) {
    this.min = min;
    this.max = max;
  }
  setMode(mode) {
    switch (mode) {
      case "MersseneTwister":
      case "XorShift":
        this.randomCalicurationMode = mode;
        break;
      default:
        console.error("randomizer setMode:Parameter Rejected [input:" + mode + "]");
    }
  }
  setPickRate(pickRate) {
    this.floatCheck = false;
    this.realityRates = pickRate.map(element => {
      if (!this.floatCheck && !Number.isInteger(Number(element.value)))
        this.floatCheck = true;
      return { reality: Number(element.dataset.reality), value: Number(element.value) }
    });
  }
  setPickupList(pickupRatesObject) {
    this.pickupRates = pickupRatesObject.map(element => {
      if (!this.floatCheck && !Number.isInteger(Number(element.value)))
        this.floatCheck = true;
      return { reality: Number(element.dataset.reality), value: Number(element.value) }
    });
  }

  // pickrateとlotteriesの照合と確率計算
  chkPickRate() {
    if (this.realityRates == "") {
      console.error("randomizer chkPickRate: not set realityRates");
      return -1;
    } else if (this.lotteries == "") {
      console.error("randomizer chkPickRate: not set lotteries");
      return -1;
    }

    // lotteriesからレアリティ抽出
    // lotteriesから含まれているレアリティ抽出
    this.lotteriesRealityList = [];
    this.lotteries.forEach(element => {
      if (!this.lotteriesRealityList.includes(element.reality)) {
        this.lotteriesRealityList.push(element.reality);
      }
    });
    // 抽出したレアリティリストからlotteriesから抽出したレアリティと照合して必要分のみ出力。
    this.matchedList = this.realityRates.filter(element => {
      return this.lotteriesRealityList.includes(element.reality)
    });
    // lotteriesとして登録されているが、realityListに登録されていないものの一覧
    // 最終的に余っている確率で等分する。
    this.unmatchedList = this.lotteriesRealityList.map(value => {
      if (!this.matchedList.some(element => {
        return element.reality == value;
      })) {
        return { reality: Number(value) };
      } else {
        return false;
      }
    }).filter(element => typeof element == "object");

    // 確率計算
    // 端数が生じた場合100の倍数に調整
    // 非設定項目用にそれまでの差分をsubProbabilityとして取得。
    this.sumProbability = this.matchedList.reduce((sum, element) => sum + element.value, 0);
    // unmatchedListが存在すればその確率を計算する。
    if (this.unmatchedList != "") {
      this.subProbability = Math.ceil(this.sumProbability / 100) * 100 - this.sumProbability;
      this.setRange(0, this.sumProbability + this.subProbability);
    } else {
      // subProbabilityが-1の時はDraw判定時にスキップする。
      this.subProbability = -1;
      this.setRange(0, this.sumProbability);
    }
  }
  // ピックアップの照合
  chkPickupList() {
    if (this.lotteriesRealityList == "") {
      console.error("randomizer chkPickupList: not set lotteriesRealiryList");
      return -1;
    }

    this.pickupList = this.pickupRates.filter(element => {
      return this.lotteriesRealityList.includes(element.reality);
    });
  }

  // 抽選情報の取得
  // 数値を渡すと結果を返す。
  getLottery(number) {
    if (typeof number != "number") {
      console.error("randomizer getLottery: Bad Argument " + typeof number);
      return -1;
    } else if (number > this.sumProbability) {
      if ((number <= (this.sumProbability + this.subProbability)) && (this.subProbability != -1)) {

      } else {
        console.error("randomizer getLottery: Argument Over Flow. limit: " + this.sumProbability);
        return -1;
      }
    }

    // 当選レアリティ計算
    let resultReality = -1;
    if (number <= this.sumProbability) {
      this.matchedList.reduce((lot, currentReality) => {
        if (lot + currentReality.value >= number) {
          if (resultReality == -1)
            resultReality = currentReality;
          return lot;
        } else {
          return lot + currentReality.value;
        }
      }, 0);
    } else {
      // 未設定レアリティに当選した場合は等分計算。
      let rate = this.subProbability / this.unmatchedList.length;
      let unmatchNumber = number;
      if (!Number.isInteger(rate)) {
        unmatchNumber = this.nextRange(this.subProbability + this.sumProbability, this.sumProbability, "float");
      }
      console.log("ummatch:" + unmatchNumber)
      let unmatchRates = this.unmatchedList.map(element => {
        return rate;
      });
      unmatchRates.reduce((lot, currentReality, index) => {
        if (lot + currentReality >= unmatchNumber) {
          if (resultReality == -1)
            resultReality = this.unmatchedList[index];
          return lot;
        } else {
          return lot + currentReality;
        }
      }, this.sumProbability);
    }

    // 計算の結果
    let hitLotteries = this.lotteries.filter(element => element.reality == resultReality.reality);
    if (hitLotteries.length == 1) {
      return hitLotteries[0];
    } else {
      return hitLotteries[this.nextRange(hitLotteries.length - 1)];
    }
  }

  // Randomizer範囲指定処理群
  calRate() {

  }
  calRange(range) {
    if (typeof range !== "object") {
      throw new TypeError("引数はオブジェクト（配列）のみになります。");
    }
    // forEachにより要素なしを除外してlengthを計算。
    let temp;
    range.forEach(element => { temp++; });
    this.setRange(0, temp - 1);
  }
  correction(input, mode = "") {
    if (this.floatCheck || mode == "float") {
      return input * (this.max - this.min) + this.min;
    } else {
      return Math.round(input * (this.max - this.min) + this.min);
    }
  }

  // ドロー処理群
  anyNext(count = 1) {
    let results = [];
    for (let i = 0; i < count; i++)
      results.push(this.next());
    return results;
  }

  next(mode = this.randomCalicurationMode, correctionMode = "") {
    switch (mode) {
      case "MersseneTwister":
        return this.correction(this.metw.next(), correctionMode);
      case "XorShift":
        return this.correction(this.rd.next(), correctionMode);
    }
  }
  nextRange(max = this.max, min = this.min, mode = "") {
    let beforeMax = this.max;
    let beforeMin = this.min;
    this.setRange(min, max);
    let result = this.next(undefined, mode);
    this.setRange(beforeMin, beforeMax);
    return result;
  }
  nextRangeAndSpecify(count = 1, max = this.max, min = this.min) {
    let beforeMax = this.max;
    let beforeMin = this.min;
    this.setRange(min, max);
    let result = this.anyNext(count);
    this.setRange(beforeMin, beforeMax);
    return result;
  }

  // Randomizer subsystem処理群
  setResultTable(object) {
    this.result.setResultTarget(object);
  }
  setResult(object) {
    this.result.setCache(object);
  }
  refresh() {
    this.result.refresh();
  }
  viewStatus() {
    return this.result.cache;
  }
  resetResult() {
    this.result.reset();
  }
  setRealityTranslation(List) {
    this.result.setTranslation(List);
  }

  // test用処理
  testSetRandomizerResult(input) {
    this.result.testSetResult(input);
  }
  testRandomizerResult(input) {
    console.log(this.lotteries)
    console.log(this.lotteries.some(element => element.id == "11"))
  }
}
