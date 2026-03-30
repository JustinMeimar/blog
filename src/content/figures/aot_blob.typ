#import "@preview/cetz:0.3.4"
#import "lib/diagrams.typ": *

#show: figure-page.with(
  number: 1,
  title: [AOT Baseline Blob],
  description: [The serialized blob contains code, metadata, and RuntimePatch entries for fixup at load time.],
)

#let code-lines = (
  "stp x29, x30, [sp, #-16]!",
  (text: "mov x0, #0x0",          role: "code-highlight"),
  "bl  #BaselineInterp_Init",
  "...",
  (text: "ldr x1, [r13, #0x18]",  role: "code-highlight"),
  "...",
  (text: "ldr x3, [r13, #0x100]", role: "code-highlight"),
  "br  x3",
  "...",
  (text: "mov x2, #0x0",          role: "code-highlight"),
  "str x2, [x0, #0x28]",
  "...",
)

#let meta-data = ("interpretOffset, endOffset,", "profilerEnterOffset, ...")

#let d1 = ("kind: DispatchTablePatch", "targetOffset: 0x44", "handlerOffset: JSOP_ADD")
#let d2 = ("kind: DispatchTablePatch", "targetOffset: 0x1A0", "handlerOffset: JSOP_SUB")
#let d3 = ("kind: JSContextPatch", "targetOffset: 0x20")

#let code-header = [AOT Baseline #text(weight: "regular", size: 8.5pt, [(`.text`)])]

#let card-role = (fill: luma(245), stroke: 0.5pt, text-size: 8.5pt, text-weight: "regular", font-key: "mono")

#context {
  let code-w = calc.max(
    auto-listing-width(code-lines, header: code-header),
    auto-grid-widths(((role: "cell-alt"),), meta-data.map(item => (item,)), header: [Baseline Metadata]).at(0).width,
  )
  let all-patch-data = d1 + d2 + d3
  let patch-cols = auto-grid-widths(((role: "cell-alt"),), all-patch-data.map(item => (item,)), header: [RuntimePatch])
  let patch-w = patch-cols.at(0).width
  let rh = default-style.geometry.row-height
  let card-gap = 0.35

  let blob-geo = listing-geo((0, 0), code-w, code-lines.len(), header: code-header)
  let meta-top = blob-geo.bottom-y - card-gap

  let meta-cols = ((width: code-w, default-role: card-role),)
  let meta-rows = meta-data.map(item => (item,))

  let patch-draw-cols = ((width: patch-w, default-role: card-role),)
  let patch-x = code-w + 1.0

  let d1-rows = d1.map(item => (item,))
  let d2-rows = d2.map(item => (item,))
  let d3-rows = d3.map(item => (item,))

  let h1 = grid-geo((0, 0), patch-draw-cols, d1.len(), header: [RuntimePatch]).height
  let h2 = grid-geo((0, 0), patch-draw-cols, d2.len(), header: [RuntimePatch]).height
  let h3 = grid-geo((0, 0), patch-draw-cols, d3.len(), header: [RuntimePatch]).height

  cetz.canvas({
    import cetz.draw: *

    code-listing((0, 0), code-w, code-lines, header: code-header)

    cell-grid((0, meta-top), meta-cols, meta-rows, header: [Baseline Metadata])

    let card-y = 0
    cell-grid((patch-x, card-y), patch-draw-cols, d1-rows, header: [RuntimePatch])
    let card-y = card-y - h1 - card-gap

    cell-grid((patch-x, card-y), patch-draw-cols, d2-rows, header: [RuntimePatch])
    let card-y = card-y - h2 - card-gap

    cell-grid((patch-x, card-y), patch-draw-cols, d3-rows, header: [RuntimePatch])
    let card-y = card-y - h3 - card-gap

    content((patch-x + patch-w / 2, card-y - 0.15),
      text(size: default-style.roles.label.text-size, [#sym.dots.v]))

    let patch-tops = (0, -h1 - card-gap, -h1 - card-gap - h2 - card-gap)
    let patch-mids = patch-tops.map(y => y - rh / 2)

    connector(
      (patch-x, patch-mids.at(0)),
      (patch-x - 0.4, patch-mids.at(0)),
      (patch-x - 0.4, (blob-geo.line-y)(6)),
      (code-w, (blob-geo.line-y)(6)),
      dash: "dotted",
    )

    connector(
      (patch-x, patch-mids.at(1)),
      (patch-x - 0.7, patch-mids.at(1)),
      (patch-x - 0.7, (blob-geo.line-y)(9)),
      (code-w, (blob-geo.line-y)(9)),
      dash: "dotted",
    )
  })
}
