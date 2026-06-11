import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Après le reload qui suit l'envoi (ou non) du SMS, on affiche un flash de
  // confirmation. Le flag est consommé : il disparaît donc au refresh suivant.
  connect() {
    const raw = sessionStorage.getItem("smsFlash")
    if (!raw) return
    sessionStorage.removeItem("smsFlash")
    try {
      const { variant, message } = JSON.parse(raw)
      this.#showSmsFlash(variant, message)
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
        "X-CSRF-Token": this.#csrfToken
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

  get #csrfToken() {
    return document.querySelector('meta[name="csrf-token"]').content
  }

  #showSmsConfirmation(orderId, phone, customerName) {
    const csrfToken = this.#csrfToken

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

    const confirmBtn = toast.querySelector("[data-role='confirm']")
    const dismissBtn = toast.querySelector("[data-role='dismiss']")

    confirmBtn.addEventListener("click", async () => {
      confirmBtn.disabled = true
      dismissBtn.disabled = true
      // Le serveur renvoie le vrai résultat (envoyé / déjà envoyé / sans téléphone).
      // En cas d'échec réseau, on ne reste pas bloqué : on affiche une erreur.
      let result
      try {
        const response = await fetch(`/orders/${orderId}/communications`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-CSRF-Token": csrfToken
          },
          body: JSON.stringify({ channel: "sms" })
        })
        result = await response.json()
      } catch (_) {
        result = { variant: "error", message: "Échec de l'envoi du SMS. Veuillez réessayer." }
      }
      sessionStorage.setItem("smsFlash", JSON.stringify(result))
      closeAndReload()
    })

    dismissBtn.addEventListener("click", () => {
      sessionStorage.setItem("smsFlash", JSON.stringify({ variant: "info", message: "SMS « commande prête » non envoyé." }))
      closeAndReload()
    })
  }

  #showSmsFlash(variant, message) {
    // Même emplacement que le toast : sous la barre de recherche, au-dessus du kanban.
    const stack = document.querySelector(".sms-toast-container")
    if (!stack) return

    const card = document.createElement("div")
    card.className = `flash-card flash-card--${variant || "info"} alert alert-dismissible fade show`
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
