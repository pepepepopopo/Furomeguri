import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  connect() {
    const options = {
      draggable: "turbo-frame",
      handle: ".drag-handle",
      animation: 500,
      onEnd: this.onEnd.bind(this)
    }

    Sortable.create(this.element, options)
  }

  onEnd(evt) {
    const items = this.element.querySelectorAll('turbo-frame')
    items.forEach((item, index) => {
      const hiddenField = item.querySelector('.row-order-field')
      if (hiddenField) {
        hiddenField.value = index
      }
    })
  }
}