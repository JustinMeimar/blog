#import "@preview/cetz:0.3.4"
#import "lib/diagrams.typ": *

#show: figure-page.with(
  number: 2,
  title: [AOT Indirection Table],
  description: [Relocation sites in the AOT code blob resolve pointers through indirect loads via a pinned register.],
)

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

#let tab-header = [AOTIndirectionTable #text(weight: "regular", size: default-theme.sizes.offset, [(`.data`)])]
#let blob-header = [AOT Code Blob #text(weight: "regular", size: default-theme.sizes.offset, [(`.text`)])]

#context {
  let tw = auto-mem-table-widths(table-entries, header: tab-header)
  let tab-w = tw.off-w + tw.field-w
  let code-w = auto-code-blob-width(code-lines, header: blob-header)
  let rw = auto-register-widths("r13", "&AOTIndirectionTable")

  let reg-y = 0
  let tab-y = -2.0
  let blob-x = tab-w + 4.0
  let rh = default-theme.geometry.row-height

  let tab-geo = mem-table-geo((0, tab-y), table-entries, header: tab-header, off-w: tw.off-w, field-w: tw.field-w)
  let blob-geo = code-blob-geo((blob-x, reg-y + 0.2), code-w, code-lines, header: blob-header)

  cetz.canvas({
    import cetz.draw: *

    register-display((0, reg-y), "r13", "&AOTIndirectionTable", name-w: rw.name-w, total-w: rw.total-w)

    mem-table((0, tab-y), table-entries, header: tab-header, off-w: tw.off-w, field-w: tw.field-w)

    connector(
      (rw.total-w / 2, reg-y - rh),
      (tab-w / 2, tab-y),
      style: "dashed",
    )

    code-blob((blob-x, reg-y + 0.2), code-w, code-lines, header: blob-header)

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
