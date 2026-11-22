#import "../template/template/lib.typ": *
#let unexpected(..args) = panic("Disabled generator was called")
#show: project.with(
  component.header(generator-function: unexpected, height: 1cm),
  component.footer(generator-function: unexpected, height: 2cm),
  component.body.header(enable: false),
  component.body.footer(generator-function: none),
  component.coversheet(generator-function: unexpected),
  component.coversheet(enable: false),
  frontbackmatter.acknowledgements(
    position: -1,
    generator-function: unexpected,
  ),
  frontbackmatter.acknowledgements(enable: false),
  frontbackmatter.abstracts(position: 1, generator-function: unexpected),
  frontbackmatter.abstracts(generator-function: none),
  component.appendix.entries(appendices: (
    (title: [Appendix], text: [Appendix content.]),
  )),
  component.appendix.header(enable: false),
  component.appendix.footer(enable: false),
  component.appendix.toc(generator-function: unexpected),
  component.appendix.toc(enable: false),
  component.show-rules(show-key: "disabled", show-fun: unexpected),
  component.show-rules(show-key: "disabled", show-enable: false),
)
Body.
#context {
  assert.eq(query(<_frontmatter-end>).len(), 0)
  assert.eq(query(<_backmatter-end>).len(), 0)
  assert.eq(counter(page).at(<_body-end>).first(), 1)
  assert.eq(counter(page).at(<_appendix-end>).first(), 1)
}
