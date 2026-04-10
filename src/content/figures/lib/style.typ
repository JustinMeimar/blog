#let default-style = (
  fonts: (mono: "New Computer Modern Mono", sans: "New Computer Modern"),
  roles: (
    header:         (fill: luma(200),  stroke: 0.5pt, text-size: 10pt, text-weight: "bold",    font-key: "sans"),
    cell:           (fill: luma(245),  stroke: 0.5pt, text-size: 10pt, text-weight: "regular",  font-key: "mono"),
    cell-alt:       (fill: luma(225),  stroke: 0.5pt, text-size: 8.5pt, text-weight: "regular", font-key: "mono"),
    code:           (fill: luma(245),  stroke: 0.5pt, text-size: 9pt,  text-weight: "regular",  font-key: "mono"),
    code-highlight: (fill: luma(200),  stroke: none,  text-size: 9pt,  text-weight: "regular",  font-key: "mono"),
    label:          (fill: none,       stroke: none,  text-size: 10pt, text-weight: "regular",  font-key: "sans"),
    caption:        (fill: none,       stroke: none,  text-size: 10pt, text-weight: "regular",  font-key: "sans"),
    caption-desc:   (fill: none,       stroke: none,  text-size: 9pt,  text-weight: "regular",  font-key: "sans"),
  ),
  connector: (stroke-weight: 0.6pt, paint: black),
  geometry: (row-height: 0.56, line-height: 0.46, padding: 0.5, code-pad: 0.3, border-weight: 0.8pt),
  chart: (
    size: (9, 6),
    palette: (
      rgb("#4e79a7"), rgb("#f28e2b"), rgb("#e15759"),
      rgb("#76b7b2"), rgb("#59a14f"), rgb("#edc948"),
      rgb("#b07aa1"), rgb("#ff9da7"), rgb("#9c755f"), rgb("#bab0ac"),
    ),
    stroke-weight: 1.2pt,
    mark-size: 0.12,
    label-size: 10pt,
    tick-size: 9pt,
    bar-width: 0.8,
  ),
)

#let resolve-role(style, role-name) = {
  if type(role-name) == dictionary { role-name }
  else { style.roles.at(role-name) }
}

#let resolve-font(style, role) = {
  style.fonts.at(role.font-key)
}

#let styled-text(style, role-name, body) = {
  let role = resolve-role(style, role-name)
  let font = resolve-font(style, role)
  text(font: font, size: role.text-size, weight: role.text-weight, body)
}

#let merge-style(base, overrides) = {
  let result = base
  for key in overrides.keys() {
    let val = overrides.at(key)
    if key in result and type(result.at(key)) == dictionary and type(val) == dictionary {
      result.insert(key, merge-style(result.at(key), val))
    } else {
      result.insert(key, val)
    }
  }
  result
}
