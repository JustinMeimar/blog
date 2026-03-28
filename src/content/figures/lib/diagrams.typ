#import "@preview/cetz:0.3.4"

#let default-theme = (
  fonts: (
    mono: "New Computer Modern Mono",
    sans: "New Computer Modern",
  ),
  sizes: (
    title: 13pt,
    label: 10pt,
    code: 9pt,
    offset: 8.5pt,
    caption: 10pt,
    caption-desc: 9pt,
  ),
  fills: (
    light: luma(245),
    med: luma(225),
    dark: luma(200),
  ),
  strokes: (
    weight: 0.5pt,
    connector: 0.6pt,
    border: 0.8pt,
  ),
  geometry: (
    row-height: 0.78,
    line-height: 0.72,
    padding: 0.6,
  ),
)

// ── Figure page ─────────────────────────────────────────────

#let figure-page(number: none, title: none, description: none, theme: default-theme, body) = {
  set page(width: auto, height: auto, margin: 1.5em, fill: none)
  set text(font: theme.fonts.mono, size: 11pt)

  body

  if title != none {
    v(0.5em)
    align(center, text(font: theme.fonts.sans, size: theme.sizes.caption)[
      #if number != none [*Figure #number* --- ]
      *#title*
      #if description != none [
        \ #text(size: theme.sizes.caption-desc, fill: luma(100), description)
      ]
    ])
  }
}

// ── Auto-measure helpers (must be called inside context) ────

#let measure-col-width(items, size, padding: 0.6, theme: default-theme) = {
  if items.len() == 0 { return padding }
  let widths = items.map(item => measure(text(size: size, raw(item))).width / 1cm)
  calc.max(..widths) + padding
}

#let auto-mem-table-widths(entries, header: none, theme: default-theme) = {
  let off-w = measure-col-width(entries.map(e => e.off), theme.sizes.offset, theme: theme)
  let field-w = measure-col-width(entries.map(e => e.field), theme.sizes.label, theme: theme)
  if header != none {
    let header-w = measure(text(size: theme.sizes.label, weight: "bold", header)).width / 1cm + 0.6
    let total = off-w + field-w
    if header-w > total { field-w = field-w + (header-w - total) }
  }
  (off-w: off-w, field-w: field-w)
}

#let auto-code-blob-width(lines, header: none, theme: default-theme) = {
  let text-w = measure-col-width(lines.map(e => e.text), theme.sizes.code, padding: 0.8, theme: theme)
  if header != none {
    let header-w = measure(text(size: theme.sizes.label, weight: "bold", header)).width / 1cm + 0.6
    calc.max(text-w, header-w)
  } else { text-w }
}

#let auto-data-card-width(kind, data, theme: default-theme) = {
  let kind-w = measure(text(size: theme.sizes.label, weight: "bold", kind)).width / 1cm + 0.6
  let data-w = if data.len() > 0 {
    measure-col-width(data, theme.sizes.offset, theme: theme)
  } else { 0 }
  calc.max(kind-w, data-w)
}

#let auto-register-widths(name, value, theme: default-theme) = {
  let nw = measure(text(size: theme.sizes.label, raw(name))).width / 1cm + 0.4
  let vw = measure(text(size: theme.sizes.label, raw(value))).width / 1cm + 0.5
  (name-w: nw, total-w: nw + vw)
}

// ── Geometry helpers ────────────────────────────────────────

#let mem-table-geo(pos, entries, header: none, off-w: 1.1, field-w: 3.4, theme: default-theme) = {
  let rh = theme.geometry.row-height
  let w = off-w + field-w
  let y = pos.at(1)
  if header != none { y = y - rh }
  (
    width: w,
    bottom-y: y - entries.len() * rh,
    row-y: (i) => y - i * rh - rh / 2,
  )
}

#let code-blob-geo(pos, width, lines, header: none, theme: default-theme) = {
  let rh = theme.geometry.row-height
  let pad = theme.geometry.padding
  let line-h = theme.geometry.line-height
  let y = pos.at(1)
  if header != none { y = y - rh }
  let h = lines.len() * line-h + 2 * pad
  (
    width: width,
    height: h + if header != none { rh } else { 0 },
    bottom-y: y - h,
    line-y: (i) => y - pad - i * line-h,
  )
}

#let data-card-height(data, theme: default-theme) = {
  let rh = theme.geometry.row-height
  rh + data.len() * rh
}

// ── Drawing functions ───────────────────────────────────────

#let section-header(pos, width, label, theme: default-theme) = {
  import cetz.draw: *
  let rh = theme.geometry.row-height
  let x = pos.at(0)
  let y = pos.at(1)
  rect((x, y), (x + width, y - rh), stroke: theme.strokes.weight, fill: theme.fills.dark)
  content((x + width / 2, y - rh / 2), text(weight: "bold", size: theme.sizes.label, label))
}

#let mem-table(pos, entries, header: none, off-w: 1.1, field-w: 3.4, theme: default-theme) = {
  import cetz.draw: *
  let rh = theme.geometry.row-height
  let w = off-w + field-w
  let x = pos.at(0)
  let y = pos.at(1)

  if header != none {
    section-header((x, y), w, header, theme: theme)
    y = y - rh
  }

  for (i, entry) in entries.enumerate() {
    let ry = y - i * rh
    rect((x, ry), (x + off-w, ry - rh), stroke: theme.strokes.weight, fill: theme.fills.med)
    content((x + off-w / 2, ry - rh / 2), text(size: theme.sizes.offset, raw(entry.off)))
    rect((x + off-w, ry), (x + w, ry - rh), stroke: theme.strokes.weight, fill: theme.fills.light)
    content((x + off-w + field-w / 2, ry - rh / 2), text(size: theme.sizes.label, raw(entry.field)))
  }
}

#let register-display(pos, name, value, name-w: 1.0, total-w: 4.5, theme: default-theme) = {
  import cetz.draw: *
  let rh = theme.geometry.row-height
  let x = pos.at(0)
  let y = pos.at(1)
  rect((x, y), (x + name-w, y - rh), stroke: theme.strokes.weight, fill: theme.fills.med)
  content((x + name-w / 2, y - rh / 2), text(size: theme.sizes.label, raw(name)))
  rect((x + name-w, y), (x + total-w, y - rh), stroke: theme.strokes.weight, fill: theme.fills.light)
  content((x + name-w + (total-w - name-w) / 2, y - rh / 2), text(size: theme.sizes.label, raw(value)))
}

#let code-blob(pos, width, lines, header: none, theme: default-theme) = {
  import cetz.draw: *
  let rh = theme.geometry.row-height
  let pad = theme.geometry.padding
  let line-h = theme.geometry.line-height
  let h = lines.len() * line-h + 2 * pad
  let x = pos.at(0)
  let y = pos.at(1)

  if header != none {
    section-header((x, y), width, header, theme: theme)
    y = y - rh
  }

  rect((x, y), (x + width, y - h), stroke: theme.strokes.weight, fill: theme.fills.light)

  for (i, entry) in lines.enumerate() {
    let ly = y - pad - i * line-h
    if entry.at("reloc", default: false) {
      rect(
        (x + 0.1, ly + line-h / 2 - 0.04),
        (x + width - 0.1, ly - line-h / 2 + 0.04),
        stroke: none,
        fill: theme.fills.dark,
      )
    }
    content(
      (x + 0.4, ly),
      anchor: "west",
      text(size: theme.sizes.code, raw(entry.text)),
    )
  }
}

#let data-card(pos, width, kind, data, theme: default-theme) = {
  import cetz.draw: *
  let rh = theme.geometry.row-height
  let x = pos.at(0)
  let y = pos.at(1)
  rect((x, y), (x + width, y - rh), stroke: theme.strokes.weight, fill: theme.fills.dark)
  content((x + width / 2, y - rh / 2), text(weight: "bold", size: theme.sizes.label, kind))
  for (i, row) in data.enumerate() {
    let ry = y - rh - i * rh
    rect((x, ry), (x + width, ry - rh), stroke: theme.strokes.weight, fill: theme.fills.light)
    content((x + width / 2, ry - rh / 2), text(size: theme.sizes.offset, raw(row)))
  }
}

#let connector(..points, style: "dotted", theme: default-theme) = {
  import cetz.draw: *
  line(
    ..points.pos(),
    stroke: (paint: black, thickness: theme.strokes.connector, dash: style),
    mark: (end: ">", fill: black),
  )
}
