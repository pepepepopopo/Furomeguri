import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  connect() {
    const options = {
      draggable: "turbo-frame",
      animation: 150,
      ghostClass: 'blue-background-class',
      onEnd: this.onEnd.bind(this)
    }

    const sortableInstance = Sortable.create(this.element, options)
  }

  onEnd(evt) {
    const body = { row_order_position: evt.newIndex }
  }
}