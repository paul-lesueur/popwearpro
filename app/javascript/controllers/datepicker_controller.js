import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

// Calendrier "Date de retrait" du wizard : Flatpickr habillé à la charte.
// Locale FR définie inline (évite un second pin importmap pour le module l10n).
const French = {
  weekdays: {
    shorthand: ["Dim", "Lun", "Mar", "Mer", "Jeu", "Ven", "Sam"],
    longhand: ["dimanche", "lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi"],
  },
  months: {
    shorthand: ["Janv", "Févr", "Mars", "Avr", "Mai", "Juin", "Juil", "Août", "Sept", "Oct", "Nov", "Déc"],
    longhand: ["janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre"],
  },
  firstDayOfWeek: 1,
  rangeSeparator: " au ",
  weekAbbreviation: "Sem",
  ordinal: () => "",
}

export default class extends Controller {
  connect() {
    this.fp = flatpickr(this.element, {
      locale: French,
      altInput: true,
      altInputClass: "form-control wiz-date__input",
      altFormat: "j F Y",
      dateFormat: "Y-m-d",
      minDate: "today",
      disableMobile: true,
    })

    // Placeholder = date du jour (indicatif, pas une valeur pré-remplie).
    if (this.fp.altInput) {
      this.fp.altInput.placeholder = this.fp.formatDate(new Date(), "j F Y")
    }
  }

  disconnect() {
    if (this.fp) this.fp.destroy()
  }
}
