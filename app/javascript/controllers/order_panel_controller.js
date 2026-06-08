import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  connect() {
    const orderId = this.element.dataset.openOrder
    if (!orderId) return
    const link = this.element.querySelector(`[data-order-id="${orderId}"] a[data-turbo-frame="order-detail"]`)
    if (link) link.click()
  }

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
