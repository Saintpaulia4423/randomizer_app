import { Controller } from "@hotwired/stimulus"
import { Toast } from "bootstrap"

// Connects to data-controller="info"
export default class extends Controller {
  static targets = ["infoModal", "selectReality", "selectedReality", "value", "realityTranslation", "realityList", "pickupList", "selectedPickup"];
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
  add() {
    switch (this.switch) {
      case "reality":
        this.addReality();
        break;
      case "pickup":
        this.addPickup();
        break;
      default:
        console.error("info_controller: not set switch");
    }
    this.switch = "";
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
      this.addRealityHTML(this.selectRealityTarget.value, this.valueTarget.value);
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
      this.addPickupHTML(this.selectRealityTarget.value, this.valueTarget.value);
  }
  viewToast(message, title = "Warning") {
    const header = document.getElementById("toastHeader");
    const body = document.getElementById("toastBody");

    header.innerText = title;
    body.innerText = message;
    this.toast.show();
  }
  addRealityHTML(index, value) {
    // _infomation.html.erbよりレアリティリストの内容から抽出。
    let html = `
      <span class="input-group-text" data-info-target="selectedReality" data-value=` + index + `>` + this.realityTranslationTargets[index].innerText + `</span>
      <input type="number" class="form-control" value=` + value + ` step="0.1" name="reality-` + index + `" data-randomizer-target="realityPickRate" data-reality=` + index + `>
      <span class="input-group-text">%</span>
    `
    const addhtml = document.createElement("div");
    addhtml.setAttribute("class", "input-group")
    addhtml.innerHTML = html;
    this.realityListTarget.appendChild(addhtml);
    this.toast.hide();
    this.modal.hide();
  }
  addPickupHTML(index, value) {
    // _infomation.html.erbよりレアリティリストの内容から抽出。
    let html = `
      <span class="input-group-text" data-info-target="selectedPickup" data-value=` + index + `>` + this.realityTranslationTargets[index].innerText + `</span>
      <input type="number" class="form-control" value=` + value + ` name="pick-` + index + `" data-randomizer-target="pickUpRate" data-reality=` + index + `>
      <span class="input-group-text">%</span>
    `
    const addhtml = document.createElement("div");
    addhtml.setAttribute("class", "input-group")
    addhtml.innerHTML = html;
    this.pickupListTarget.appendChild(addhtml);
    this.toast.hide();
    this.modal.hide();
  }
}
