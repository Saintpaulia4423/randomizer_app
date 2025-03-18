import { Controller } from "@hotwired/stimulus"
import { Toast } from "bootstrap"

// Connects to data-controller="info"
export default class extends Controller {
  static targets = ["infoModal", "value", "realityTranslation", "selectReality",
    "realityList", "selectedReality",
    "pickupList", "selectedPickup",
    "valueList", "selectedValue"];
  connect() {
    this.modal = new bootstrap.Modal(this.infoModalTarget);
    this.toast = new Toast(document.getElementById("toast"));
    this.switch = "";
  }
  addRealityModal() {
    this.switch = "reality";
    this.modal.show();
  }
  addPickupModal() {
    this.switch = "pickup";
    this.modal.show();
  }
  addValueModal() {
    this.switch = "value";
    this.modal.show()
  }
  reset(event) {
    let value_list = Array.from(event.target.closest("turbo-frame").querySelectorAll("input[type='number']"));
    value_list.map(element => element.value = element.dataset.defaultValue);
  }
  add() {
    switch (this.switch) {
      case "reality":
        this.addReality();
        break;
      case "pickup":
        this.addPickup();
        break;
      case "value":
        this.addValue();
        break;
      default:
        throw new Error("info_controller: not set switch");
    }
  }
  addReality() {
    let check = true;
    this.selectedRealityTargets.some(element => {
      if (element.dataset.value == this.selectRealityTarget.value) {
        this.viewToast("既に存在するレアリティ要素です。");
        check = false;
        return true;
      }
    });
    if (check)
      this.addHTML(this.selectRealityTarget.value, this.valueTarget.value, "selectedReality", "realityFrame", "%");
  }
  addPickup() {
    let check = true;
    this.selectedPickupTargets.some(element => {
      if (element.dataset.value == this.selectRealityTarget.value) {
        this.viewToast("既に存在するレアリティ要素です。");
        check = false;
        return true;
      }
    });
    if (check)
      this.addHTML(this.selectRealityTarget.value, this.valueTarget.value, "selectedPickup", "pickupFrame", "%");
  }
  addValue() {
    let check = true;
    this.selectedValueTargets.some(element => {
      if (element.dataset.value == this.selectRealityTarget.value) {
        this.viewToast("既に存在するレアリティ要素です。");
        check = false;
        return true;
      }
    });
    if (check)
      this.addHTML(this.selectRealityTarget.value, this.valueTarget.value, "selectedValue", "valueFrame", "個");
  }
  viewToast(message, title = "Warning") {
    const header = document.getElementById("toastHeader");
    const body = document.getElementById("toastBody");

    header.innerText = title;
    body.innerText = message;
    this.toast.show();
  }
  addHTML(index, value, targetName, dataRandomizerName, quantity) {
    // _infomation.html.erbよりレアリティリストの内容から抽出。
    let html = `
      <span class="input-group-text" data-info-target="` + targetName + `" data-value=` + index + `>` + this.realityTranslationTargets[index].innerText + `</span>
      <input type="number" class="form-control" data-default-value=` + value + ` value=` + value + ` name="pick-` + index + `" data-randomizer-target="` + dataRandomizerName + `" data-reality=` + index + `>
      <span class="input-group-text">`+ quantity + `</span>
    `;
    const addhtml = document.createElement("div");
    const addhtml2 = document.createElement("div");
    addhtml.setAttribute("class", "input-group col")
    addhtml2.setAttribute("class", "row mw-100");
    addhtml.innerHTML = html;
    addhtml2.appendChild(addhtml)
    switch (dataRandomizerName) {
      case "realityFrame":
        this.realityListTarget.appendChild(addhtml2);
        break;
      case "pickupFrame":
        this.pickupListTarget.appendChild(addhtml2);
        break;
      case "valueFrame":
        this.valueListTarget.appendChild(addhtml2);
        break;
      default:
        throw new Error("info Error:不正なAddが行われました。")
    }
    this.toast.hide();
    this.modal.hide();
  }
}
