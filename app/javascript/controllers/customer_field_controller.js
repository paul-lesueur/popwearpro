import { Controller } from "@hotwired/stimulus"

// Section "Client" du formulaire commande : cocher "Client anonyme" désactive et
// vide la sélection du client nommé (la commande sera rattachée à un client anonyme).
export default class extends Controller {
  static targets = ["select", "checkbox", "hint", "addButton"]

  toggle() {
    const anonymous = this.checkboxTarget.checked
    this.selectTarget.disabled = anonymous
    if (anonymous) this.selectTarget.value = ""
    if (this.hasHintTarget) this.hintTarget.hidden = !anonymous
    // "Ajouter un nouveau client" n'a pas de sens pour une vente anonyme.
    if (this.hasAddButtonTarget) this.addButtonTarget.hidden = anonymous
  }
}
