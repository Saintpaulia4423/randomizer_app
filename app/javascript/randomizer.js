// randomizer機能
import { MersenneTwister } from "mt";

class RandomizerResult {
  constructor() {
    this.randomizeResult = "";
  }

  initialize() {
    this.randomizeResult = document.getElementById("result");
  }
  chkElement() {
    if (this.randomizeResult === "") {
      this.initialize();
    }
  }
  setText(x) {
    this.chkElement();
    this.randomizeResult.innerText += x;
  }
}

class Xrandom {
  constructor(seed1 = new Date(), seed2 = 198101012) {
    this.state1 = seed1;
    this.state2 = seed2;
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

export class Randomizer {
  constructor() {
    this.metw = new MersenneTwister();
    this.rd = new Xrandom();
  }

  setSeed(x) {
    this.metw.setSeed(x);
  }
  chkSeed() {
    seedValue = document.getElementById("randomSeed")
    if (seedValue != "")
      this.setSeed(seedValue)
  }

  getRandomMt(count = 1) {
    let results = [];
    for (let i = 0; i <= count; i++)
      results.push(this.metw.next());
    return results;
  }
  getRandomXs(count = 1) {
    let results = [];
    for (let i = 0; i <= count; i++)
      results.push(this.rd.next());
    return results;
  }
  nextMt() {
    return this.metw.next();
  }
  nextXs() {
    return this.rd.next();
  }

}
