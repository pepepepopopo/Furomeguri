import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  connect() {
    const options = {
      draggable: "turbo-frame",
      handle: '.drag-handle',
      animation: 150,
      forceFallback: true,
      fallbackOnBody: true,
      fallbackTolerance: 5,
      onEnd: this.onEnd.bind(this)
    }
    console.log("[sortable] connect on", this.element)
    Sortable.create(this.element, options)
  }

  onEnd(evt) {
    const body = { row_order_position: evt.newIndex }
    console.log(body)
  }
}