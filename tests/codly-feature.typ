#import "../template/template/lib.typ": *
#let mode = sys.inputs.at("mode", default: "unthemed")
#let enabled = mode != "disabled"
#show: project.with(
  if mode == "theme" { theme.spotless() } else { (:) },
  component.coversheet(enable: false),
  frontbackmatter.toc(enable: false),
  feature.codly(
    display-icon: false,
    display-name: false,
    number-format: n => [#metadata(n)<codly-line>#n],
  ),
  feature.codly(enable: false),
  feature.codly(fill: yellow.lighten(80%)),
  if enabled { feature.codly(enable: true) } else { (:) },
  component.show-rules(show-key: "custom", show-order: 10, show-fun: it => {
    set text(fill: blue)
    it
  }),
)
```typ
#let a = 1
#let b = 2
```
#context assert.eq(query(<codly-line>).len(), if enabled { 2 } else { 0 })
