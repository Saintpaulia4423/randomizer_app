import { Controller } from "@hotwired/stimulus"
import { MersenneTwister } from "mt"
import { Randomizer } from "randomizer"

// Connects to data-controller="random-sets"
export default class extends Controller {
  connect() {
    this.x = new MersenneTwister();
    this.y = new Randomizer();
    this.seed = document.getElementById("randomSeed");
  }
  oneDraw() {
    console.log("clicked!");
  }
  tenDraw() {

  }
  anyDraw() {

  }
  drawToTarget() {

  }
}
