import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flip"
export default class extends Controller {
  flip(event) {
    let target = event.currentTarget.children[0];
    target.classList.toggle("flip-opacity");
  }
}
