#import "@preview/cetz:0.3.4"

#let default-theme = (
  fonts: (
    mono: "New Computer Modern Mono",
    sans: "New Computer Modern Sans",
  ),
  sizes: (
    title: 10pt,
    label: 7.5pt,
    code: 7pt,
    offset: 6.5pt,
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
    row-height: 0.6,
    line-height: 0.55,
    padding: 0.5,
  ),
)

// ── Geometry helpers ────────────────────────────────────────

#let mem-table-geo(pos, entries, off-w: 1.1, field-w: 3.4, theme: default-theme) = {
  let row-h = theme.geometry.row-height
  let w = off-w + field-w
  let y = pos.at(1)
  (
    width: w,
    bottom-y: y - entries.len() * row-h,
    row-y: (i) => y - i * row-h - row-h / 2,
  )
}

#let code-blob-geo(pos, width, lines, theme: default-theme) = {
  let pad = theme.geometry.padding
  let line-h = theme.geometry.line-height
  let h = lines.len() * line-h + 2 * pad
  let y = pos.at(1)
  (
    width: width,
    height: h,
    bottom-y: y - h,
    line-y: (i) => y - pad - i * line-h,
  )
}

// ── Drawing functions ───────────────────────────────────────

#let mem-table(pos, entries, label: none, off-w: 1.1, field-w: 3.4, theme: default-theme) = {
  import cetz.draw: *
  let row-h = theme.geometry.row-height
  let w = off-w + field-w
  let x = pos.at(0)
  let y = pos.at(1)

  for (i, entry) in entries.enumerate() {
    let ry = y - i * row-h

    rect((x, ry), (x + off-w, ry - row-h), stroke: theme.strokes.weight, fill: theme.fills.med)
    content((x + off-w / 2, ry - row-h / 2), text(size: theme.sizes.offset, raw(entry.off)))

    rect((x + off-w, ry), (x + w, ry - row-h), stroke: theme.strokes.weight, fill: theme.fills.light)
    content((x + off-w + field-w / 2, ry - row-h / 2), text(size: theme.sizes.label, raw(entry.field)))
  }

  if label != none {
    let bottom = y - entries.len() * row-h
    content((x + w / 2, bottom - 0.5), text(weight: "bold", size: theme.sizes.title, label))
  }
}

#let register-display(pos, name, value, title: none, name-w: 1.0, total-w: 4.5, theme: default-theme) = {
  import cetz.draw: *
  let row-h = theme.geometry.row-height
  let x = pos.at(0)
  let y = pos.at(1)

  if title != none {
    content((x + total-w / 2, y + 0.8), text(weight: "bold", size: theme.sizes.title, title))
  }

  rect((x, y), (x + name-w, y - row-h), stroke: theme.strokes.weight, fill: theme.fills.med)
  content((x + name-w / 2, y - row-h / 2), text(size: theme.sizes.label, raw(name)))

  rect((x + name-w, y), (x + total-w, y - row-h), stroke: theme.strokes.weight, fill: theme.fills.light)
  content((x + name-w + (total-w - name-w) / 2, y - row-h / 2), text(size: theme.sizes.label, raw(value)))
}

#let code-blob(pos, width, lines, title: none, theme: default-theme) = {
  import cetz.draw: *
  let pad = theme.geometry.padding
  let line-h = theme.geometry.line-height
  let h = lines.len() * line-h + 2 * pad
  let x = pos.at(0)
  let y = pos.at(1)

  if title != none {
    content((x + width / 2, y + 0.8), text(weight: "bold", size: theme.sizes.title, title))
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

#let titled-box(pos, size, title, fill: auto, title-offset: 0.5, theme: default-theme) = {
  let f = if fill == auto { theme.fills.light } else { fill }
  import cetz.draw: *
  let x = pos.at(0)
  let y = pos.at(1)
  let w = size.at(0)
  let h = size.at(1)

  rect((x, y), (x + w, y - h), stroke: theme.strokes.weight, fill: f)
  content((x + w / 2, y + title-offset), text(weight: "bold", size: theme.sizes.title, title))
}

#let patch-card-height(data, theme: default-theme) = {
  let row-h = theme.geometry.row-height
  row-h + data.len() * row-h
}

#let patch-card(pos, width, kind, data, theme: default-theme) = {
  import cetz.draw: *
  let row-h = theme.geometry.row-height
  let x = pos.at(0)
  let y = pos.at(1)

  rect((x, y), (x + width, y - row-h), stroke: theme.strokes.weight, fill: theme.fills.dark)
  content((x + width / 2, y - row-h / 2), text(weight: "bold", size: theme.sizes.label, kind))

  for (i, row) in data.enumerate() {
    let ry = y - row-h - i * row-h
    rect((x, ry), (x + width, ry - row-h), stroke: theme.strokes.weight, fill: theme.fills.light)
    content((x + width / 2, ry - row-h / 2), text(size: theme.sizes.offset, raw(row)))
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
