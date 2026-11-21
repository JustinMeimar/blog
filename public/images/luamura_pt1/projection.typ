// Luamura's ad-hoc first Futamura projection.
// Fonts: nix build nixpkgs#geist-font
// Compile: typst compile --font-path <geist>/share/fonts projection.typ
//   and again with --input theme=dark for projection-dark.svg.
// The background is transparent so the blog's own page colour shows.
#let palettes = (
  light: (
    ink: "292524", muted: "78716c", line-ink: "a8a29e", card: "ece9e5",
    data-fill: "c9dcf5", data-ink: "1d4a80", code-fill: "fad3b8",
    code-ink: "9a3f0c", edge-ink: "57534e", pill: "ffffff",
    pill-border: "a8a29e",
  ),
  dark: (
    ink: "e7e5e4", muted: "a8a29e", line-ink: "78716c", card: "292524",
    data-fill: "1f3a5c", data-ink: "c3dbf7", code-fill: "5c2f17",
    code-ink: "fbcfae", edge-ink: "a8a29e", pill: "1c1917",
    pill-border: "57534e",
  ),
)
#let theme = sys.inputs.at("theme", default: "light")
#let colours = (palettes.at(theme).pairs()
  .map(((k, v)) => (k, rgb(v))).to-dict())

#set page(width: 228mm, height: auto, margin: 6mm, fill: none)
// Measure text by its cap height so it centres optically in boxes.
#set text(font: "Geist", size: 9.5pt, fill: colours.ink,
  top-edge: "cap-height", bottom-edge: "baseline")
#set par(leading: 3pt, spacing: 0pt)

#let muted = colours.muted
#let line-ink = colours.line-ink
#let card = colours.card
#let data-fill = colours.data-fill
#let data-ink = colours.data-ink
#let code-fill = colours.code-fill
#let code-ink = colours.code-ink
#let edge-ink = colours.edge-ink

#let mono(fill: auto, body) = text(font: "Geist Mono", size: 8pt,
  fill: if fill == auto { colours.ink } else { fill }, body)
#let at(x, y, body) = place(top + left, dx: x * 1mm, dy: y * 1mm, body)
// A rounded box whose content is centred both ways.
#let panel(x, y, w, h, body, fill: card, border: none, radius: 3mm) = at(
  x, y, block(width: w * 1mm, height: h * 1mm, radius: radius,
    fill: fill, stroke: if border == none { none } else { 0.5pt + border },
  )[#align(center + horizon)[#body]])
#let pill(x, y, w, body, fill: colours.pill, border: none) = panel(x, y, w, 7,
  body, fill: fill, border: border, radius: 3.5mm)
#let label(x, y, w, body) = at(x, y,
  block(width: w * 1mm)[#align(center)[#body]])
#let block-name(x, y, name, fill: muted) = at(x + 3, y + 3,
  text(size: 7.5pt, fill: fill)[#name])
// Cap heights in mm, so boxes can be sized to their text exactly.
#let mono-cap = 2
#let name-cap = 1.9
#let line-gap = 2.2
#let lines-h(n) = n * mono-cap + (n - 1) * line-gap
#let lines(items, fill) = stack(spacing: line-gap * 1mm,
  ..items.map(op => mono(fill: fill)[#op]))
#let ellipsis = text(fill: muted, baseline: -0.7mm)[…]
// Padding inside a block, and the gap below its name.
#let pad = 3.5
#let body-y = 3 + name-cap + 3

#let head(x, y, dir, paint) = {
  let s = 1.6
  let pts = if dir == "right" { ((0, 0), (s, s / 2), (0, s)) }
    else if dir == "left" { ((s, 0), (0, s / 2), (s, s)) }
    else { ((0, 0), (s, 0), (s / 2, s)) }
  let (dx, dy) = if dir == "right" { (-s, -s / 2) }
    else if dir == "left" { (0, -s / 2) } else { (-s / 2, -s) }
  at(x + dx, y + dy, polygon(fill: paint,
    ..pts.map(((a, b)) => (a * 1mm, b * 1mm))))
}
#let stroke-of(paint, dash) = (paint: paint, thickness: 0.6pt,
  cap: "round", dash: dash)
#let mm(p) = p.map(v => v * 1mm)
// A cubic edge ending in an arrowhead that points in direction dir.
#let edge(p0, c0, c1, p1, dir, paint: edge-ink, dash: none) = {
  let end = if dir == "down" { (p1.at(0), p1.at(1) - 1.4) }
    else if dir == "left" { (p1.at(0) + 1.4, p1.at(1)) }
    else { (p1.at(0) - 1.4, p1.at(1)) }
  at(0, 0, curve(stroke: stroke-of(paint, dash),
    curve.move(mm(p0)), curve.cubic(mm(c0), mm(c1), mm(end))))
  head(p1.at(0), p1.at(1), dir, paint)
}
#let arrow-down(x, y, length, paint: line-ink) = edge((x, y), (x, y),
  (x, y + length), (x, y + length), "down", paint: paint)
#let arrow-right(x, y, length, paint: line-ink) = edge((x, y), (x, y),
  (x + length, y), (x + length, y), "right", paint: paint)

#let col-w = 44
#let pill-w = 34
#let cfg-w = 80
#let gap = 24
#let interp-x = 0
#let cfg-x = col-w + gap
#let out-x = cfg-x + cfg-w + gap

#let blocks = (
  (name: "B0", ops: ("MODK t i 2", "EQI t 0"), jump: "JMP → B2",
    out: ("OP_MODK", "OP_EQI"), br: "br B1, B2"),
  (name: "B1", ops: ("ADD s s i", "MULK s s 3"), jump: "JMP → B3",
    out: ("OP_ADD", "OP_MULK"), br: "br B3", expand: true),
  (name: "B2", ops: ("SUB s s i",), jump: none,
    out: ("OP_SUB",), br: none),
  (name: "B3", ops: ("ADDI i i 1",), jump: "JMP → B0",
    out: ("OP_ADDI",), br: "br B0"),
)

// A bytecode basic block: its name, then its instructions centred.
#let bytecode-lines(b) = b.ops + if b.jump == none { () } else { (b.jump,) }
#let bytecode-h(b) = body-y + lines-h(bytecode-lines(b).len()) + pad
#let bytecode-block(x, y, w, b) = {
  panel(x, y, w, bytecode-h(b), fill: data-fill)[]
  block-name(x, y, b.name, fill: data-ink)
  label(x, y + body-y, w)[#lines(bytecode-lines(b), data-ink)]
}

// A compiled block: its handlers share one box, then its branch.
#let handlers-h(b) = lines-h(b.out.len()) + 2 * pad
#let compiled-h(b) = {
  body-y + handlers-h(b) + if b.br == none { 0 } else { 2.5 + 7 } + 5
}
#let compiled-block(x, y, b) = {
  panel(x, y, col-w, compiled-h(b))[]
  block-name(x, y, b.name)
  panel(x + 5, y + body-y, pill-w, handlers-h(b), fill: code-fill,
    radius: 3.5mm)[#lines(b.out, code-ink)]
  if b.br != none {
    pill(x + 5, y + body-y + handlers-h(b) + 2.5, pill-w,
      border: colours.pill-border)[#mono[#b.br]]
  }
}
// Other compiled blocks are elided to focus on one.
#let collapsed-h = 8
#let collapsed-block(x, y, b) = {
  panel(x, y, col-w, collapsed-h)[#ellipsis]
  at(x + 3, y, block(height: collapsed-h * 1mm)[#align(horizon)[
    #text(size: 7.5pt, fill: muted)[#b.name]]])
}

// The CFG sets the height; the other columns centre against it.
#let (b0, b1, b2, b3) = blocks
#let arm-y = bytecode-h(b0) + 14
#let merge-y = arm-y + calc.max(bytecode-h(b1), bytecode-h(b2)) + 13
#let cfg-h = merge-y + bytecode-h(b3)
#let mid = cfg-h / 2

#let interp-h = 80
#let compiled-total = blocks.map(b =>
  if b.at("expand", default: false) { compiled-h(b) }
  else { collapsed-h }).sum() + (blocks.len() - 1) * 3

#block(width: 216mm, height: (cfg-h + 22) * 1mm)[
  // The interpreter fetches, dispatches, runs a handler, and repeats.
  #let iy = mid - interp-h / 2
  #panel(interp-x, iy, col-w, interp-h)[]
  #pill(interp-x + 5, iy + 6, pill-w)[#mono[i = code[pc++]]]
  #arrow-down(interp-x + 22, iy + 14, 5)
  #pill(interp-x + 5, iy + 20, pill-w)[#mono[switch op(i)]]
  #arrow-down(interp-x + 22, iy + 28, 5)
  #for (k, name) in ("OP_EQI", "OP_JMP", "OP_ADD",
                     "OP_MULK").enumerate() {
    pill(interp-x + 5, iy + 34 + k * 9, pill-w,
      fill: code-fill)[#mono(fill: code-ink)[#name]]
  }
  #panel(interp-x, iy + 70, col-w, 7, fill: none)[#ellipsis]
  // Every handler returns to the top of the loop.
  #at(interp-x + 41, iy + 35.5, line(end: (0mm, 29mm),
    stroke: stroke-of(muted, none)))
  #edge((interp-x + 41, iy + 50), (interp-x + 54, iy + 50),
    (interp-x + 54, iy + 9.5), (interp-x + 39, iy + 9.5), "left",
    paint: muted, dash: "dashed")

  // The guest's CFG: an if/else diamond inside a loop.
  #let side-w = 34
  #let centre-w = 36
  #let cx = cfg-x + cfg-w / 2
  #let left-c = cfg-x + side-w / 2
  #let right-c = cfg-x + cfg-w - side-w / 2
  #bytecode-block(cx - centre-w / 2, 0, centre-w, b0)
  #bytecode-block(cfg-x, arm-y, side-w, b1)
  #bytecode-block(cfg-x + cfg-w - side-w, arm-y, side-w, b2)
  #bytecode-block(cx - centre-w / 2, merge-y, centre-w, b3)
  #let b0-end = bytecode-h(b0)
  #edge((cx - 6, b0-end), (cx - 6, b0-end + 7), (left-c, arm-y - 7),
    (left-c, arm-y), "down")
  #edge((cx + 6, b0-end), (cx + 6, b0-end + 7), (right-c, arm-y - 7),
    (right-c, arm-y), "down")
  #let b1-end = arm-y + bytecode-h(b1)
  #let b2-end = arm-y + bytecode-h(b2)
  #edge((left-c, b1-end), (left-c, b1-end + 7), (cx - 6, merge-y - 7),
    (cx - 6, merge-y), "down")
  #edge((right-c, b2-end), (right-c, b2-end + 9), (cx + 6, merge-y - 7),
    (cx + 6, merge-y), "down")
  #let back-x = cfg-x - 11
  #edge((cx - centre-w / 2, merge-y + bytecode-h(b3) / 2),
    (back-x, merge-y + bytecode-h(b3) / 2),
    (back-x, bytecode-h(b0) / 2), (cx - centre-w / 2, bytecode-h(b0) / 2),
    "right")

  // Projection: each block's handlers inlined back to back.
  #let arrow-x = cfg-x + cfg-w + 6
  #arrow-right(arrow-x, mid, gap - 12)
  #label(arrow-x - 4, mid - 5, gap - 4)[
    #text(size: 7.5pt, fill: muted)[Inline]]
  #let y = mid - compiled-total / 2
  #for b in blocks {
    if b.at("expand", default: false) {
      compiled-block(out-x, y, b)
      y += compiled-h(b) + 3
    } else {
      collapsed-block(out-x, y, b)
      y += collapsed-h + 3
    }
  }

  #for (x, w, title, note) in (
    (interp-x, col-w, "Interpreter", "Dispatch per instruction"),
    (cfg-x, cfg-w, "Bytecode", "Walked in pc order, not along its edges"),
    (out-x, col-w, "Compiled", "Handlers fall through"),
  ) {
    label(x - 10, cfg-h + 12, w + 20)[
      #text(weight: "medium", size: 11pt)[#title]]
    label(x - 10, cfg-h + 18, w + 20)[
      #text(size: 8pt, fill: muted)[#note]]
  }
]
