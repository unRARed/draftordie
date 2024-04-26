console.log("loaded modal_controller.js")

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "content" ]

  connect() {
    this.element.remove
  }

  disconnect() {}

  close() {
    document.querySelector(".c-modal").classList.
      remove("c-modal--open")
  }
  open() {
    document.querySelector(".c-modal").classList.
      add("c-modal--open")
  }

  handleKeyup(e) {
    if (e.code == "Escape") {
      this.close()
    }
  }

  // handleSubmit = (e) => {
  //   if (e.detail.success) {
  //     this.close()
  //   }
  // }
}
