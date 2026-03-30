#import "style.typ": *

#let measure-text-width(items, size, padding: 0.6) = {
  if items.len() == 0 { return padding }
  let widths = items.map(item => measure(text(size: size, raw(item))).width / 1cm)
  calc.max(..widths) + padding
}

#let measure-content-width(body, padding: 0.6) = {
  measure(body).width / 1cm + padding
}

#let auto-grid-widths(columns, rows, header: none, style: default-style) = {
  let n = columns.len()
  let widths = range(n).map(j => {
    let col = columns.at(j)
    let role-name = if type(col) == str { col } else { col.role }
    let pad = if type(col) == str { style.geometry.padding } else { col.at("padding", default: style.geometry.padding) }
    let role = resolve-role(style, role-name)
    let items = rows.map(row => {
      let cell = row.at(j)
      if type(cell) == dictionary { cell.content } else { cell }
    })
    measure-text-width(items, role.text-size, padding: pad)
  })
  if header != none {
    let header-role = resolve-role(style, "header")
    let header-w = measure-content-width(
      text(size: header-role.text-size, weight: header-role.text-weight, header),
    )
    let total = widths.sum()
    if header-w > total {
      widths.at(n - 1) = widths.at(n - 1) + (header-w - total)
    }
  }
  let role-names = columns.map(c => if type(c) == str { c } else { c.role })
  role-names.zip(widths).map(p => (width: p.at(1), default-role: p.at(0)))
}

#let auto-listing-width(lines, header: none, style: default-style) = {
  let code-role = resolve-role(style, "code")
  let texts = lines.map(l => if type(l) == str { l } else { l.text })
  let has-offsets = lines.any(l => type(l) == dictionary and "offset" in l)
  let offset-col = if has-offsets { 0.6 } else { 0 }
  let text-w = measure-text-width(texts, code-role.text-size, padding: 0.8)
  let total = offset-col + text-w
  if header != none {
    let header-role = resolve-role(style, "header")
    let header-w = measure-content-width(
      text(size: header-role.text-size, weight: header-role.text-weight, header),
    )
    calc.max(total, header-w)
  } else { total }
}

#let vstack-positions(start-y, heights, gap: 0) = {
  let positions = ()
  let y = start-y
  for h in heights {
    positions.push(y)
    y = y - h - gap
  }
  positions
}

#let hstack-positions(start-x, widths, gap: 0) = {
  let positions = ()
  let x = start-x
  for w in widths {
    positions.push(x)
    x = x + w + gap
  }
  positions
}

#let grid-geo(pos, columns, row-count, header: none, style: default-style) = {
  let rh = style.geometry.row-height
  let col-widths = columns.map(c => c.width)
  let w = col-widths.sum()
  let x = pos.at(0)
  let y = pos.at(1)
  if header != none { y = y - rh }
  (
    width: w,
    height: row-count * rh + if header != none { rh } else { 0 },
    bottom-y: y - row-count * rh,
    row-y: (i) => y - i * rh - rh / 2,
    col-x: (j) => x + if j > 0 { col-widths.slice(0, j).sum() } else { 0 },
    left-edge: (j) => x + if j > 0 { col-widths.slice(0, j).sum() } else { 0 },
    right-edge: (j) => x + col-widths.slice(0, j + 1).sum(),
  )
}

#let listing-geo(pos, width, line-count, header: none, style: default-style) = {
  let rh = style.geometry.row-height
  let pad = style.geometry.code-pad
  let line-h = style.geometry.line-height
  let x = pos.at(0)
  let y = pos.at(1)
  if header != none { y = y - rh }
  let h = line-count * line-h + 2 * pad
  (
    width: width,
    height: h + if header != none { rh } else { 0 },
    bottom-y: y - h,
    line-y: (i) => y - pad - i * line-h,
    left-edge: (_) => x,
    right-edge: (_) => x + width,
  )
}
