import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Après le reload qui suit l'envoi (ou non) du SMS, on affiche un flash de
  // confirmation. Le flag est consommé : il disparaît donc au refresh suivant.
  connect() {
    const raw = sessionStorage.getItem("smsFlash")
    if (!raw) return
    sessionStorage.removeItem("smsFlash")
    try {
      const { sent, name } = JSON.parse(raw)
      this.#showSmsFlash(sent, name)
    } catch (_) {
      // flag invalide : on ignore
    }
  }

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
      <span class="sms-toast__accent"></span>
      <div class="sms-toast__body">
        <p class="sms-toast__title">Prévenir ${customerName} que sa commande est prête à être retirée ?</p>
        <p class="sms-toast__phone">Un SMS sera envoyé au ${phone}</p>
      </div>
      <div class="sms-toast__actions">
        <button class="btn btn-sm btn-primary" data-role="confirm">Envoyer SMS</button>
        <button class="btn btn-sm btn-outline-secondary" data-role="dismiss">Ne pas envoyer</button>
      </div>
    `

    container.appendChild(toast)
    requestAnimationFrame(() => toast.classList.add("sms-toast--visible"))

    const closeAndReload = () => {
      toast.classList.remove("sms-toast--visible")
      toast.addEventListener("transitionend", () => {
        toast.remove()
        // Reload complet (pas Turbo.visit) : pas de preview en cache qui
        // consommerait le flag avant l'affichage du flash de confirmation.
        window.location.reload()
      }, { once: true })
    }

    toast.querySelector("[data-role='confirm']").addEventListener("click", async () => {
      toast.querySelector("[data-role='confirm']").disabled = true
      toast.querySelector("[data-role='dismiss']").disabled = true
      await fetch(`/orders/${orderId}/communications`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": csrfToken
        },
        body: JSON.stringify({ channel: "sms" })
      })
      sessionStorage.setItem("smsFlash", JSON.stringify({ sent: true, name: customerName }))
      closeAndReload()
    })

    toast.querySelector("[data-role='dismiss']").addEventListener("click", () => {
      sessionStorage.setItem("smsFlash", JSON.stringify({ sent: false, name: customerName }))
      closeAndReload()
    })
  }

  #showSmsFlash(sent, name) {
    // Même emplacement que le toast : sous la barre de recherche, au-dessus du kanban.
    const stack = document.querySelector(".sms-toast-container")
    if (!stack) return

    const message = sent
      ? `SMS « commande prête » envoyé à ${name}.`
      : `SMS « commande prête » non envoyé à ${name}.`

    const card = document.createElement("div")
    card.className = `flash-card flash-card--${sent ? "success" : "info"} alert alert-dismissible fade show`
    card.setAttribute("role", "alert")
    card.innerHTML = `
      <span class="flash-card__accent"></span>
      <div class="flash-card__body">${message}</div>
      <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Fermer"></button>
    `
    stack.appendChild(card)

    // Auto-disparition après ~5 s (la croix permet de fermer avant).
    setTimeout(() => {
      card.classList.remove("show")
      card.addEventListener("transitionend", () => card.remove(), { once: true })
    }, 5000)
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
