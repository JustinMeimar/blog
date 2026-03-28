#import "@preview/cetz:0.3.4"
#import "lib/diagrams.typ": *

#set page(width: auto, height: auto, margin: 1.5em, fill: none)
#set text(font: default-theme.fonts.mono, size: 8pt)

#let table-entries = (
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

#let code-lines = (
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

#let arrows = (
  (code-i: 3,  tab-i: 0, wx: 0.8),
  (code-i: 6,  tab-i: 3, wx: 1.6),
  (code-i: 9,  tab-i: 7, wx: 2.4),
  (code-i: 12, tab-i: 1, wx: 3.2),
)

#let rh = default-theme.geometry.row-height
#let reg-y = 0
#let tab-header-y = -2.0
#let tab-y = tab-header-y - rh
#let blob-x = 8.5
#let blob-w = 7.5
#let blob-header-y = reg-y + 0.2
#let blob-top = blob-header-y - rh
#let reg-w = 4.5
#let tab-w = 1.1 + 3.4

#let tab-geo = mem-table-geo((0, tab-y), table-entries)
#let blob-geo = code-blob-geo((blob-x, blob-top), blob-w, code-lines)

#cetz.canvas({
  import cetz.draw: *

  register-display((0, reg-y), "r13", "&AOTIndirectionTable", total-w: reg-w)

  // Table header + table
  rect((0, tab-header-y), (tab-w, tab-header-y - rh),
    stroke: default-theme.strokes.weight, fill: default-theme.fills.dark)
  content((tab-w / 2, tab-header-y - rh / 2),
    text(weight: "bold", size: default-theme.sizes.label,
      [AOTIndirectionTable #text(weight: "regular", size: 7pt, [(`.data`)])]))

  mem-table((0, tab-y), table-entries)

  connector(
    (reg-w / 2, reg-y - rh),
    (tab-w / 2, tab-header-y),
    style: "dashed",
  )

  // Code blob header + blob
  rect((blob-x, blob-header-y), (blob-x + blob-w, blob-header-y - rh),
    stroke: default-theme.strokes.weight, fill: default-theme.fills.dark)
  content((blob-x + blob-w / 2, blob-header-y - rh / 2),
    text(weight: "bold", size: default-theme.sizes.label,
      [AOT Code Blob #text(weight: "regular", size: 7pt, [(`.text`)])]))

  code-blob((blob-x, blob-top), blob-w, code-lines)

  for a in arrows {
    let cy = (blob-geo.line-y)(a.code-i)
    let ty = (tab-geo.row-y)(a.tab-i)
    let wx = tab-geo.width + a.wx

    connector(
      (blob-x, cy),
      (wx, cy),
      (wx, ty),
      (tab-geo.width, ty),
    )
  }
})
