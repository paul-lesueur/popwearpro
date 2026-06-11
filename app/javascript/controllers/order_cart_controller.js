import { Controller } from "@hotwired/stimulus"
import { formatMoney } from "../utils/money"

// Panier d'une commande : on clique une carte prestation pour l'ajouter/retirer,
// et les totaux (sous-total HT, TVA, total TTC) se recalculent en direct.
// Chaque carte porte data-item-id / data-price-ht / data-vat-rate.
// Les lignes sélectionnées sont matérialisées par des <input hidden> order_lines_attributes.
export default class extends Controller {
  static targets = ["card", "lines", "subtotal", "vat", "total", "empty"]

  connect() {
    // Édition / ré-affichage après erreur : marquer les cartes déjà dans le panier.
    this.linesTarget.querySelectorAll("[data-item-id]").forEach((line) => {
      const card = this.cardFor(line.dataset.itemId)
      if (card) card.classList.add("is-selected")
    })
    // On démarre les nouveaux index APRÈS les lignes déjà rendues (évite les collisions).
    this.index = this.linesTarget.querySelectorAll("[data-item-id]").length
    this.recalculate()
  }

  toggle(event) {
    const card = event.currentTarget
    const itemId = card.dataset.itemId
    const existing = this.lineFor(itemId)

    if (existing) {
      existing.remove()
      card.classList.remove("is-selected")
    } else {
      this.linesTarget.insertAdjacentHTML("beforeend", this.lineHTML(itemId))
      card.classList.add("is-selected")
    }
    this.recalculate()
  }

  lineHTML(itemId) {
    // Index NUMÉRIQUE obligatoire : Rails ignore les attributs nested aux clés non entières.
    const i = this.index++
    return `<div data-item-id="${itemId}">
      <input type="hidden" name="order[order_lines_attributes][${i}][item_id]" value="${itemId}">
      <input type="hidden" name="order[order_lines_attributes][${i}][quantity]" value="1">
    </div>`
  }

  lineFor(itemId) {
    return this.linesTarget.querySelector(`[data-item-id="${itemId}"]`)
  }

  cardFor(itemId) {
    return this.cardTargets.find((card) => card.dataset.itemId === itemId)
  }

  recalculate() {
    let ht = 0
    let vat = 0

    this.linesTarget.querySelectorAll("[data-item-id]").forEach((line) => {
      const card = this.cardFor(line.dataset.itemId)
      if (!card) return
      const price = parseFloat(card.dataset.priceHt) || 0
      const rate = parseFloat(card.dataset.vatRate) || 0
      ht += price
      vat += (price * rate) / 100
    })

    this.subtotalTarget.textContent = formatMoney(ht)
    this.vatTarget.textContent = formatMoney(vat)
    this.totalTarget.textContent = formatMoney(ht + vat)

    if (this.hasEmptyTarget) {
      this.emptyTarget.classList.toggle("d-none", this.linesTarget.children.length > 0)
    }
  }

}
