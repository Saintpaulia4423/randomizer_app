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
  // 仮想テーブルに書き込み、または数量の増加。
  setCache(object) {
    if (typeof object == "undefined") {
      console.error("randomizer Result Error:不正な値をセットしようとしました。 インプット:" + object);
      return -1;
    }
    let cacheIndex = this.cache.findIndex(element => element.id == object.id);
    if (cacheIndex == -1) {
      object.value = 1;
      this.cache.push(object);
    } else {
      this.cache[cacheIndex].value++;
    }
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
  // ヒット割合の計算
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
  // 
  writeResult() {
    this.calResultAccessory();
    this.refresh();
    this.cache.map(element => this.convert(element));
  }

  // test用処理
  testSetResult(input) {
    this.testInput = input;
  }
  testResult(input) {
    console.log(input)
    // console.log(this.testInput);
  }
}

// XorShift方式の乱数精製
class XorShift {
  DEFAULT_SEED1 = 108101012;
  DEFAULT_SEED2 = 123456789;
  DEFAULT_SEED3 = 232139941;
  constructor(seed1 = new Date().getTime(), seed2 = this.DEFAULT_SEED1) {
    this.state1 = seed1;
    this.state2 = seed2;
    this.state3 = this.DEFAULT_SEED2;
    this.state4 = this.DEFAULT_SEED3;
  }

  chkSeed() {
    return this.state1;
  }
  setSeed(seed) {
    this.state1 = seed;
    this.state2 = this.DEFAULT_SEED1;
    this.state3 = this.DEFAULT_SEED2;
    this.state4 = this.DEFAULT_SEED3;
  }

  next() {
    let result = (this.state1 ^ (this.state1 << 11));
    this.state1 = this.state2;
    this.state2 = this.state3;
    this.state3 = this.state4;

    this.state4 = (this.state4 ^ (this.state4 >> 19)) ^ (result ^ (result >> 8));
    return (this.state4) / 0x7FFFFFFF;
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

// 線形合同方式
// 方式はC++V11であるMINSTD方式。
class LCGs {
  DEFAULT_MULTIPLIER = 48271;
  DEFALUT_INCREMENT = 0;
  DEFALUT_MODULUS = Math.pow(2, 31) - 1;
  constructor(seed = new Date().getTime()) {
    this.seed = seed;
    this.multiplier = this.DEFAULT_MULTIPLIER;
    this.increment = this.DEFALUT_INCREMENT;
    this.mod = this.DEFALUT_MODULUS;
  }
  setSeed(seed) {
    this.seed = seed;
  }
  next() {
    this.seed = (this.multiplier * this.seed + this.increment) % this.mod;
    return this.seed / 0x7FFFFFFF;
  }
}

// Randomizer本体部
export class Randomizer {
  constructor() {
    this.metw = new MersenneTwister();
    this.rd = new XorShift();
    this.liner = new LCGs();
    this.result = new RandomizerResult();
    this.min = 0;
    this.max = 0;
    this.lotteries = []; // 今回抽選するlottery
    this.originLotteries = []; // 
    this.randomCalicurationMode = "MersseneTwister"; // 利用するrandomizerの方式
    this.lotteriesRealityList = []; // lotteryに含まれる全てのレアリティ
    this.realityRates = []; // レアリティ抽選率のリスト
    this.pickupRates = []; // ピックアップ抽選率のリスト
    this.matchedList = [];  // レアリティ登録のあるレアリティ
    this.unmatchedList = []; // レアリティ登録のないレアリティ
    this.pickupList = []; // ピックアップ登録されているレアリティ
    this.sumProbability; // 確率計算、未登録レアリティがlotteryなければレアリティリストの合算、そうでなければ100の倍数のceilされたもの
    this.subProbability; // 確率計算、未登録レアリティがlotteryにあればsumProbabilityの100倍数ceil前のとceil後の差分
    this.floatCheck = false; // 確率計算において小数点以下が発生した際の処理。小数点がなければ高速化する。
    this.lotStyle; // mixかboxの判定
    this.pickupStyle; // 現在未使用状態
    this.valueFrameObjectList; // レアリティ別個数のレアリティ個数の制御
    this.valueFrameRealityList; // レアリティ別個数のレアリティのリスト
    this.lotteriesValueObjectList; // lotteryの個数の制御
    this.boxValue; // セット全体の数量
    this.allResetCount; // リセット回数
  }

  // get・setter処理群
  setSeed(seed) {
    this.metw.setSeed(seed);
    this.rd.setSeed(seed);
    this.liner.setSeed(seed);
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
      case "LinearCGs":
      case "MathRandom":
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
  setValueList(valueListObject, valueLotteriesObject, valueBox, resetCount) {
    this.valueFrameObjectList = valueListObject;
    this.lotteriesValueObjectList = valueLotteriesObject;
    this.boxValue = valueBox;
    this.allResetCount = resetCount;
    // box時に元の情報を用意する。
    this.originLotteries = this.lotteries
  }
  setResetPattern(valueFrameReset, lotteryValueReset) {
    this.valueFrameReset = valueFrameReset.value;
    this.lotteryValueReset = lotteryValueReset.value;
  }
  setStyles(lotStyle, pickupStyle) {
    switch (lotStyle) {
      case "box":
      case "mix":
        this.lotStyle = lotStyle;
        break;
      default:
        throw new Error("規定されていない抽選タイプが設定されています。");
    }
    switch (pickupStyle) {
      case "pre":
      case "percent-ave":
      case "percent-fix":
        this.pickupStyle = pickupStyle;
        break;
      default:
        throw new Error("規定されていないピックアップ抽選方式が設定されています。");
    }
  }

  // pickrateとlotteriesの照合と確率計算
  chkPickRate() {
    if (this.realityRates == "") {
      console.error("randomizer chkPickRate: not set realityRates");
      throw new Error("レアリティ情報が提供されていません。")
    } else if (this.lotteries == "") {
      console.error("randomizer chkPickRate: not set lotteries");
      throw new Error("セット情報が提供されていません。")
    }

    // lotteriesからレアリティ抽出
    // lotteriesから含まれているレアリティ抽出
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

    // bos時にreality,valueが0の物はここで排除する。
    if (this.lotStyle == "box") {
      // lotteryを排除する。
      this.lotteries = this.lotteries.filter(element => element.value != 0);
      // realityを排除する。
      // reject_reality = this.lotteries.filter(element => )
      console.log(this.matchedList)
      console.log(this.lotteries[0])
    }

    // 確率計算
    // 端数が生じた場合100の倍数に調整
    // 非設定項目用にそれまでの差分をsubProbabilityとして取得。
    this.sumProbability = this.matchedList.reduce((sum, element) => sum + element.value, 0);
    // matchedListが鳴ければ非判定
    // unmatchedListが存在すればその確率を計算する。
    // unmatchedListも鳴ければsumで終わり
    if (this.matchedList == "") {
      this.subProbability = 100;
      this.setRange(0, this.subProbability);
    } else if (this.unmatchedList != "") {
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
      throw new Error("ピックアップ情報が提供されていません。")
    }

    this.pickupList = this.pickupRates.filter(element => {
      return this.lotteriesRealityList.includes(element.reality);
    });
  }
  // 個数の照合
  chkValueList() {
    // boxの場合処理をしない。
    if (this.lotStyle != "box") {
      return 0
    }

    // リストフレームの合算値とロット別の合算値計算
    this.valueFrameSum = this.valueFrameObjectList.reduce((accumulator, element) => {
      if (!this.controleValue(element, "isInfinity"))
        return accumulator + this.controleValue(element, "value")
      else
        return accumulator
    }, 0)
    this.valueLotteriesSum = this.lotteriesValueObjectList.reduce((accumulator, element) => {
      if (!this.controleValue(element, "isInfinity"))
        return accumulator + this.controleValue(element, "value")
      else
        return accumulator
    }, 0)
    console.log(this.boxValue)
    console.log(this.allResetCount)
    this.resetValues()
  }
  // valueの変換用
  controleValue(object, index) {
    let allowlist = ["INPUT"];
    switch (index) {
      case "reality":
        return Number(object.dataset.reality);
      case "value":
        return allowlist.includes(object.tagName) ? parseInt(object.value) : parseInt(object.dataset.value);
      case "default":
        return parseInt(object.dataset.defaultValue);
      case "reset":
        if (allowlist.includes(object.tagName)) {
          object.value = this.controleValue(object, "default");
        } else {
          object.dataset.value = this.controleValue(object, "default");
          object.text = this.controleValue(object, "default");
        }
        break;
      case "isInfinity":
        if (allowlist.includes(object.tagName)) {
          return (object.value == -1) ? true : false
        } else {
          return (object.dataset.value == -1) ? true : false
        }
      case "add":
        if (allowlist.includes(object.tagName)) {
          object.value++;
        } else {
          object.dataset.value++;
        }
        break;
      case "reduce":
        if (allowlist.includes(object.tagName)) {
          object.value--;
        } else {
          object.dataset.value--;
        }
        break;
    }
  }
  reduceValue(object) {
    // 全体ボックス数
    if (this.controleValue(this.boxValue, "isInfinity")) {
    } else if (this.boxValue.value == 0) {
      // リセット処理
      this.controleValue(this.boxValue, "reset");
      this.controleValue(this.allResetCount, "add");
      this.resetValues(this.valueFrameObjectList, this.valueFrameReset);
      this.resetValues(this.lotteriesValueObjectList, this.lotteryValueReset);
      this.controleValue(this.boxValue, "reduce");
    } else {
      // 通常時
      this.controleValue(this.boxValue, "reduce");
    }

  }
  // resetFrameとlotteryValueをリセットする。
  resetValues(objectArray, mode) {
    switch (mode) {
      case "reset":
        objectArray.map(element => this.controleValue(element, "reset"));
        break;
      case "onlyZero":
        objectArray.filter(element => this.controleValue(element, "value") == 0)
          .map(element => this.controleValue(element, "reset"));
        break;
    }
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
    // value処理追加予定地
    hitLotteries = this.getPickupLottery(hitLotteries);
    if (hitLotteries.length == 1) {
      return hitLotteries[0];
    } else {
      return hitLotteries[this.nextRange(hitLotteries.length, 0, "integer") - 1];
    }
  }
  // ピックアップ抽選処理。
  // ピックアップ時はピックアップのリストのみ。すり抜け時はピックアップを除いたリストを返す。
  // percent-ave,fixは改めて考えましたがpreとほぼ同一のため、残存しています。
  getPickupLottery(rawLotteries) {
    if (!this.pickupList.length) {
      return rawLotteries;
    }

    // ピックアップ対象と非対象を分離
    let filteredPickupList = rawLotteries.reduce((accumulator, element) => {
      if (element.pickup) {
        accumulator.pickup.push(element);
      } else {
        accumulator.unpickup.push(element);
      }
      return accumulator;
    }, { pickup: [], unpickup: [] });
    // 分離結果、片方のリストが存在しない場合は、元の値で返す。
    if (!filteredPickupList.pickup.length || !filteredPickupList.unpickup.length) {
      return rawLotteries;
    }

    let pickupValue = this.pickupList[0].value
    let pickSelect = this.nextRange(Math.ceil(pickupValue / 100) * 100, 0, "integer") - 1;
    if (pickSelect >= pickupValue) {
      return filteredPickupList.pickup;
    } else {
      return filteredPickupList.unpickup;
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
    if ((this.floatCheck && mode == "") || mode == "float") {
      return input * (this.max - this.min) + this.min;
    } else {
      return Math.ceil(input * (this.max - this.min) + this.min);
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
      case "LinearCGs":
        return this.correction(this.liner.next(), correctionMode);
      case "MathRandom":
        return this.correction(Math.random(), correctionMode);
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
    if (Array.isArray(object)) {
      let lots = object.map(element => this.getLottery(element))
      lots.map(element => this.result.setCache(element));
      return lots
    } else {
      let lot = this.getLottery(object)
      this.result.setCache(lot);
      return lot
    }
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
  writeResult() {
    this.result.writeResult();
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
