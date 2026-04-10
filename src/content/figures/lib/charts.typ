#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot as cetz-plot, chart as cetz-chart
#import "style.typ": *

#let line-chart(
  data,
  x-label: none,
  y-label: none,
  x-tick-step: auto,
  y-tick-step: auto,
  x-min: auto,
  x-max: auto,
  y-min: auto,
  y-max: auto,
  x-grid: false,
  y-grid: false,
  size: auto,
  legend: auto,
  style: default-style,
) = {
  let s = style.chart
  let sz = if size == auto { s.size } else { size }
  let pal = s.palette

  set text(font: style.fonts.sans, size: s.tick-size)
  cetz.canvas({
    cetz-plot.plot(
      size: sz,
      axis-style: "scientific",
      x-label: if x-label != none { text(size: s.label-size, x-label) },
      y-label: if y-label != none { text(size: s.label-size, y-label) },
      x-tick-step: x-tick-step,
      y-tick-step: y-tick-step,
      x-min: x-min,
      x-max: x-max,
      y-min: y-min,
      y-max: y-max,
      x-grid: x-grid,
      y-grid: y-grid,
      legend: legend,
      {
        for (i, series) in data.enumerate() {
          let color = pal.at(calc.rem(i, pal.len()))
          cetz-plot.add(
            series.points,
            label: series.at("label", default: none),
            style: (stroke: (paint: color, thickness: s.stroke-weight, dash: series.at("dash", default: "solid"))),
            mark: series.at("mark", default: none),
            mark-size: s.mark-size,
            mark-style: (stroke: color, fill: color.lighten(60%)),
          )
        }
      },
    )
  })
}

#let bar-chart(
  data,
  label-key: 0,
  value-key: 1,
  labels: none,
  mode: "basic",
  horizontal: false,
  x-label: none,
  y-label: none,
  size: auto,
  legend: auto,
  style: default-style,
) = {
  let s = style.chart
  let sz = if size == auto { s.size } else { size }
  let pal = s.palette
  let fn = if horizontal { cetz-chart.barchart } else { cetz-chart.columnchart }

  let bar-style = (i) => (fill: pal.at(calc.rem(i, pal.len())), stroke: none)

  let args = (
    size: sz,
    label-key: label-key,
    value-key: value-key,
    mode: mode,
    bar-style: bar-style,
    bar-width: s.bar-width,
    legend: legend,
  )
  let args = args + if labels != none { (labels: labels) } else { (:) }
  let args = args + if x-label != none { (x-label: text(font: style.fonts.sans, size: s.label-size, x-label)) } else { (:) }
  let args = args + if y-label != none { (y-label: text(font: style.fonts.sans, size: s.label-size, y-label)) } else { (:) }

  set text(font: style.fonts.sans, size: s.tick-size)
  cetz.canvas({
    fn(..args, data)
  })
}
