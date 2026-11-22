// Bibliography and glossarium integrations, including inline glossary output.
#import "../template/template/lib.typ": (
  component, frontbackmatter, general, project, theme, util,
)

#let abbreviations = (
  (key: "api", short: "API", long: "Application Programming Interface"),
)
#let glossary = (
  (
    key: "regression",
    short: "regression test",
    description: [A repeatable check that detects unintended changes.],
    group: "Testing",
  ),
)

#show: project.with(
  theme.spotless(),
  component.coversheet(enable: false),
  frontbackmatter.toc(enable: false),
  general.layout(pagebreak-heading: false),
  frontbackmatter.bibliography(library: bibliography(
    "assets/references.bib",
    style: "ieee",
  )),
  frontbackmatter.abbreviations(abbreviations: abbreviations),
  frontbackmatter.glossary(glossary: glossary),
)

= Citations and references

A reproducible document build is a useful @regression. The @api is introduced
with its long form on first use and shortened on the next reference: @api.

Knuth describes a typesetting system in @knuth1984. A separate reference
describes literate programming @knuth1992.

$ sum_(k=1)^n k = (n(n + 1)) / 2 $ <sum-equation>

The theme formats the reference to @sum-equation using IEEE-style parentheses.

== Inline definitions

#util.inline-glossary(glossary, ("Testing",), show-all: true)

The regular glossary and abbreviation list are also rendered in the back
matter, followed by the bibliography. Inline definitions do not add glossary
back-references.
