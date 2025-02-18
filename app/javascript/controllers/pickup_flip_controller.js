import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pickup-flip"
export default class extends Controller {
  flip(event) {
    let target = event.currentTarget.children[0];
    target.classList.toggle("bi-stars");
  }
}
