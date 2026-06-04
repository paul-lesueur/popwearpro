import { Controller } from "@hotwired/stimulus"

// Section "Client" du formulaire commande :
// - recherche filtrante (nom / email / téléphone -> liste filtrée -> clic = sélection) ;
// - case "Client anonyme" qui désactive/vide la recherche et masque "Ajouter un client".
//
// Note : on masque le menu/options avec la classe .d-none (et non l'attribut hidden),
// car Bootstrap force `display` sur .list-group / .list-group-item, ce qui écraserait [hidden].
export default class extends Controller {
  static targets = ["search", "hidden", "list", "option", "empty", "checkbox", "hint", "addButton"]

  connect() {
    // Ré-affichage après erreur : si un client est déjà choisi, on remet son nom dans le champ.
    const selected = this.optionTargets.find((o) => o.dataset.id === this.hiddenTarget.value)
    if (selected) this.searchTarget.value = selected.dataset.name
  }

  open() {
    if (!this.searchTarget.disabled) this.listTarget.classList.remove("d-none")
  }

  filter() {
    const query = this.searchTarget.value.trim().toLowerCase()
    let visible = 0

    this.optionTargets.forEach((option) => {
      // On filtre sur nom + email + téléphone (data-search), pas seulement le nom.
      const haystack = option.dataset.search || option.dataset.name.toLowerCase()
      const match = haystack.includes(query)
      option.classList.toggle("d-none", !match)
      if (match) visible += 1
    })

    if (this.hasEmptyTarget) this.emptyTarget.classList.toggle("d-none", visible > 0)
    this.listTarget.classList.remove("d-none")
    // Tant que l'utilisateur tape, l'ancienne sélection n'est plus valide.
    this.hiddenTarget.value = ""
  }

  select(event) {
    const option = event.currentTarget
    this.hiddenTarget.value = option.dataset.id
    this.searchTarget.value = option.dataset.name
    this.listTarget.classList.add("d-none")
  }

  closeOnOutside(event) {
    if (!this.element.contains(event.target)) this.listTarget.classList.add("d-none")
  }

  toggle() {
    const anonymous = this.checkboxTarget.checked
    this.searchTarget.disabled = anonymous

    if (anonymous) {
      this.searchTarget.value = ""
      this.hiddenTarget.value = ""
      this.listTarget.classList.add("d-none")
    }

    if (this.hasHintTarget) this.hintTarget.hidden = !anonymous
    // "Ajouter un nouveau client" n'a pas de sens pour une vente anonyme.
    if (this.hasAddButtonTarget) this.addButtonTarget.hidden = anonymous
  }
}
