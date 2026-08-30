import { Controller } from "@hotwired/stimulus"

// Flips the interface between the light and the dark palette and remembers the
// choice. With nothing stored, the OS preference decides (see application.css).
export default class extends Controller {
  static STORAGE_KEY = "redmine-theme"

  toggle(event) {
    event.preventDefault()

    const root = document.documentElement
    const current = root.dataset.theme ||
      (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light")
    const next = current === "dark" ? "light" : "dark"

    root.dataset.theme = next
    try {
      localStorage.setItem(this.constructor.STORAGE_KEY, next)
    } catch (e) {
      // Storage can be unavailable (private mode, blocked cookies); the toggle
      // still applies to this page.
    }
  }
}
