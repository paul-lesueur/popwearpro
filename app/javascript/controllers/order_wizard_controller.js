import { Controller } from "@hotwired/stimulus"
import { formatMoney } from "../utils/money"

// Parcours "Créer une commande" en 5 étapes (Client · Prestations · Paiement · Infos · Reçu).
// Gère navigation, panier, totaux live, validation par étape. Une seule soumission à la fin.
export default class extends Controller {
  static targets = [
    "step", "stepperItem", "stepperLine",
    "clientModeInput", "clientPanel", "clientName", "clientNumber",
    "clientSearch", "clientRow", "customerIdInput", "clientEmpty",
    "tile", "lines", "ticketLines", "ticketEmpty", "ticketClear",
    "recapLines", "receiptLines",
    "subtotal", "vat", "ttc", "total",
    "discountInput", "discountBox", "discountToggle", "discountRow", "discountAmount",
    "methodInput", "statusInput", "methodLabel", "statusLabel",
    "receiptSlot", "receiptBox",
    "back", "next", "finalize", "hint",
    "posPageNav", "posPagePrev", "posPageNext", "posPageInfo",
    "payMethodSection",
    "smsReminderInput", "emailConfirmationInput"
  ]

  connect() {
    this.step = 0
    this.maxReached = 0
    this.cart = {}                       // { itemId: qty }
    this.mode = "passage"
    this.method = null
    this.status = null
    this.tilePage = 0
    this.render()
    this.renderTilePage()
  }

  // ---------- Navigation ----------
  showStep(i) {
    this.step = i
    this.maxReached = Math.max(this.maxReached, i)
    this.render()
    window.scrollTo(0, 0)
  }
  next() { if (this.canContinue()) this.showStep(Math.min(4, this.step + 1)) }
  back() { this.showStep(Math.max(0, this.step - 1)) }
  jump(event) {
    const i = parseInt(event.currentTarget.dataset.index, 10)
    if (i <= this.maxReached) this.showStep(i)
  }

  // ---------- Étape 1 : client ----------
  selectMode(event) {
    this.mode = event.currentTarget.dataset.mode
    this.clientModeInputTarget.value = this.mode
    if (this.mode !== "existing") { this.customerIdInputTarget.value = "" }
    this.render()
  }

  filterClients() {
    const q = this.clientSearchTarget.value.trim().toLowerCase()
    let visible = 0
    this.clientRowTargets.forEach((row) => {
      const match = (row.dataset.search || "").includes(q)
      row.classList.toggle("d-none", !match)
      if (match) visible += 1
    })
    if (this.hasClientEmptyTarget) this.clientEmptyTarget.classList.toggle("d-none", visible > 0)
  }

  selectClient(event) {
    const row = event.currentTarget
    this.customerIdInputTarget.value = row.dataset.id
    this.clientRowTargets.forEach((r) => r.classList.toggle("is-on", r === row))
    this.render()
  }

  // ---------- Étape 2 : panier ----------
  addItem(event) {
    const id = event.currentTarget.dataset.itemId
    this.cart[id] = (this.cart[id] || 0) + 1
    this.render()
  }
  decItem(event) {
    const id = event.currentTarget.dataset.itemId
    this.cart[id] = (this.cart[id] || 0) - 1
    if (this.cart[id] <= 0) delete this.cart[id]
    this.render()
  }
  removeItem(event) {
    delete this.cart[event.currentTarget.dataset.itemId]
    this.render()
  }
  clearCart() { this.cart = {}; this.render() }

  get perPage() { return 9 }

  posPagePrev() {
    this.tilePage = Math.max(0, this.tilePage - 1)
    this.renderTilePage()
  }

  posPageNext() {
    const pages = Math.ceil(this.tileTargets.length / this.perPage)
    this.tilePage = Math.min(pages - 1, this.tilePage + 1)
    this.renderTilePage()
  }

  renderTilePage() {
    const total = this.tileTargets.length
    const pages = Math.ceil(total / this.perPage)
    const start = this.tilePage * this.perPage
    const end = start + this.perPage

    this.tileTargets.forEach((t, i) => t.classList.toggle("pospage-hidden", i < start || i >= end))

    if (this.hasPosPageNavTarget) this.posPageNavTarget.classList.toggle("d-none", pages <= 1)
    if (this.hasPosPageInfoTarget) this.posPageInfoTarget.textContent = `${this.tilePage + 1} / ${pages}`
    if (this.hasPosPagePrevTarget) this.posPagePrevTarget.disabled = this.tilePage === 0
    if (this.hasPosPageNextTarget) this.posPageNextTarget.disabled = this.tilePage >= pages - 1
  }

  tileFor(id) { return this.tileTargets.find((t) => t.dataset.itemId === id) }

  // ---------- Étape 3 : paiement ----------
  selectMethod(event) {
    this.method = event.currentTarget.dataset.value
    this.methodInputTarget.value = this.method
    this.markGroup(event.currentTarget, "paytile")
    this.render()
  }
  selectStatus(event) {
    this.status = event.currentTarget.dataset.value           // "paid" | "unpaid"
    this.statusInputTarget.value = this.status
    this.markGroup(event.currentTarget, "statustile")
    if (this.hasPayMethodSectionTarget) {
      const hide = this.status === "unpaid"
      this.payMethodSectionTarget.classList.toggle("d-none", hide)
      if (hide) { this.method = null; this.methodInputTarget.value = "" }
    }
    this.render()
  }
  markGroup(el, klass) {
    this.element.querySelectorAll(`.${klass}`).forEach((b) => b.classList.toggle("is-on", b === el))
  }

  // ---------- Toggles décoratifs (sms / cgv / confirmation) ----------
  toggleSwitch(event) { event.currentTarget.classList.toggle("is-on") }

  // Toggles branchés sur le formulaire : on met à jour le champ caché ("1"/"0").
  toggleSms(event) {
    const on = event.currentTarget.classList.toggle("is-on")
    this.smsReminderInputTarget.value = on ? "1" : "0"
  }

  toggleEmail(event) {
    const on = event.currentTarget.classList.toggle("is-on")
    this.emailConfirmationInputTarget.value = on ? "1" : "0"
  }

  // ---------- Réduction ----------
  showDiscount() {
    this.discountBoxTarget.classList.remove("d-none")
    if (this.hasDiscountToggleTarget) this.discountToggleTarget.classList.add("d-none")
    this.discountInputTarget.focus()
  }
  removeDiscount() {
    this.discountInputTarget.value = ""
    this.discountBoxTarget.classList.add("d-none")
    if (this.hasDiscountToggleTarget) this.discountToggleTarget.classList.remove("d-none")
    this.render()
  }
  discount() {
    return this.hasDiscountInputTarget ? Math.max(0, parseFloat(this.discountInputTarget.value) || 0) : 0
  }

  // ---------- Étape 5 : reçu ----------
  generateReceipt() {
    this.receiptSlotTarget.classList.add("d-none")
    this.receiptBoxTarget.classList.remove("d-none")
  }
  print() { window.print() }

  // ---------- Validation ----------
  canContinue() {
    if (this.step === 0) {
      if (this.mode === "passage") return true
      if (this.mode === "existing") return !!this.customerIdInputTarget.value
      const name = this.element.querySelector("[name='order[new_name]']")
      return name && name.value.trim().length > 1
    }
    if (this.step === 1) return Object.keys(this.cart).length > 0
    if (this.step === 2) return !!this.status && (this.status === "unpaid" || !!this.method)
    return true
  }

  // ---------- Rendu ----------
  render() {
    // étapes visibles
    this.stepTargets.forEach((s, i) => s.classList.toggle("is-active", i === this.step))

    // stepper
    this.stepperItemTargets.forEach((it, i) => {
      it.classList.toggle("is-active", i === this.step)
      it.classList.toggle("is-done", i < this.step)
      it.classList.toggle("is-clickable", i <= this.maxReached && i !== this.step)
      const dot = it.querySelector(".stepper__dot")
      if (dot) dot.innerHTML = i < this.step ? '<i class="fa-solid fa-check"></i>' : (i + 1)
    })
    this.stepperLineTargets.forEach((l, i) => l.classList.toggle("is-done", i < this.step))

    // panneaux client (existing / new)
    this.clientPanelTargets.forEach((p) => p.classList.toggle("d-none", p.dataset.mode !== this.mode))
    this.element.querySelectorAll(".clientopt").forEach((b) => b.classList.toggle("is-on", b.dataset.mode === this.mode))

    // nom du client (récap / reçu)
    this.clientNameTargets.forEach((e) => (e.textContent = this.clientName()))
    this.clientNumberTargets.forEach((e) => (e.textContent = this.clientNumber()))
    this.methodLabelTargets.forEach((e) => (e.textContent = this.method || "—"))
    this.statusLabelTargets.forEach((e) => (e.textContent = this.status === "paid" ? "Payé" : this.status === "unpaid" ? "Au retrait" : "—"))

    // panier : lignes + totaux + champs cachés
    this.renderCart()

    // navigation (boutons dupliqués en haut ET en bas)
    const last = this.step === 4
    const blocked = !this.canContinue()
    this.backTargets.forEach((b) => b.classList.toggle("invisible", this.step === 0))
    this.nextTargets.forEach((b) => {
      b.classList.toggle("d-none", last)
      b.disabled = blocked
    })
    this.finalizeTargets.forEach((b) => b.classList.toggle("d-none", !last))
    if (this.hasHintTarget) {
      let hint = ""
      if (this.step === 1 && !this.canContinue()) hint = "Ajoutez au moins une prestation"
      if (this.step === 2 && !this.canContinue()) hint = "Choisissez le moyen et le statut de paiement"
      this.hintTarget.textContent = hint
      this.hintTarget.classList.toggle("d-none", !hint)
    }
  }

  renderCart() {
    const ids = Object.keys(this.cart)
    let ht = 0
    const ticketHtml = []
    const linesHtml = []
    const recapHtml = []
    const receiptHtml = []

    ids.forEach((id, idx) => {
      const tile = this.tileFor(id)
      if (!tile) return
      const qty = this.cart[id]
      const price = parseFloat(tile.dataset.priceHt) || 0
      const name = tile.dataset.name
      const icon = tile.dataset.icon || ""
      ht += price * qty

      recapHtml.push(`
        <div class="recap__line">
          <span class="recap__line-name"><span class="catalog-icon-halo" style="width:34px;height:34px">${icon}</span><span>${qty}× ${name}</span></span>
          <span style="font-weight:600">${formatMoney(price * qty)}</span>
        </div>`)

      receiptHtml.push(`
        <div class="receipt__row"><span><span class="receipt__qty">${qty}×</span> ${name}</span><span>${formatMoney(price * qty)}</span></div>`)

      ticketHtml.push(`
        <div class="ticket__line">
          <span class="catalog-icon-halo" style="width:34px;height:34px">${icon}</span>
          <div style="flex:1;min-width:0">
            <div class="ticket__line-name">${name}</div>
            <div class="ticket__line-unit">${formatMoney(price)} · ${formatMoney(price * qty)}</div>
          </div>
          <div class="qtyctl">
            <button type="button" data-item-id="${id}" data-action="order-wizard#decItem" aria-label="Retirer un"><i class="fa-solid fa-minus"></i></button>
            <span>${qty}</span>
            <button type="button" data-item-id="${id}" data-action="order-wizard#addItem" aria-label="Ajouter un"><i class="fa-solid fa-plus"></i></button>
          </div>
          <button type="button" class="ticket__del" data-item-id="${id}" data-action="order-wizard#removeItem" aria-label="Supprimer"><i class="fa-solid fa-trash"></i></button>
        </div>`)

      linesHtml.push(`
        <input type="hidden" name="order[order_lines_attributes][${idx}][item_id]" value="${id}">
        <input type="hidden" name="order[order_lines_attributes][${idx}][quantity]" value="${qty}">`)
    })

    const tva = ht * 0.2
    const ttc = ht + tva
    const discount = Math.min(this.discount(), ttc) // ne dépasse pas le total
    const totalDue = ttc - discount

    // ticket lines
    if (this.hasTicketLinesTarget) this.ticketLinesTarget.innerHTML = ticketHtml.join("")
    if (this.hasTicketEmptyTarget) this.ticketEmptyTarget.classList.toggle("d-none", ids.length > 0)
    if (this.hasTicketClearTarget) this.ticketClearTarget.classList.toggle("d-none", ids.length === 0)

    // hidden order_lines
    if (this.hasLinesTarget) this.linesTarget.innerHTML = linesHtml.join("")
    // récap + reçu
    this.recapLinesTargets.forEach((e) => (e.innerHTML = recapHtml.join("")))
    this.receiptLinesTargets.forEach((e) => (e.innerHTML = receiptHtml.join("")))

    // totaux (plusieurs emplacements possibles via les targets)
    this.subtotalTargets.forEach((e) => (e.textContent = formatMoney(ht)))
    this.vatTargets.forEach((e) => (e.textContent = formatMoney(tva)))
    this.ttcTargets.forEach((e) => (e.textContent = formatMoney(ttc)))
    this.totalTargets.forEach((e) => (e.textContent = formatMoney(totalDue)))

    // ligne réduction (panier / récap / reçu)
    this.discountRowTargets.forEach((row) => row.classList.toggle("d-none", discount <= 0))
    this.discountAmountTargets.forEach((e) => (e.textContent = `− ${formatMoney(discount)}`))

    // bouton "Continuer · total" (étape panier) — sur tous les boutons Continuer
    const showAmount = this.step === 1 && ids.length > 0
    this.nextTargets.forEach((b) => {
      const amount = b.querySelector("[data-amount]")
      if (amount) amount.textContent = showAmount ? ` · ${formatMoney(totalDue)}` : ""
    })
    this.element.querySelectorAll("[data-total-amount]").forEach((e) => (e.textContent = formatMoney(totalDue)))
  }

  get selectedClientRow() {
    return this.clientRowTargets.find((r) => r.dataset.id === this.customerIdInputTarget.value)
  }

  clientName() {
    if (this.mode === "passage") return "Client de passage"
    if (this.mode === "existing") return this.selectedClientRow?.dataset.name ?? "—"
    const name = this.element.querySelector("[name='order[new_name]']")
    return (name && name.value.trim()) || "Nouveau client"
  }

  // Sous le nom dans le récap : n° client pour un client existant, sinon le type.
  clientNumber() {
    if (this.mode === "existing" && this.customerIdInputTarget.value) {
      return `Client #${this.customerIdInputTarget.value}`
    }
    if (this.mode === "new") return "Nouveau client"
    return "Client de passage"
  }
}

