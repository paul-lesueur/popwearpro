import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  dragstart(event) {
    event.dataTransfer.setData("text/plain", event.currentTarget.dataset.orderId)
    event.currentTarget.classList.add("opacity-50")
  }

  dragend(event) {
    event.currentTarget.classList.remove("opacity-50")
  }

  dragover(event) {
    event.preventDefault()
    event.currentTarget.classList.add("kanban-column--over")
  }

  dragleave(event) {
    if (!event.currentTarget.contains(event.relatedTarget)) {
      event.currentTarget.classList.remove("kanban-column--over")
    }
  }

  async drop(event) {
    event.preventDefault()
    event.currentTarget.classList.remove("kanban-column--over")

    const orderId = event.dataTransfer.getData("text/plain")
    const status = event.currentTarget.dataset.status

    await fetch(`/orders/${orderId}/move`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ status })
    })

    Turbo.visit(window.location.href)
  }
}
