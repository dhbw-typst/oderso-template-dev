#import "@preview/tidy:0.4.3"
#import "template/utils.typ": *

#let show-module(parsed) = {
tidy.show-module(
  parsed,
  first-heading-level: 0,
  show-outline: false,
  style: tidy.styles.default,
  omit-private-definitions: true,
  omit-private-parameters: true,
)
}

#{
  v(5em)
  align(center, heading(text("ODERSO", size: 2em), outlined: false))
  v(1em)
  align(center, text("Organized Documentation for Experimental Research and Scientific Outputs", size: 1em, fill: luma(100)))
  v(2em)
  align(center, grid(
    columns: 2,
    column-gutter: 5em,
    sys.inputs.at("version", default: "v?.?.?"),
    datetime.today().display("[month repr:long] [day], [year]")
  ))
  align(center, text(underline(link("https://github.com/dhbw-typst/oderso-template"))))
  v(2em)
  place(center + horizon, pad(text([
    *ODERSO* is a Typst template for the *DHBW Karlruhe* with adapters for the *DHBW Mannheim* and *IHK*. It follows a clean academic design and uses IEEE standards where applicable.
  ]), x: 20%))


  align(bottom, pad(outline(depth: 1), x: 20%))
  pagebreak()
}


#let base-docs = tidy.parse-module(
  read("template/template/base.typ")
)

#show-module(base-docs)

#let adapters = (
  "dhbw-ka.typ",
  "dhbw-ma.typ",
  "ihk.typ"
)

#for adapter in adapters {
  let adapter-docs = tidy.parse-module(
    read("template/template/" + adapter)
  )

  show-module(adapter-docs)
}

#let utils-docs = tidy.parse-module(
  read("template/utils.typ"),
  scope: (
    codefigure: codefigure,
    codefigurefile: codefigurefile,
    hr: hr,
    caption-with-source: caption-with-source,
    table-hline-spaced: table-hline-spaced,
    tablefigure-raw: tablefigure-raw,
    styled-table: styled-table,
    tablefigure: tablefigure,
  ),
)

#show-module(utils-docs)
