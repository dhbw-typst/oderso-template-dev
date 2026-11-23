#import "../template/template/lib.typ": *
#let mode = sys.inputs.at("mode", default: "neither")
#let layers = if mode == "theme" {
  (
    theme.spotless(),
    component.coversheet(enable: false),
    frontbackmatter.toc(enable: false),
  )
} else if mode == "institution" or mode in ("ka", "ma", "ihk") {
  let institution = if mode == "ma" { institution.dhbw-ma } else if (
    mode == "ihk"
  ) { institution.ihk } else { institution.dhbw-ka }
  (
    institution.setup(authors: ()),
    frontbackmatter.statutory-declaration(enable: false),
    frontbackmatter.confidentiality-clause(enable: false),
  )
} else { () }
#show: project.with(..layers)
Minimal body.
#context {
  assert.eq(counter(page).final().first(), 1)
  assert.eq(query(<_frontmatter-end>).len(), 0)
  assert.eq(query(<_backmatter-end>).len(), 0)
  assert.eq(query(<_appendix-end>).len(), 0)
}
