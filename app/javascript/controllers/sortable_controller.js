import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  connect() {

    // 子要素確認
    const draggableElements = this.element.querySelectorAll("turbo-frame")

    const options = {
      draggable: "turbo-frame",
      animation: 150,
      onStart: (evt) => {
        console.log("[sortable] Started dragging:", evt.item)
      },
      onEnd: this.onEnd.bind(this)
    }
    
    console.log("[sortable] Creating Sortable with options:", options)
    const sortableInstance = Sortable.create(this.element, options)
    console.log("[sortable] Sortable instance created:", sortableInstance)
  }

  onEnd(evt) {
    const body = { row_order_position: evt.newIndex }
    console.log("[sortable] Drag ended:", body)
  }
}