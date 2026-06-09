import { Controller } from "@hotwired/stimulus"

// Modal générique : ouvre/ferme un volet (.detail-modal, via la target "modal"),
// ferme sur Échap et sur clic du backdrop, et verrouille le scroll du body.
// Le contenu (turbo-frame côté commandes, champs peuplés en JS côté clients)
// est géré par d'autres contrôleurs : celui-ci ne s'occupe que de la mécanique.
export default class extends Controller {
  static targets = ["modal", "autoOpen"]

  connect() {
    this.onKeydown = this.onKeydown.bind(this)
    // Ouverture automatique (ex : ?open=<id> côté commandes).
    if (this.hasAutoOpenTarget) this.autoOpenTarget.click()
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKeydown)
    document.body.classList.remove("detail-modal-open")
  }

  open() {
    this.modalTarget.classList.add("is-open")
    this.modalTarget.setAttribute("aria-hidden", "false")
    document.body.classList.add("detail-modal-open")
    document.addEventListener("keydown", this.onKeydown)
  }

  close() {
    this.modalTarget.classList.remove("is-open")
    this.modalTarget.setAttribute("aria-hidden", "true")
    document.body.classList.remove("detail-modal-open")
    document.removeEventListener("keydown", this.onKeydown)
  }

  // Ferme seulement si le clic vise le backdrop lui-même, pas le contenu.
  backdropClose(event) {
    if (event.target === event.currentTarget) this.close()
  }

  onKeydown(event) {
    if (event.key === "Escape") this.close()
  }
}
