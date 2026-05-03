export const PreserveSize = {
  beforeUpdate() {
    const textarea = this.el.tagName === "TEXTAREA" ? this.el : this.el.querySelector("textarea")
    if (textarea) this._savedHeight = textarea.style.height
  },
  updated() {
    const textarea = this.el.tagName === "TEXTAREA" ? this.el : this.el.querySelector("textarea")
    if (textarea && this._savedHeight) textarea.style.height = this._savedHeight
  }
}
