import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="table-sort"
export default class extends Controller {
  static targets = ["tableHeader", "checkboxHeader"];

  connect() {
    console.log("Table Sort connected")
  }

  // 基本的な文字ソート
  sort(event) {
    const header = event.currentTarget;
    const columnIndex = this.tableHeaderTargets.indexOf(header);
    const sortOrder = header.dataset.sortOrder === "asc" ? "desc" : "asc"
    const type = header.dataset.sort;

    this.sortTable(columnIndex, type, sortOrder);
    header.dataset.sortOrder = sortOrder;
    this.setSortIcon(header, sortOrder);
  }

  // checkbox用のソート処理
  checkboxSort(event) {
    const header = event.currentTarget;
    const columnIndex = this.tableHeaderTargets.indexOf(header);
    const checkStatus = this.checkboxHeaderTarget;
    let type = header.dataset.sort;

    const sortOrder = checkStatus.checked === true ? "asc" : "decs"

    this.sortTable(columnIndex, type, sortOrder);
  }

  // ソート基部
  sortTable(columnIndex, type, sortOrder) {
    const table = this.element;
    const rows = Array.from(table.querySelectorAll("tbody tr"));
    const multiplier = sortOrder === "asc" ? 1 : -1;

    rows.sort((a, b) => {
      const cellA = a.children[columnIndex];
      const cellB = b.children[columnIndex];

      if (type === 'number') {
        let cell1 = cellA.children[0].dataset.value;
        let cell2 = cellB.children[0].dataset.value;
        return (cell2 - cell1) * multiplier;
      } else if (type === "checkbox") {
        let cell1 = cellA.children[0].checked === true ? 1 : -1;
        let cell2 = cellB.children[0].checked === true ? 1 : -1;
        return (cell1 - cell2) * multiplier;
      } else if (type === "pickup") {
        let cell1 = cellA.children.length;
        let cell2 = cellB.children.length;
        return (cell2 - cell1) * multiplier;
      } else {
        let cell1 = cellA.innerText;
        let cell2 = cellB.innerText;
        return cell1.localeCompare(cell2) * multiplier;
      }
    });

    const tbody = table.querySelector("tbody");
    rows.forEach(row => tbody.appendChild(row));
  }

  // ソート中のアイコンを追加（単一のみ）
  setSortIcon(header, sortOrder) {
    this.tableHeaderTargets.forEach(target => {
      target.classList.remove("asc", "desc");
    })

    header.classList.add(sortOrder);
  }
}
