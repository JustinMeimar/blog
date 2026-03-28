#import "@preview/cetz:0.3.4"
#import "lib/diagrams.typ": *

#show: figure-page.with(
  number: 1,
  title: [AOT Baseline Blob],
  description: [The serialized blob contains code, metadata, and RuntimePatch entries for fixup at load time.],
)

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

#let d1 = ("kind: DispatchTablePatch", "targetOffset: 0x44", "handlerOffset: JSOP_ADD")
#let d2 = ("kind: DispatchTablePatch", "targetOffset: 0x1A0", "handlerOffset: JSOP_SUB")
#let d3 = ("kind: JSContextPatch", "targetOffset: 0x20")

#let code-header = [AOT Baseline #text(weight: "regular", size: default-theme.sizes.offset, [(`.text`)])]

#context {
  let code-w = calc.max(
    auto-code-blob-width(code-lines, header: code-header),
    auto-data-card-width([Baseline Metadata], meta-data),
  )
  let patch-w = auto-data-card-width([RuntimePatch], d1 + d2 + d3)
  let rh = default-theme.geometry.row-height
  let card-gap = 0.35

  let blob-geo = code-blob-geo((0, 0), code-w, code-lines, header: code-header)
  let meta-top = blob-geo.bottom-y - card-gap

  let patch-x = code-w + 1.0
  let h1 = data-card-height(d1)
  let h2 = data-card-height(d2)
  let h3 = data-card-height(d3)

  cetz.canvas({
    import cetz.draw: *

    code-blob((0, 0), code-w, code-lines, header: code-header)

    data-card((0, meta-top), code-w, [Baseline Metadata], meta-data)

    let card-y = 0
    data-card((patch-x, card-y), patch-w, [RuntimePatch], d1)
    let card-y = card-y - h1 - card-gap

    data-card((patch-x, card-y), patch-w, [RuntimePatch], d2)
    let card-y = card-y - h2 - card-gap

    data-card((patch-x, card-y), patch-w, [RuntimePatch], d3)
    let card-y = card-y - h3 - card-gap

    content((patch-x + patch-w / 2, card-y - 0.15),
      text(size: default-theme.sizes.label, [#sym.dots.v]))

    let patch-tops = (0, -h1 - card-gap, -h1 - card-gap - h2 - card-gap)
    let patch-mids = patch-tops.map(y => y - rh / 2)

    connector(
      (patch-x, patch-mids.at(0)),
      (patch-x - 0.4, patch-mids.at(0)),
      (patch-x - 0.4, (blob-geo.line-y)(6)),
      (code-w, (blob-geo.line-y)(6)),
      style: "dotted",
    )

    connector(
      (patch-x, patch-mids.at(1)),
      (patch-x - 0.7, patch-mids.at(1)),
      (patch-x - 0.7, (blob-geo.line-y)(9)),
      (code-w, (blob-geo.line-y)(9)),
      style: "dotted",
    )
  })
}
