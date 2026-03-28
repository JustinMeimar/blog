#import "@preview/cetz:0.3.4"

#set page(width: auto, height: auto, margin: 1.5em)
#set text(font: "New Computer Modern Mono", size: 8pt)

#cetz.canvas({
  import cetz.draw: *

  let row-h = 0.6
  let light-fill = luma(245)
  let med-fill = luma(225)
  let dark-fill = luma(200)
  let stroke-w = 0.5pt
  let line-h = 0.55

  // ── Layout constants ───────────────────────────────────
  let reg-y = 0
  let tab-y = -2.0
  let blob-x = 8.5
  let blob-w = 7.5

  // ── Registers ──────────────────────────────────────────
  let reg-x = 0
  let reg-w = 4.5

  content((reg-w / 2, reg-y + 0.8), text(weight: "bold", size: 10pt, [Registers]))

  rect((reg-x, reg-y), (reg-x + 1.0, reg-y - row-h), stroke: stroke-w, fill: med-fill)
  content((reg-x + 0.5, reg-y - row-h / 2), text(size: 7.5pt, [r13]))

  rect((reg-x + 1.0, reg-y), (reg-x + reg-w, reg-y - row-h), stroke: stroke-w, fill: light-fill)
  content((reg-x + 1.0 + (reg-w - 1.0) / 2, reg-y - row-h / 2), text(size: 7.5pt, [`&AOTIndirectionTable`]))


  // ── AOT Indirection Table ──────────────────────────────
  let tab-x = 0
  let off-w = 1.1
  let field-w = 3.4
  let tab-w = off-w + field-w

  let table-entries = (
    (off: "[0x00]", field: "JSContext*"),
    (off: "[0x08]", field: "JitRuntime*"),
    (off: "[0x10]", field: "Realm*"),
    (off: "[0x18]", field: "wellKnownSymbols"),
    (off: "[0x20]", field: "profilerFlags"),
    (off: "[0x28]", field: "gcWriteBarrier"),
    (off: "...",    field: "..."),
    (off: "[0x100]", field: "dispatch[JSOP_ADD]"),
    (off: "[0x108]", field: "dispatch[JSOP_SUB]"),
    (off: "[0x110]", field: "dispatch[JSOP_MUL]"),
    (off: "...",     field: "..."),
  )

  for (i, entry) in table-entries.enumerate() {
    let y = tab-y - i * row-h

    rect((tab-x, y), (tab-x + off-w, y - row-h), stroke: stroke-w, fill: med-fill)
    content((tab-x + off-w / 2, y - row-h / 2), text(size: 6.5pt, raw(entry.off)))

    rect((tab-x + off-w, y), (tab-x + tab-w, y - row-h), stroke: stroke-w, fill: light-fill)
    content((tab-x + off-w + field-w / 2, y - row-h / 2), text(size: 7.5pt, raw(entry.field)))
  }

  let tab-bottom = tab-y - table-entries.len() * row-h

  // label below the table
  content((tab-w / 2, tab-bottom - 0.5), text(weight: "bold", size: 10pt, [AOTIndirectionTable #text(weight: "regular", size: 8pt, [(`.data`)])]))

  // arrow from r13 register to top of table
  line(
    (reg-w / 2, reg-y - row-h),
    (tab-w / 2, tab-y),
    stroke: (paint: black, thickness: 0.8pt, dash: "dashed"),
    mark: (end: ">", fill: black),
  )


  // ── AOT Code Blob ─────────────────────────────────────
  let code-lines = (
    (text: "...",                                          reloc: false),
    (text: "cmp x0, x1",                                  reloc: false),
    (text: "b.ne #handler",                                reloc: false),
    (text: "ldr x0, [r13, #0x00]  ; JSContext*",           reloc: true),
    (text: "str x2, [x0, #0x10]",                          reloc: false),
    (text: "...",                                          reloc: false),
    (text: "ldr x1, [r13, #0x18]  ; wellKnownSymbols",    reloc: true),
    (text: "ldr x1, [x1, #0x40]",                          reloc: false),
    (text: "...",                                          reloc: false),
    (text: "ldr x3, [r13, #0x100] ; dispatch[JSOP_ADD]",  reloc: true),
    (text: "br  x3",                                       reloc: false),
    (text: "...",                                          reloc: false),
    (text: "ldr x0, [r13, #0x08]  ; JitRuntime*",         reloc: true),
    (text: "...",                                          reloc: false),
  )

  let blob-pad = 0.5
  let blob-top = reg-y + 0.2
  let blob-h = code-lines.len() * line-h + 2 * blob-pad
  let blob-bottom = blob-top - blob-h

  // title above blob
  content((blob-x + blob-w / 2, blob-top + 0.8), text(weight: "bold", size: 10pt, [AOT Code Blob #text(weight: "regular", size: 8pt, [(`.text`)])]))

  rect(
    (blob-x, blob-top),
    (blob-x + blob-w, blob-bottom),
    stroke: stroke-w,
    fill: light-fill,
  )

  for (i, entry) in code-lines.enumerate() {
    let ly = blob-top - blob-pad - i * line-h

    if entry.reloc {
      rect(
        (blob-x + 0.1, ly + line-h / 2 - 0.04),
        (blob-x + blob-w - 0.1, ly - line-h / 2 + 0.04),
        stroke: none,
        fill: dark-fill,
      )
    }

    content(
      (blob-x + 0.4, ly),
      anchor: "west",
      text(size: 7pt, raw(entry.text)),
    )
  }

  // ── Arrows from relocation sites to table entries ─────
  let dash-style = (paint: black, thickness: 0.6pt, dash: "dotted")

  // y-center of code line i in the blob
  let code-y(i) = blob-top - blob-pad - i * line-h

  // y-center of table row i
  let tab-row-y(i) = tab-y - i * row-h - row-h / 2

  // (code line index, table row index, waypoint-x offset from tab-w)
  let arrows = (
    (code-i: 3,  tab-i: 0, wx: 0.8),
    (code-i: 6,  tab-i: 3, wx: 1.6),
    (code-i: 9,  tab-i: 7, wx: 2.4),
    (code-i: 12, tab-i: 1, wx: 3.2),
  )

  for a in arrows {
    let cy = code-y(a.code-i)
    let ty = tab-row-y(a.tab-i)
    let wx = tab-w + a.wx

    line(
      (blob-x, cy),
      (wx, cy),
      (wx, ty),
      (tab-x + tab-w, ty),
      stroke: dash-style,
      mark: (end: ">", fill: black),
    )
  }
})
