#import "../template/template/lib.typ": *
#let case = sys.inputs.at("case")
#show: project.with(if case == "enable" {
  feature.codly(enable: "yes")
} else if case == "options" {
  (feature: (codly: (options: (1,))))
} else if case == "codly-option" {
  feature.codly(nonexistent-option: true)
} else if case == "notes-position" {
  feature.drafting(notes-position: "body")
} else if case == "binding" {
  feature.print(binding-space: none)
} else if case == "recto" {
  feature.print(recto-chapters: "odd")
} else if case == "presentation" {
  component.coversheet(
    generator-function: cfg => [],
    presentation-generator: "no",
  )
} else if case == "matter-rule" {
  frontbackmatter.entry("custom", show-key: "missing", show-order: 1)
} else if case == "theme-option" {
  theme.spotless(show-total-pages: true)
} else { panic("Unknown case") })
Invalid features
