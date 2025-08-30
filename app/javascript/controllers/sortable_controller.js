import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  connect() {
    const options = {
      draggable: "turbo-frame",
      handle: ".drag-handle",
      animation: 500,
    }

    Sortable.create(this.element, options)
  }
}