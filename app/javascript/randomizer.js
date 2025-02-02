// randomizer機能
import { MersenneTwister } from "mt";

class RandomizerResult {
  constructor() {
    this.randomizeResult = "";
    this.cache = "";
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
    this.cache = this.randomizeResult.innerText + string;
  }
}

// Xrandom方式の乱数精製
class Xrandom {
  constructor(seed1 = new Date(), seed2 = 198101012) {
    this.state1 = seed1;
    this.state2 = seed2;
  }

  chkSeed() {
    return this.state1;
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
    this.rd = new Xrandom();
    this.result = new RandomizerResult();
    this.min = 0;
    this.max = 0;
  }

  setSeed(seed) {
    this.metw.setSeed(seed);
    this.rd.setSeed(seed);
  }
  chkSeed() {
    seed = this.rd.chkSeed();
    this.metw.setSeed(seed);
    return seed;
  }
  setRange(min = 0, max = 0) {
    this.min = min;
    this.max = max;
  }

  calRange(range) {
    if (typeof range !== "object") {
      throw new TypeError("引数はオブジェクト（配列）のみになります。");
    }
    this.setRange(0, range.length - 1);
  }
  correction(input) {
    return Math.round(input * (this.max - this.min) + this.min);
  }

  anyNextMt(count = 1) {
    let results = [];
    for (let i = 0; i < count; i++)
      results.push(this.nextMt());
    return results;
  }
  anyNextXs(count = 1) {
    let results = [];
    for (let i = 0; i < count; i++)
      results.push(this.nextXs());
    return results;
  }

  nextMt() {
    return this.correction(this.metw.next());
  }
  nextXs() {
    return this.correction(this.rd.next());
  }

  setResult(string) {
    this.result.setText(string);
  }
  refresh() {
    this.result.refresh();
  }
}
