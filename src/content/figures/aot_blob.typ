#import "@preview/cetz:0.3.4"
#import "lib/diagrams.typ": *

#set page(width: auto, height: auto, margin: 1.5em, fill: none)
#set text(font: default-theme.fonts.mono, size: 8pt)

#let code-lines = (
  (text: "stp x29, x30, [sp, #-16]!",  reloc: false),
  (text: "mov x0, #0x0",               reloc: true),
  (text: "bl  #BaselineInterp_Init",    reloc: false),
  (text: "...",                         reloc: false),
  (text: "ldr x1, [r13, #0x18]",       reloc: true),
  (text: "...",                         reloc: false),
  (text: "ldr x3, [r13, #0x100]",      reloc: true),
  (text: "br  x3",                      reloc: false),
  (text: "...",                         reloc: false),
  (text: "mov x2, #0x0",               reloc: true),
  (text: "str x2, [x0, #0x28]",        reloc: false),
  (text: "...",                         reloc: false),
)

#let meta-data = ("interpretOffset, endOffset,", "profilerEnterOffset, ...")

#let rh = default-theme.geometry.row-height
#let frame-pad = 0.6
#let code-x = frame-pad
#let code-w = 8.5
#let card-gap = 0.35

#let header-top = 0
#let code-top = header-top - rh
#let blob-geo = code-blob-geo((code-x, code-top), code-w, code-lines)

#let meta-top = blob-geo.bottom-y - card-gap
#let meta-h = patch-card-height(meta-data)

#let patch-x = code-x + code-w + 1.0
#let patch-w = 5.2

#let left-bottom = meta-top - meta-h
#let frame-w = patch-x + patch-w + frame-pad
#let frame-h = -left-bottom + frame-pad + 0.8

#cetz.canvas({
  import cetz.draw: *

  content((frame-w / 2, 1.4),
    text(weight: "bold", size: default-theme.sizes.title,
      [AOT Baseline Blob, Manifest and Patches]))

  // AOT Baseline header + code
  rect((code-x, header-top), (code-x + code-w, header-top - rh),
    stroke: default-theme.strokes.weight, fill: default-theme.fills.dark)
  content((code-x + code-w / 2, header-top - rh / 2),
    text(weight: "bold", size: default-theme.sizes.label, [AOT Baseline #text(weight: "regular", size: 7pt, [(`.text`)])]))

  code-blob((code-x, code-top), code-w, code-lines)

  // Baseline Metadata card
  patch-card((code-x, meta-top), code-w, [Baseline Metadata], meta-data)

  // Patch cards
  let card-y = header-top

  let d1 = ("kind: DispatchTablePatch", "targetOffset: 0x44", "handlerOffset: JSOP_ADD")
  let h1 = patch-card-height(d1)
  patch-card((patch-x, card-y), patch-w, [RuntimePatch], d1)
  let card-y = card-y - h1 - card-gap

  let d2 = ("kind: DispatchTablePatch", "targetOffset: 0x1A0", "handlerOffset: JSOP_SUB")
  let h2 = patch-card-height(d2)
  patch-card((patch-x, card-y), patch-w, [RuntimePatch], d2)
  let card-y = card-y - h2 - card-gap

  let d3 = ("kind: JSContextPatch", "targetOffset: 0x20")
  let h3 = patch-card-height(d3)
  patch-card((patch-x, card-y), patch-w, [RuntimePatch], d3)
  let card-y = card-y - h3 - card-gap

  content((patch-x + patch-w / 2, card-y - 0.15),
    text(size: default-theme.sizes.label, [#sym.dots.v]))

  // Connectors
  let patch-tops = (header-top, header-top - h1 - card-gap, header-top - h1 - card-gap - h2 - card-gap)
  let patch-mids = patch-tops.map(y => y - rh / 2)

  connector(
    (patch-x, patch-mids.at(0)),
    (patch-x - 0.4, patch-mids.at(0)),
    (patch-x - 0.4, (blob-geo.line-y)(6)),
    (code-x + code-w, (blob-geo.line-y)(6)),
    style: "dotted",
  )

  connector(
    (patch-x, patch-mids.at(1)),
    (patch-x - 0.7, patch-mids.at(1)),
    (patch-x - 0.7, (blob-geo.line-y)(9)),
    (code-x + code-w, (blob-geo.line-y)(9)),
    style: "dotted",
  )
})
