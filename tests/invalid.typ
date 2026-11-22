#import "../template/template/lib.typ": *
#let case = sys.inputs.at("case")
#let patch = (
  if case == "margin-auto" { component.page(margin: auto) } else if case
    == "margin-side-auto" { component.page(margin: (top: auto)) } else if case
    == "margin-mixed" {
    component.page(margin: (left: 1cm, inside: 2cm))
  } else if case == "margin-key" {
    component.page(margin: (topp: 1cm))
  } else if case == "numbering" {
    component.body.page(numbering: 1)
  } else if case == "heading-break" {
    general.layout(pagebreak-heading: "next")
  } else if case == "font" { general.typography.body(font: (1,)) } else if case
    == "sizes" { general.typography.heading(sizes: 14pt) } else if case
    == "generator" {
    component.footer(generator-function: "footer")
  } else if case == "rule-order" {
    component.show-rules(show-key: "key", show-order: "early")
  } else if case == "rule-missing" {
    component.show-rules(show-key: "key", show-order: 2)
  } else if case == "shape" { (component: (body: none)) } else if case
    == "cover-authors" { theme.spotless() } else if case
    == "declaration-authors" {
    institution.dhbw-ka.setup(authors: ())
  } else if case == "course" {
    institution.dhbw-ka.setup(authors: (
      (firstname: "Name", lastname: "Surname", course: "invalid"),
    ))
  } else { panic("Unknown invalid case") }
)
#show: project.with(patch)
Invalid configuration must not compile.
