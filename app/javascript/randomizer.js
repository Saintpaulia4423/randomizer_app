// randomizer機能
import { MersenneTwister } from "mt";

class RandomizerResult {
  constructor() {
    this.randomizeResult = "";
    this.cache = "";
    this.objectList;
  }

  initialize() {
    this.randomizeResult = document.getElementById("result");
  }
  chkElement() {
    if (this.randomizeResult === "") {
      this.initialize();
    }
  }
  reset() {
    this.chkElement();
    this.randomizeResult = "";
    this.cache = "";
  }
  refresh() {
    this.chkElement();
    this.randomizeResult.innerText = this.cache;
  }

  setText(string) {
    this.chkElement();
    this.cache = this.cache + string;
  }
  addContent(object) {

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
  }

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
        console.log("randomizer setMode:Parameter Rejected [input:" + mode + "]");
    }
  }

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
  correction(input) {
    return Math.round(input * (this.max - this.min) + this.min);
  }

  anyNext(count = 1) {
    let results = [];
    for (let i = 0; i < count; i++)
      results.push(this.next());
    return results;
  }

  next(mode = this.randomCalicurationMode) {
    switch (mode) {
      case "MersseneTwister":
        return this.correction(this.metw.next());
      case "XorShift":
        return this.correction(this.rd.next());
    }
  }
  nextRange(max = this.max, min = this.min) {
    let beforeMax = this.max;
    let beforeMin = this.min;
    this.setRange(min, max);
    let result = this.next();
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

  setResult(string) {
    this.result.setText(string);
  }
  refresh() {
    this.result.refresh();
  }
  viewStatus() {
    return this.result.cache;
  }
}
