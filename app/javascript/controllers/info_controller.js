import { Controller } from "@hotwired/stimulus"
import { Toast } from "bootstrap"

// Connects to data-controller="info"
export default class extends Controller {
  static targets = ["infoModal", "toast", "toastTitle", "toastMessage", "selectReality", "selectedReality", "value", "realityTranslation", "realityList"];
  connect() {
    this.modal = new bootstrap.Modal(this.infoModalTarget);
    this.toast = new Toast(this.toastTarget);
  }
  addRealityPick() {
    this.modal.show();
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
  viewToast(message, title = "Warning") {
    this.toastMessageTarget.innerText = message;
    this.toastTitleTarget.innerText = title;
    this.toast.show();
  }
  addRealityHTML(index, value) {
    // _infomation.html.erbよりレアリティリストの内容から抽出。
    let html = `
      <span class="input-group-text" data-info-target="selectedReality" data-value=` + index + `>` + this.realityTranslationTargets[index].innerText + `</span>
      <input type="number" class="form-control" value=` + value + ` step="0.1" name="reality-` + index + `" data-randomizer-target="realityPickRate">
      <span class="input-group-text">%</span>
    `
    const addhtml = document.createElement("div");
    addhtml.setAttribute("class", "input-group")
    addhtml.innerHTML = html;
    this.realityListTarget.appendChild(addhtml);
  }
}
