const CANVAS_SIZE = 400
const CROP_RADIUS = 120
const CX = CANVAS_SIZE / 2
const CY = CANVAS_SIZE / 2

export const AvatarCropper = {
  mounted() {
    this.img = null
    this.scale = 1
    this.offsetX = 0
    this.offsetY = 0
    this.dragging = false
    this.resizing = false
    this.lastX = 0
    this.lastY = 0

    const canvas = this.el.querySelector("#avatar-canvas")
    this.ctx = canvas.getContext("2d")
    this.handleSE = this.el.querySelector("#avatar-handle-se")

    const form = this.el.querySelector("#avatar_form")
    form.addEventListener("submit", (e) => {
      if (!this.img) { e.preventDefault(); return }
      const { img, scale, offsetX, offsetY } = this
      const cropX = (CX - CROP_RADIUS - offsetX) / scale
      const cropY = (CY - CROP_RADIUS - offsetY) / scale
      const cropSize = 2 * CROP_RADIUS / scale
      const offscreen = document.createElement("canvas")
      offscreen.width = 128
      offscreen.height = 128
      offscreen.getContext("2d").drawImage(img, cropX, cropY, cropSize, cropSize, 0, 0, 128, 128)
      this.el.querySelector("#avatar-data").value = offscreen.toDataURL("image/webp")
    })

    const input = this.el.querySelector("input[type=file]")

    input.addEventListener("change", (e) => {
      const file = e.target.files[0]
      if (!file) return
      const reader = new FileReader()
      reader.onload = (ev) => {
        const img = new Image()
        img.onload = () => {
          this.img = img
          const minScale = Math.max(2 * CROP_RADIUS / img.width, 2 * CROP_RADIUS / img.height)
          this.scale = minScale
          this.offsetX = (CANVAS_SIZE - img.width * this.scale) / 2
          this.offsetY = (CANVAS_SIZE - img.height * this.scale) / 2
          canvas.style.display = "block"
          this.handleSE.style.display = "block"
          this.redraw()
        }
        img.src = ev.target.result
      }
      reader.readAsDataURL(file)
    })

    // Pan — pointer events (covers mouse, touch, and stylus)
    canvas.addEventListener("pointerdown", (e) => {
      this.dragging = true
      this.lastX = e.clientX
      this.lastY = e.clientY
      canvas.style.cursor = "grabbing"
      canvas.setPointerCapture(e.pointerId)
    })
    canvas.addEventListener("pointermove", (e) => {
      if (!this.dragging || !this.img) return
      this.offsetX += e.clientX - this.lastX
      this.offsetY += e.clientY - this.lastY
      this.lastX = e.clientX
      this.lastY = e.clientY
      this.clamp()
      this.redraw()
    })
    canvas.addEventListener("pointerup", () => {
      this.dragging = false
      canvas.style.cursor = "grab"
    })
    canvas.addEventListener("pointercancel", () => {
      this.dragging = false
      canvas.style.cursor = "grab"
    })

    // Resize — SE handle; NW corner stays fixed (offsetX/offsetY unchanged).
    // Scale is derived from total drag distance since pointerdown so the SE corner
    // tracks the pointer 1:1 rather than compounding per-event deltas.
    this.handleSE.addEventListener("pointerdown", (e) => {
      this.resizing = true
      this.resizeStartX = e.clientX
      this.resizeStartY = e.clientY
      this.scaleAtResizeStart = this.scale
      this.handleSE.setPointerCapture(e.pointerId)
    })
    this.handleSE.addEventListener("pointermove", (e) => {
      if (!this.resizing || !this.img) return
      const totalDx = e.clientX - this.resizeStartX
      const totalDy = e.clientY - this.resizeStartY
      // Average X and Y contributions for proportional scaling
      const newScaleX = this.scaleAtResizeStart + totalDx / this.img.width
      const newScaleY = this.scaleAtResizeStart + totalDy / this.img.height
      const minScale = Math.max(2 * CROP_RADIUS / this.img.width, 2 * CROP_RADIUS / this.img.height)
      this.scale = Math.max(minScale, (newScaleX + newScaleY) / 2)
      this.clamp()
      this.redraw()
    })
    this.handleSE.addEventListener("pointerup", () => { this.resizing = false })
    this.handleSE.addEventListener("pointercancel", () => { this.resizing = false })
  },

  clamp() {
    const imgW = this.img.width * this.scale
    const imgH = this.img.height * this.scale
    // Image must always cover the crop circle
    this.offsetX = Math.min(CX - CROP_RADIUS, Math.max(CX + CROP_RADIUS - imgW, this.offsetX))
    this.offsetY = Math.min(CY - CROP_RADIUS, Math.max(CY + CROP_RADIUS - imgH, this.offsetY))
  },

  redraw() {
    const { ctx, img, scale, offsetX, offsetY } = this
    const imgW = img.width * scale
    const imgH = img.height * scale

    ctx.clearRect(0, 0, CANVAS_SIZE, CANVAS_SIZE)
    ctx.drawImage(img, offsetX, offsetY, imgW, imgH)

    // Dim the image outside the crop circle using even-odd fill rule
    ctx.fillStyle = "rgba(0, 0, 0, 0.5)"
    ctx.beginPath()
    ctx.rect(offsetX, offsetY, imgW, imgH)
    ctx.arc(CX, CY, CROP_RADIUS, 0, Math.PI * 2)
    ctx.fill("evenodd")

    // Move handle to SE image corner
    this.handleSE.style.left = (offsetX + imgW - 7) + "px"
    this.handleSE.style.top = (offsetY + imgH - 7) + "px"
  }
}
