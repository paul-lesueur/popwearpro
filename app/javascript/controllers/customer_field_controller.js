import { Controller } from "@hotwired/stimulus"

// Section "Client" du formulaire commande :
// - recherche filtrante (on tape un nom -> liste filtrée -> clic = sélection) ;
// - case "Client anonyme" qui désactive/vide la recherche et masque "Ajouter un client".
export default class extends Controller {
  static targets = ["search", "hidden", "list", "option", "empty", "checkbox", "hint", "addButton"]

  connect() {
    // Ré-affichage après erreur : si un client est déjà choisi, on remet son nom dans le champ.
    const selected = this.optionTargets.find((o) => o.dataset.id === this.hiddenTarget.value)
    if (selected) this.searchTarget.value = selected.dataset.name
  }

  open() {
    if (!this.searchTarget.disabled) this.listTarget.hidden = false
  }

  filter() {
    const query = this.searchTarget.value.trim().toLowerCase()
    let visible = 0

    this.optionTargets.forEach((option) => {
      const match = option.dataset.name.toLowerCase().includes(query)
      option.hidden = !match
      if (match) visible += 1
    })

    if (this.hasEmptyTarget) this.emptyTarget.hidden = visible > 0
    this.listTarget.hidden = false
    // Tant que l'utilisateur tape, l'ancienne sélection n'est plus valide.
    this.hiddenTarget.value = ""
  }

  select(event) {
    const option = event.currentTarget
    this.hiddenTarget.value = option.dataset.id
    this.searchTarget.value = option.dataset.name
    this.listTarget.hidden = true
  }

  closeOnOutside(event) {
    if (!this.element.contains(event.target)) this.listTarget.hidden = true
  }

  toggle() {
    const anonymous = this.checkboxTarget.checked
    this.searchTarget.disabled = anonymous

    if (anonymous) {
      this.searchTarget.value = ""
      this.hiddenTarget.value = ""
      this.listTarget.hidden = true
    }

    if (this.hasHintTarget) this.hintTarget.hidden = !anonymous
    // "Ajouter un nouveau client" n'a pas de sens pour une vente anonyme.
    if (this.hasAddButtonTarget) this.addButtonTarget.hidden = anonymous
  }
}
