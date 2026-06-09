import { Controller } from "@hotwired/stimulus"

// Fait disparaître l'élément (fondu) après un délai (5 s par défaut).
// La croix de fermeture reste utilisable pour le retirer plus tôt.
export default class extends Controller {
  static values = { delay: { type: Number, default: 5000 } }

  connect() {
    this.timeout = setTimeout(() => {
      this.element.classList.remove("show")
      this.element.addEventListener("transitionend", () => this.element.remove(), { once: true })
    }, this.delayValue)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
