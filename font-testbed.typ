= Font Comparison

This document provides a testbed to adjust the size and spacing of different fonts to a baseline. The used baseline is Arial with a text size and spacing adjusted to match 12pt and 1.5 line spacing in word. See #underline(link("https://github.com/dhbw-typst/oderso-template-dev/pull/64")[here]) for more info.

#let arial = (
  font: "Arial",
  size: 12.04pt,
  spacing: 1.5em,
  leading: 1em,
)

#let show-arial = false

#let fonts = (
  new-computer-modern: (
    font: "New Computer Modern",
    size: 12.4pt,
    spacing: 1.47em,
    leading: 0.985em,
    char-spacing: 80%,
    tracking: -0.08pt,
  ),
  libertinus-serif: (
    font: "Libertinus Serif",
    size: 13.2pt,
    spacing: 1.366em,
    leading: 0.905em,
    char-spacing: 90%,
    tracking: -0.1pt,
  ),
)

#let body = [
  #box(height: 200pt, {
    lorem(100)
  })

  A paragraph with a few words

  Another paragraph

  And a third paragraph
]

#for (_, font) in fonts {
  pagebreak()

  let font-a(body) = {
    set text(font: font.font, size: font.size, spacing: font.char-spacing, tracking: font.tracking)
    set par(spacing: font.spacing, leading: font.leading)
    body
  }

  let font-b(body) = {
    set text(font: arial.font, size: arial.size)
    set par(spacing: arial.spacing, leading: arial.leading)
    body
  }

  set page(
    background: place(top + left, float: true, scope: "column", pad(rest: 2cm, {
      show: font-b.with()
      set text(fill: red)
      if show-arial {
        body
      }
    })),
    foreground: place(top + left, float: true, scope: "column", pad(rest: 2cm, {
      show: font-a.with()
      set text(fill: black.transparentize(30%))
      body
    })),
  )
}






