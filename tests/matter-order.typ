#import "../template/template/lib.typ": *
#let entry(name) = cfg => [#metadata(name)<render-order>#name]
#show: project.with(
  frontbackmatter.acknowledgements(
    position: -20,
    generator-function: entry("ack"),
  ),
  frontbackmatter.abstracts(
    position: -20,
    generator-function: entry("abstracts"),
  ),
  frontbackmatter.toc(position: -40, generator-function: entry("toc")),
  frontbackmatter.figure-listings(position: -10, generator-function: cfg => []),
  frontbackmatter.bibliography(
    position: 10,
    generator-function: entry("bibliography"),
  ),
  frontbackmatter.glossary(position: 0, generator-function: entry("glossary")),
  frontbackmatter.abbreviations(
    position: 10,
    generator-function: entry("abbreviations"),
  ),
)
#metadata("body")<render-order>
Body.
#context assert.eq(query(<render-order>).map(it => it.value), (
  "toc",
  "ack",
  "abstracts",
  "body",
  "glossary",
  "bibliography",
  "abbreviations",
))
