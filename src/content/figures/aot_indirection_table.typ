#import "@preview/cetz:0.3.4"
#import "lib/diagrams.typ": *

#show: figure-page.with(
  number: 2,
  title: [AOT Indirection Table],
  description: [Relocation sites in the AOT code blob resolve pointers through indirect loads via a pinned register.],
)

#let table-rows = (
  ("[0x00]",  "JSContext*"),
  ("[0x08]",  "JitRuntime*"),
  ("[0x10]",  "Realm*"),
  ("[0x18]",  "profilerFlags"),
  ("[0x20]",  "gcWriteBarrier"),
  ("[0x28]",  "wellKnownSymbols"),
  ("...",     "..."),
)

#let code-lines = (
  (offset: "",   text: "; BaselineInterpreterCodeGen::emit_Symbol"),
  (offset: "00", text: "movzbl 0x1(%r14), %ecx"),
  (offset: "04", text: "movq  -0x20(%rbp), %rbx   ; aotTableBase_"),
  (offset: "0b", text: "..."),
  (offset: "0f", text: "movq  0x28(%rbx), %rbx    ; wellKnownSymbols"),
  (offset: "16", text: "movq  (%rbx,%rcx,8), %rcx"),
  (offset: "1a", text: "..."),
  (offset: "1e", text: "leaq  .Ltable(%rip), %rbx ; dispatch (PIC)"),
  (offset: "25", text: "movslq (%rbx,%rcx,4), %rcx ; rel32 offset"),
  (offset: "29", text: "addq  %rbx, %rcx          ; base + rel"),
  (offset: "2c", text: "jmp   *%rcx"),
)

#let code-regions = (
  (start: 2, end: 2, fill: yellow.lighten(75%)),
  (start: 4, end: 4, fill: yellow.lighten(75%)),
)

#let arrows = (
  (code-i: 4, tab-i: 5, wx: 1.0),
)

#let tab-header = [AOTIndirectionTable #text(weight: "regular", size: 8.5pt, [(`.data`)])]
#let blob-header = [AOT Baseline Interpreter #text(weight: "regular", size: 8.5pt, [(`.text`)])]

#context {
  let tab-cols = auto-grid-widths(("cell-alt", "cell"), table-rows, header: tab-header)
  let tab-w = tab-cols.map(c => c.width).sum()
  let code-w = auto-listing-width(code-lines, header: blob-header)

  let reg-nw = measure-text-width(("%rbx",), 10pt, padding: 0.4)
  let reg-vw = measure-text-width(("aotTableBase_",), 10pt, padding: 0.5)
  let reg-name-role = (fill: luma(225), stroke: 0.5pt, text-size: 10pt, text-weight: "regular", font-key: "mono")
  let reg-cols = ((width: reg-nw, default-role: reg-name-role), (width: reg-vw, default-role: "cell"))

  let reg-y = 0
  let tab-y = -1.5
  let blob-x = tab-w + 2.0
  let rh = default-style.geometry.row-height

  let tab-geo = grid-geo((0, tab-y), tab-cols, table-rows.len(), header: tab-header)
  let blob-geo = listing-geo((blob-x, reg-y + 0.2), code-w, code-lines.len(), header: blob-header)

  cetz.canvas({
    import cetz.draw: *

    cell-grid((0, reg-y), reg-cols, (("%rbx", "aotTableBase_"),))

    cell-grid((0, tab-y), tab-cols, table-rows, header: tab-header)

    connector(
      ((reg-nw + reg-vw) / 2, reg-y - rh),
      (tab-w / 2, tab-y),
      dash: "dashed",
    )

    code-listing((blob-x, reg-y + 0.2), code-w, code-lines, header: blob-header, regions: code-regions)

    for a in arrows {
      let cy = (blob-geo.line-y)(a.code-i)
      let ty = (tab-geo.row-y)(a.tab-i)
      let wx = tab-w + a.wx

      connector(
        (blob-x, cy),
        (wx, cy),
        (wx, ty),
        (tab-w, ty),
      )
    }
  })
}
