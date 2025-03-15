import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flip"
export default class extends Controller {
  TARGET_CLASS_NAME = "flip-opacity"
  flip(event) {
    let target = event.currentTarget.children[0];
    target.classList.toggle(this.TARGET_CLASS_NAME);
  }
  linkedCheckbox(event) {
    let target = event.currentTarget.children[0];
    let checkbox = Array.from(event.currentTarget.children).filter(element => element.type == "checkbox")[0];
    if (!checkbox.checked)
      target.classList.add(this.TARGET_CLASS_NAME);
    else
      target.classList.remove(this.TARGET_CLASS_NAME);
  }
}
