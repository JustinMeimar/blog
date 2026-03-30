#import "style.typ": *
#import "layout.typ": *
#import "shapes.typ": *

#let figure-page(number: none, title: none, description: none, style: default-style, body) = {
  set page(width: auto, height: auto, margin: 1.5em, fill: none)
  set text(font: style.fonts.mono, size: 11pt)

  body

  if title != none {
    let cap = resolve-role(style, "caption")
    let cap-desc = resolve-role(style, "caption-desc")
    v(0.5em)
    align(center, text(font: resolve-font(style, cap), size: cap.text-size)[
      #if number != none [*Figure #number* --- ]
      *#title*
      #if description != none [
        \ #text(size: cap-desc.text-size, fill: luma(100), description)
      ]
    ])
  }
}
