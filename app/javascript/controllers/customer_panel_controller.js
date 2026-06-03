import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "panel",
    "row",
    "name",
    "initials",
    "email",
    "emailInDetails",
    "phone",
    "notes",
    "ordersCount",
    "orders",
    "ordersTemplate",
    "editLink",
    "createdAt",
    "lastOrderDate"
  ]

  open(event) {
    const row = event.currentTarget

    this.element.classList.add("customers-page--with-panel")
    this.panelTarget.classList.add("is-open")
    this.panelTarget.setAttribute("aria-hidden", "false")

    this.rowTargets.forEach((target) => {
      target.classList.remove("is-selected")
    })

    row.classList.add("is-selected")

    this.nameTarget.textContent = row.dataset.name || "Client"
    this.initialsTarget.textContent = row.dataset.initials || "CL"
    this.emailTarget.textContent = row.dataset.email || "Email non renseigné"
    this.emailInDetailsTarget.textContent = row.dataset.email || "Email non renseigné"
    this.phoneTarget.textContent = row.dataset.phone || "Téléphone non renseigné"
    this.notesTarget.textContent = row.dataset.notes || "Aucune note interne."
    this.ordersCountTarget.textContent = row.dataset.ordersCount || "0"
    this.createdAtTarget.textContent = row.dataset.createdAt || "—"
    this.lastOrderDateTarget.textContent = row.dataset.lastOrderDate || "Aucune commande"
    this.editLinkTarget.href = row.dataset.editUrl || "#"

    const template = this.ordersTemplateTargets.find((item) => {
      return item.dataset.customerId === row.dataset.customerId
    })

    if (template) {
      this.ordersTarget.innerHTML = template.innerHTML
    } else {
      this.ordersTarget.innerHTML = "<p class='customer-panel-empty'>Aucune commande pour ce client.</p>"
    }
  }

  close() {
    this.element.classList.remove("customers-page--with-panel")
    this.panelTarget.classList.remove("is-open")
    this.panelTarget.setAttribute("aria-hidden", "true")

    this.rowTargets.forEach((target) => {
      target.classList.remove("is-selected")
    })
  }
}
