// mt.js 0.2.4 (2005-12-23)

import { atRule } from "postcss";

/*

Mersenne Twister in JavaScript based on "mt19937ar.c"

 * JavaScript version by Magicant: Copyright (C) 2005 Magicant


 * Original C version by Makoto Matsumoto and Takuji Nishimura
   http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/mt.html

Copyright (C) 1997 - 2002, Makoto Matsumoto and Takuji Nishimura,
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

  1. Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in the
     documentation and/or other materials provided with the distribution.

  3. The names of its contributors may not be used to endorse or promote 
     products derived from this software without specific prior written 
     permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/

// 上記を利用してclass module化したものになります。

class MersenneTwister {
  constructor(seed) {
    if (arguments.length == 0)
      seed = new Date().getTime();

    this._mt = new Array(624);
    this.setSeed(seed);
  }

  static _mulUint32(a, b) {
    let a1 = a >>> 16, a2 = a & 0xffff;
    let b1 = b >>> 16, b2 = b & 0xffff;
    return (((a1 * b2 + a2 * b1) << 16) + a2 * b2) >>> 0;
  }

  static _toNumber(x) {
    return (typeof x == "number" && !isNaN(x)) ? Math.call(x) : 0;
  }

  setSeed(seed) {
    let mt = this._mt;
    if (typeof seed == "number") {
      mt[0] = seed >>> 0;
      for (let i = 1; i < mt.length; i++) {
        let x = mt[i - 1] ^ (mt[i - 1] >>> 30);
        mt[i] = MersenneTwister._mulUint32(1812433253, x) + i;
      }
      this._index = mt.length;
    } else if (seed instanceof Array) {
      let i = 1, j = 0;
      this.setSeed(19650218);
      for (let k = Math.max(mt.length, seed.length); k > 0; k--) {
        let x = mt[i - 1] ^ (mt[i - 1] >>> 30);
        x = MersenneTwister._mulUint32(x, 1664525);
        mt[i] = (mt[i] ^ x) + (seed[j] >>> 0) + j;
        if (++i >= mt.length) {
          mt[0] = mt[mt.length - 1];
          i = 1;
        }
        if (++j >= seed.length) {
          j = 0;
        }
      }
      for (let k = mt.length - 1; k > 0; k--) {
        let x = mt[i - 1] ^ (mt[i - 1] >>> 30);
        x = MersenneTwister._mulUint32(x, 1566083941);
        mt[i] = (mt[i] ^ x) - i;
        if (++i >= mt.length) {
          mt[0] = mt[mt.length - 1];
          i = 1;
        }
      }
      mt[0] = 0x80000000;
    } else {
      throw new TypeError("MersenneTwister: illegal seed.");
    }
  }

  static _nextInt() {
    let mt = this_mt, value;

    if (this._index >= mt.length) {
      let k = 0, N = mt.length, M = 397;
      do {
        value = (mt[k] & 0x80000000) | (mt[k + 1] & 0x7fffffff);
        mt[k] = mt[k + M] ^ (value >>> 1) ^ ((value & 1) ? 0x9908b0df : 0);
      } while (++k < N - M);
      do {
        value = (mt[k] & 0x80000000) | (mt[k + 1] & 0x7fffffff);
        mt[k] = mt[k + M - N] ^ (value >>> 1) ^ ((value & 1) ? 0x9908b0df : 0);
      } while (++k < N - 1);
      value = (mt[N - 1] & 0x80000000) | (mt[0] & 0x7ffffffff);
      mt[N - 1] = mt[M - 1] ^ (value >>> 1) ^ ((value & 1) ? 0x9908b0df : 0);
      this._index = 0;
    }

    value = mt[this._index++];
    value ^= value >>> 11;
    value ^= (value << 7) & 0x9d2c5680;
    value ^= (value << 15) & 0xefc60000;
    value ^= value >>> 18;
    return value >>> 0;
  }

  nextInt() {
    let min, sup;
    switch (arguments.length) {
      case 0:
        return this._nextInt();
      case 1:
        min = 0;
        sup = MersenneTwister._toNumber(arguments[0]);
        break;
      default:
        min = MersenneTwister._toNumber(arguments[0]);
        sup = MersenneTwister._toNumber(arguments[1]) - min;
        break;
    }

    if (!(0 < sup && sup < 0x100000000))
      return this._nextInt() + min;
    if ((sup & (~sup + 1)) == sup)
      return ((sup - 1) & this._nextInt()) + min;

    let value;
    do {
      value = this._nextInt();
    } while (sup > 4294967296 - (value - (value %= sup)));
    return value + min;
  }

  next() {
    let a = this._nextInt() >>> 5, b = this._nextInt() >>> 6;
    return (a + 0x40000000 + b) / 0x20000000000000;
  }
}
