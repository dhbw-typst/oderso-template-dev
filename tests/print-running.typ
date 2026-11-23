#import "../template/template/lib.typ": *
#let print = sys.inputs.at("print", default: "true") == "true"
#show: project.with(
  theme.spotless(),
  general.metadata(title-short: "RTITLE"),
  component.coversheet(generator-function: cfg => [Cover]),
  frontbackmatter.toc(enable: false),
  frontbackmatter.entry(
    "front",
    position: -1,
    generator-function: cfg => [Front],
  ),
  component.page(margin: (left: 25mm, right: 15mm, y: 25mm)),
  feature.print(enable: print),
)
= RCHAPTER
Body
#pagebreak()
Second page
