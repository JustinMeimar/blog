#import "@preview/cetz:0.3.4"
#import "style.typ": *

#let node(pos, width, height: none, body, role: "cell", style: default-style) = {
  import cetz.draw: *
  let r = resolve-role(style, role)
  let rh = if height != none { height } else { style.geometry.row-height }
  let x = pos.at(0)
  let y = pos.at(1)
  rect((x, y), (x + width, y - rh), stroke: r.stroke, fill: r.fill)
  content((x + width / 2, y - rh / 2), body)
}

#let section-header(pos, width, label, style: default-style) = {
  import cetz.draw: *
  let r = resolve-role(style, "header")
  let rh = style.geometry.row-height
  let x = pos.at(0)
  let y = pos.at(1)
  rect((x, y), (x + width, y - rh), stroke: r.stroke, fill: r.fill)
  content((x + width / 2, y - rh / 2), text(weight: r.text-weight, size: r.text-size, label))
}

#let cell-grid(pos, columns, rows, header: none, style: default-style) = {
  import cetz.draw: *
  let rh = style.geometry.row-height
  let col-widths = columns.map(c => c.width)
  let w = col-widths.sum()
  let x = pos.at(0)
  let y = pos.at(1)

  if header != none {
    section-header((x, y), w, header, style: style)
    y = y - rh
  }

  for (i, row) in rows.enumerate() {
    let ry = y - i * rh
    let cx = x
    for (j, col) in columns.enumerate() {
      let cell = row.at(j)
      let role-name = if type(cell) == dictionary { cell.role } else { col.default-role }
      let r = resolve-role(style, role-name)
      let cell-text = if type(cell) == dictionary { cell.content } else { cell }
      rect((cx, ry), (cx + col.width, ry - rh), stroke: r.stroke, fill: r.fill)
      content(
        (cx + col.width / 2, ry - rh / 2),
        text(size: r.text-size, weight: r.text-weight, raw(cell-text)),
      )
      cx = cx + col.width
    }
  }
}

#let code-listing(pos, width, lines, header: none, regions: (), style: default-style) = {
  import cetz.draw: *
  let rh = style.geometry.row-height
  let pad = style.geometry.code-pad
  let line-h = style.geometry.line-height
  let h = lines.len() * line-h + 2 * pad
  let x = pos.at(0)
  let y = pos.at(1)

  if header != none {
    section-header((x, y), width, header, style: style)
    y = y - rh
  }

  let has-offsets = lines.any(l => type(l) == dictionary and "offset" in l)
  let offset-col = if has-offsets { 0.6 } else { 0 }

  let code-role = resolve-role(style, "code")
  rect((x, y), (x + width, y - h), stroke: code-role.stroke, fill: code-role.fill)

  for region in regions {
    let ry-top = y - pad - region.start * line-h + line-h / 2
    let ry-bot = y - pad - region.end * line-h - line-h / 2
    rect(
      (x + 0.05, ry-top + 0.04),
      (x + width - 0.05, ry-bot - 0.04),
      stroke: none,
      fill: region.fill,
    )
  }

  for (i, entry) in lines.enumerate() {
    let ly = y - pad - i * line-h
    let line-text = if type(entry) == str { entry } else { entry.text }
    let role-name = if type(entry) == str { "code" } else { entry.at("role", default: "code") }

    if role-name == "code-highlight" {
      let hl = resolve-role(style, "code-highlight")
      rect(
        (x + 0.1, ly + line-h / 2 - 0.04),
        (x + width - 0.1, ly - line-h / 2 + 0.04),
        stroke: none,
        fill: hl.fill,
      )
    }

    if has-offsets {
      let offset = if type(entry) == dictionary { entry.at("offset", default: "") } else { "" }
      if offset != "" {
        content(
          (x + 0.15, ly),
          anchor: "west",
          text(size: 7.5pt, fill: luma(140), raw(offset)),
        )
      }
    }

    let r = resolve-role(style, role-name)
    content(
      (x + offset-col + 0.4, ly),
      anchor: "west",
      text(size: r.text-size, raw(line-text)),
    )
  }
}

#let container(pos, width, height, label: none, label-pos: "top", border-style: "dashed", role: "label", style: default-style) = {
  import cetz.draw: *
  let x = pos.at(0)
  let y = pos.at(1)
  rect(
    (x, y), (x + width, y - height),
    stroke: (paint: black, thickness: style.geometry.border-weight, dash: border-style),
  )
  if label != none {
    let lx = x + width / 2
    let ly = if label-pos == "top" { y + 0.3 } else { y - height - 0.3 }
    content((lx, ly), styled-text(style, role, label))
  }
}

#let legend(pos, entries, direction: "vertical", swatch-size: 0.4, style: default-style) = {
  import cetz.draw: *
  let x = pos.at(0)
  let y = pos.at(1)
  for (i, entry) in entries.enumerate() {
    let r = resolve-role(style, entry.role)
    let ex = if direction == "horizontal" { x + i * 2.0 } else { x }
    let ey = if direction == "vertical" { y - i * (swatch-size + 0.2) } else { y }
    rect((ex, ey), (ex + swatch-size, ey - swatch-size), fill: r.fill, stroke: r.stroke)
    content(
      (ex + swatch-size + 0.2, ey - swatch-size / 2),
      anchor: "west",
      styled-text(style, "label", entry.label),
    )
  }
}

#let connector(..args, dash: "dotted", dir: "forward", label: none, label-pos: 0.5, style: default-style) = {
  import cetz.draw: *
  let points = args.pos()
  let s = style.connector
  let stroke-style = (paint: s.paint, thickness: s.stroke-weight, dash: dash)
  if dir == "none" {
    line(..points, stroke: stroke-style)
  } else {
    let mark = if dir == "forward" { (end: ">", fill: s.paint) }
      else if dir == "backward" { (start: ">", fill: s.paint) }
      else { (start: ">", end: ">", fill: s.paint) }
    line(..points, stroke: stroke-style, mark: mark)
  }
}

#let side-annotation(x, y-start, y-end, body, side: "right", offset: 0.5, style: default-style) = {
  import cetz.draw: *
  let ax = if side == "right" { x + offset } else { x - offset }
  let mid-y = (y-start + y-end) / 2
  line((x, y-start), (ax, y-start), stroke: 0.4pt)
  line((ax, y-start), (ax, y-end), stroke: 0.4pt)
  line((ax, y-end), (x, y-end), stroke: 0.4pt)
  let anchor = if side == "right" { "west" } else { "east" }
  content((ax + if side == "right" { 0.2 } else { -0.2 }, mid-y), anchor: anchor, body)
}
