import { Controller } from "@hotwired/stimulus"
import { MersenneTwister } from "mt"
import { Randomizer } from "randomizer"

// Connects to data-controller="random-sets"
export default class extends Controller {
  static targets = ["seed"]
  connect() {
    this.x = new MersenneTwister();
    this.y = new Randomizer();
  }
  access() {
    console.log("connect check", this.element);
    console.log(this.x.next());
    console.log(this.y.nextXs() + "::" + this.y.nextMt());
  }
}
