import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

// Connects to data-controller="number-change"
export default class extends Controller {
  static targets = ["modal", "inputValue", "inputDefaultValue", "validate", "lotteriesValue"];
  connect() {
    this.modal = new Modal(this.modalTarget)
  }
  change(event) {
    this.targetAssign = event.target;
    this.type = this.targetAssign.dataset.type

    this.inputDefaultValueTarget.value = parseInt(event.target.dataset.defaultValue)
    this.inputValueTarget.value = parseInt(event.target.dataset.value)
    this.validateTarget.classList.add("d-none")
    this.validateTarget.innertText = ""

    this.modal.show()
  }
  submit() {
    try {
      this.validateCheck()
    } catch (error) {
      console.log(error)
      this.validateTarget.innerText = error
      this.validateTarget.classList.remove("d-none")
      return
    }

    this.targetAssign.dataset.defaultValue = parseInt(this.inputDefaultValueTarget.value)
    if (this.targetAssign.dataset.defaultValue != -1)
      this.targetAssign.dataset.value = parseInt(this.inputValueTarget.value)
    else
      this.targetAssign.dataset.value = parseInt(-1)
    if (this.inputDefaultValueTarget.value != -1) {
      this.targetAssign.classList.remove("bi", "bi-infinity")
      this.targetAssign.innerText = this.inputValueTarget.value
    } else {
      this.targetAssign.classList.add("bi", "bi-infinity")
      this.targetAssign.innerText = ""
    }
    this.modal.hide()
  }
  validateCheck() {
    if (parseInt(this.inputDefaultValueTarget.value) < -1)
      throw new Error("\n初期値の最低値は-1までです。")
    if (parseInt(this.inputValueTarget.value) < -1)
      throw new Error("\n現在の個数の最低値は-1までです。")
    if (this.inputDefaultValueTarget.value != -1 && this.inputValueTarget.value == -1)
      throw new Error("\n現在の値が無限を指定していますが、初期値が異なります。\n無限を希望する場合は「現在の初期値」に-1を入力してください。")
  }
  reset() {
    let lotsValue = this.lotteriesValueTargets
    console.log(this.lotteriesValueTargets)
    console.log(this.lotteriesValueTargets.filter(i => !(i.dataset.defaultValue < 0)))
    lotsValue.filter(i => !(i.dataset.defaultValue < 0)).forEach(element => {
      element.dataset.value = element.dataset.defaultValue;
      element.innerText = element.dataset.defaultValue;
    });
  }
}
