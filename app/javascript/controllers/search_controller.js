import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ['searchWrapper']
  static classes = ["hidden"]

  close() {
    this.searchWrapperTarget.classList.add(hiddenClass)
  }
}
