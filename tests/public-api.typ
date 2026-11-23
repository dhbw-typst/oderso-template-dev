#import "../template/template/lib.typ" as api

#assert.eq(
  dictionary(api).keys().sorted(),
  (
    "component",
    "dependency",
    "feature",
    "frontbackmatter",
    "general",
    "institution",
    "project",
    "theme",
    "util",
  ).sorted(),
)
#assert.eq(dictionary(api.dependency).keys().sorted(), (
  "codly",
  "drafting",
  "glossarium",
))

#for name in (
  "caption-with-source",
  "inline-glossary",
  "styled-table",
  "table-hline-spaced",
  "tablefigure",
  "tablefigure-raw",
) {
  assert(name not in api)
  assert.eq(type(dictionary(api.util).at(name)), function)
}
#assert.eq(type(api.dependency.codly.codly), function)
#assert.eq(type(api.dependency.drafting.inline-note), function)
#assert.eq(type(api.dependency.glossarium.gls), function)

#assert.eq(dictionary(api.general).keys().sorted(), (
  "layout",
  "metadata",
  "typography",
))
#assert.eq(dictionary(api.theme).keys().sorted(), ("shared", "spotless"))
#assert("academic" not in api.theme.shared)
#assert.eq(dictionary(api.frontbackmatter).keys().sorted(), (
  "abbreviations",
  "abstracts",
  "acknowledgements",
  "bibliography",
  "confidentiality-clause",
  "entry",
  "figure-listings",
  "glossary",
  "statutory-declaration",
  "toc",
))
#let matter-producers(module) = {
  dictionary(module)
    .keys()
    .filter(name => (
      not name.starts-with("_") and name != "config"
    ))
}
#assert.eq(matter-producers(api.institution.dhbw-ka.frontbackmatter), (
  "ai-declaration",
))
#assert.eq(matter-producers(api.institution.dhbw-ma.frontbackmatter), (
  "ai-declaration-form",
))
#assert.eq(dictionary(api.institution.ihk).keys(), ("setup",))

Each customization producer has one public namespace.
