import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  open() {
    this.element.classList.add("orders-kanban--with-panel")
    this.panelTarget.classList.add("is-open")
    this.panelTarget.setAttribute("aria-hidden", "false")
  }

  close() {
    this.element.classList.remove("orders-kanban--with-panel")
    this.panelTarget.classList.remove("is-open")
    this.panelTarget.setAttribute("aria-hidden", "true")
  }
}
