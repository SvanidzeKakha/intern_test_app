import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets=["checkbox", "button"]
  
  toggle(){
    const AnyChecked = this.checkboxTargets.some(cb => cb.checked)
    this.buttonTarget.disabled = !AnyChecked
  }

  download(){
    const SelectedIDs = this.checkboxTargets
      .filter(cb => cb.checked)
      .map(cb => cb.value)
    
    if (SelectedIDs.length === 0) return

    const query = SelectedIDs.map(id => `user_ids[]=${id}`).join("&")
    window.location = `/users/download_csv?${query}`
  }
}