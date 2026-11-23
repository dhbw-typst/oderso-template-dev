#import "../template/template/lib.typ": *
#import "../template/template/config/resolve.typ": _resolve
#let rule = it => {
  set text(fill: red)
  it
}
#let patch = frontbackmatter.entry("first", show-key: "local", show-fun: rule)
#let cfg = _resolve(patch, frontbackmatter.entry(
  "first",
  show-key: "local",
  show-order: 7,
))
#assert.eq(cfg.front-back-matter.first.show-rules.local.function, rule)
#assert.eq(cfg.front-back-matter.first.show-rules.local.order, 7)
#for producer in (
  frontbackmatter.glossary,
  frontbackmatter.abbreviations,
  frontbackmatter.toc,
  frontbackmatter.acknowledgements,
  frontbackmatter.abstracts,
  frontbackmatter.bibliography,
  frontbackmatter.figure-listings,
  frontbackmatter.statutory-declaration,
  frontbackmatter.confidentiality-clause,
  institution.dhbw-ka.frontbackmatter.ai-declaration,
  institution.dhbw-ma.frontbackmatter.ai-declaration-form,
) {
  assert.eq(
    producer(show-key: "local", show-fun: rule)
      .front-back-matter
      .values()
      .first()
      .show-rules
      .local
      .function,
    rule,
  )
}
#let skip = it => panic("Skipped content must not invoke hooks")
#show: project.with(
  component.show-rules(show-key: "global", show-fun: it => {
    set text(fill: black)
    it
  }),
  component.frontmatter.show-rules(show-key: "section", show-fun: it => {
    set text(fill: blue)
    it
  }),
  patch,
  frontbackmatter.entry("first", position: -2, generator-function: cfg => [
    #context {
      assert.eq(text.fill, red)
      assert.eq(cfg.resolved-section.name, "frontmatter")
    }
    #metadata("first")<matter-hook>First
  ]),
  frontbackmatter.entry(
    "second",
    position: -1,
    show-key: "local",
    show-fun: rule,
    generator-function: cfg => [#context assert.eq(text.fill, blue) Second],
  ),
  frontbackmatter.entry("second", show-key: "local", show-enable: false),
  frontbackmatter.entry(
    "third",
    position: 1,
    show-key: "local",
    show-fun: rule,
    generator-function: cfg => [#context assert.eq(text.fill, green) Third],
  ),
  frontbackmatter.entry("third", show-key: "local", show-fun: it => {
    set text(fill: green)
    it
  }),
  frontbackmatter.entry(
    "empty",
    position: -5,
    generator-function: cfg => [],
    show-key: "skip",
    show-fun: skip,
  ),
  frontbackmatter.entry(
    "none",
    position: -5,
    generator-function: cfg => none,
    show-key: "skip",
    show-fun: skip,
  ),
  frontbackmatter.entry(
    "disabled",
    position: -5,
    enable: false,
    generator-function: cfg => panic("Disabled"),
    show-key: "skip",
    show-fun: skip,
  ),
  frontbackmatter.entry(
    "cleared",
    position: -5,
    generator-function: none,
    show-key: "skip",
    show-fun: skip,
  ),
)
#context {
  assert.eq(text.fill, black)
  assert.eq(query(<matter-hook>).len(), 1)
}
Body
