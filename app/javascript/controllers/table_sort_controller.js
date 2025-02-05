import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="table-sort"
export default class extends Controller {
  static targets = ["tableHeader"];

  connect() {
    console.log("Table Sort connected")
  }

  sort(event) {
    const header = event.currentTarget;
    const columnIndex = this.tableHeaderTargets.indexOf(header);
    const sortOrder = header.dataset.sortOrder === "asc" ? "desc" : "asc"
    const type = header.dataset.sort;

    this.sortTable(columnIndex, type, sortOrder);
    header.dataset.sortOrder = sortOrder;
  }

  sortTable(columnIndex, type, sortOrder) {
    const table = this.element;
    const rows = Array.from(table.querySelectorAll("tbody tr"));
    const multiplier = sortOrder === "asc" ? 1 : -1;

    rows.sort((a, b) => {
      const cellA = a.children[columnIndex].innerText;
      const cellB = b.children[columnIndex].innerText;

      if (type === 'number') {
        return (parseFloat(cellA) - parseFloat(cellB)) * multiplier;
      } else {
        return cellA.localeCompare(cellB) * multiplier;
      }
    });

    const tbody = table.querySelector("tbody");
    rows.forEach(row => tbody.appendChild(row));
  }
}
