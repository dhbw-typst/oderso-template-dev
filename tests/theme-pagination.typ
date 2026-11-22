#import "../template/template/lib.typ": *
#show: project.with(
  theme.spotless(),
  component.coversheet(enable: false),
  component.body.header(enable: false),
  frontbackmatter.toc(enable: false),
  frontbackmatter.acknowledgements(
    position: -1,
    generator-function: cfg => [Front matter.],
  ),
  frontbackmatter.abstracts(
    position: 1,
    generator-function: cfg => [Back matter.],
  ),
  component.frontmatter.footer(show-key: "front-footer", show-fun: it => {
    show text: node => [#metadata(node.text)<front-footer-text>#node]
    it
  }),
  component.backmatter.footer(show-key: "back-footer", show-fun: it => {
    show text: node => [#metadata(node.text)<back-footer-text>#node]
    it
  }),
)
Body.
#context {
  assert.eq(query(<front-footer-text>).map(it => it.value).join(""), "I")
  assert.eq(query(<back-footer-text>).map(it => it.value).join(""), "a")
  assert.eq(counter(page).at(<_frontmatter-end>).first(), 1)
  assert.eq(counter(page).at(<_body-end>).first(), 1)
  assert.eq(counter(page).at(<_backmatter-end>).first(), 1)
}
