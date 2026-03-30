#import "@preview/cetz:0.3.4"
#import "lib/diagrams.typ": *

#show: figure-page.with(
  number: 1,
  title: [AOT Baseline Blob],
  description: [The serialized blob contains code, metadata, and RuntimePatch entries for fixup at load time.],
)

#let code-lines = (
  (offset: "",   text: "; BaselineInterpreterCodeGen::emit_Symbol"),
  (offset: "00", text: "movzbl 0x1(%r14), %ecx"),
  (offset: "04", text: "movabs $0xdeadbeefdeadbeef, %rbx ; wellKnownSymbols"),
  (offset: "0e", text: "movq  (%rbx,%rcx,8), %rcx"),
  (offset: "12", text: "..."),
  (offset: "16", text: "leaq  .Ltable(%rip), %rbx        ; dispatch (PIC)"),
  (offset: "1d", text: "movslq (%rbx,%rcx,4), %rcx        ; rel32 offset"),
  (offset: "21", text: "addq  %rbx, %rcx                  ; base + rel"),
  (offset: "24", text: "jmp   *%rcx"),
)

#let code-regions = (
  (start: 2, end: 2, fill: yellow.lighten(75%)),
)

#let meta-data = ("interpretOffset, endOffset,", "profilerEnterOffset, ...")

#let d1 = ("kind: WellKnownSymbolsPatch", "targetOffset: 0x06")

#let blob-header = [AOT Baseline Interpreter #text(weight: "regular", size: 8.5pt, [(`.text`)])]

#let card-role = (fill: luma(245), stroke: 0.5pt, text-size: 8.5pt, text-weight: "regular", font-key: "mono")

#context {
  let code-w = auto-listing-width(code-lines, header: blob-header)
  let all-data = d1 + meta-data
  let patch-cols = auto-grid-widths(((role: "cell-alt"),), all-data.map(item => (item,)), header: [RuntimePatch])
  let patch-w = patch-cols.at(0).width
  let rh = default-style.geometry.row-height
  let card-gap = 0.35

  let blob-geo = listing-geo((0, 0), code-w, code-lines.len(), header: blob-header)

  let patch-draw-cols = ((width: patch-w, default-role: card-role),)
  let patch-x = code-w + 1.0

  let d1-rows = d1.map(item => (item,))
  let meta-cols = ((width: patch-w, default-role: card-role),)
  let meta-rows = meta-data.map(item => (item,))

  let h1 = grid-geo((0, 0), patch-draw-cols, d1.len(), header: [RuntimePatch]).height

  cetz.canvas({
    import cetz.draw: *

    code-listing((0, 0), code-w, code-lines, header: blob-header, regions: code-regions)

    cell-grid((patch-x, 0), patch-draw-cols, d1-rows, header: [RuntimePatch])

    content((patch-x + patch-w / 2, -h1 - card-gap - 0.15),
      text(size: default-style.roles.label.text-size, [#sym.dots.v]))

    let meta-top = -h1 - card-gap - 0.6
    cell-grid((patch-x, meta-top), meta-cols, meta-rows, header: [Baseline Metadata])

    connector(
      (patch-x, -rh / 2),
      (patch-x - 0.4, -rh / 2),
      (patch-x - 0.4, (blob-geo.line-y)(2)),
      (code-w, (blob-geo.line-y)(2)),
      dash: "dotted",
    )
  })
}
