import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  dragstart(event) {
    event.dataTransfer.setData("text/plain", event.currentTarget.dataset.orderId)
    event.currentTarget.classList.add("opacity-50", "kanban-card--dragging")
  }

  dragend(event) {
    event.currentTarget.classList.remove("opacity-50", "kanban-card--dragging")
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
    const card = document.querySelector(`[data-order-id="${orderId}"]`)
    const phone = card?.dataset.phone
    const customerName = card?.dataset.customerName
    const fromStatus = card?.dataset.status
    const paymentStatus = card?.dataset.paymentStatus

    await fetch(`/orders/${orderId}/move`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ status })
    })

    if (status === "sent" && phone) {
      this.#showSmsConfirmation(orderId, phone, customerName)
    } else {
      if (status === "completed" && fromStatus === "sent" && paymentStatus !== "paid") {
        this.#showPaymentToast(orderId)
      }
      Turbo.visit(window.location.href)
    }
  }

  #showSmsConfirmation(orderId, phone, customerName) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content

    let container = document.querySelector(".sms-toast-container")
    if (!container) {
      container = document.createElement("div")
      container.className = "sms-toast-container"
      document.body.appendChild(container)
    }

    const toast = document.createElement("div")
    toast.className = "sms-toast"
    toast.innerHTML = `
      <div class="sms-toast__accent"></div>
      <div class="sms-toast__body">
        <p class="sms-toast__title">Envoyer un SMS à ${customerName} ?</p>
        <p class="sms-toast__phone">${phone}</p>
        <div class="sms-toast__actions">
          <button class="btn btn-sm btn-primary" data-role="confirm">Envoyer le SMS</button>
          <button class="btn btn-sm btn-outline-secondary" data-role="dismiss">Ignorer</button>
        </div>
      </div>
    `

    container.appendChild(toast)
    requestAnimationFrame(() => toast.classList.add("sms-toast--visible"))

    const dismiss = () => {
      toast.classList.remove("sms-toast--visible")
      toast.addEventListener("transitionend", () => {
        toast.remove()
        Turbo.visit(window.location.href)
      }, { once: true })
    }

    toast.querySelector("[data-role='confirm']").addEventListener("click", async () => {
      toast.querySelector("[data-role='confirm']").disabled = true
      toast.querySelector("[data-role='dismiss']").disabled = true
      await fetch(`/orders/${orderId}/communications`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken
        },
        body: JSON.stringify({ channel: "sms" })
      })
      dismiss()
    })

    toast.querySelector("[data-role='dismiss']").addEventListener("click", dismiss)
  }

  #showPaymentToast(orderId) {
    const container = document.getElementById("payment-toast-container")

    const toast = document.createElement("div")
    toast.className = "sms-toast"
    toast.innerHTML = `
      <div class="sms-toast__accent" style="background: #198754;"></div>
      <div class="sms-toast__body">
        <p class="sms-toast__title">Paiement mis à jour</p>
        <p class="sms-toast__phone">La commande CMD-${orderId} a été marquée comme payée.</p>
      </div>
    `

    container.appendChild(toast)
    requestAnimationFrame(() => toast.classList.add("sms-toast--visible"))

    const dismiss = () => {
      toast.classList.remove("sms-toast--visible")
      toast.addEventListener("transitionend", () => toast.remove(), { once: true })
    }

    setTimeout(dismiss, 4000)
  }
}
