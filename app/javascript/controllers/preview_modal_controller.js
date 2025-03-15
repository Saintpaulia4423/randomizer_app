import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  connect() {
    this.modal = new bootstrap.Modal(this.element)

    this.modal.show()
  }

  close(event) {
    console.log(event)
    if (event.detail.success) {
      this.modal.hide()
    }
  }
}
