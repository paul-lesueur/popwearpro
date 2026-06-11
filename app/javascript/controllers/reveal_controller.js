import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: Number }

  connect() {
    this.element.classList.add("reveal--hidden")

    this.observer = new IntersectionObserver(([entry]) => {
      if (!entry.isIntersecting) return
      setTimeout(() => {
        this.element.classList.remove("reveal--hidden")
        this.element.classList.add("reveal--visible")
      }, this.delayValue)
      this.observer.disconnect()
    }, { threshold: 0.25 })

    this.observer.observe(this.element)
  }

  disconnect() {
    this.observer?.disconnect()
  }
}
