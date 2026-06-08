import "@hotwired/turbo-rails"
import * as bootstrap from "bootstrap"
import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application
window.bootstrap = bootstrap

export { application }
