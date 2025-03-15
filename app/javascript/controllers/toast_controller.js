import { Controller } from "@hotwired/stimulus"
import { Toast } from "bootstrap"

// Connects to data-controller="toast"
export default class extends Controller {
  static targets = ["infoToast"]
  connect() {
    this.toast = new Toast(this.infoToastTarget);
    this.toast.show()
  }
}
