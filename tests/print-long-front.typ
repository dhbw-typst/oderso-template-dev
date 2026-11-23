#import "../template/template/lib.typ": *
#show: project.with(
  component.page(margin: 2cm),
  component.coversheet(generator-function: cfg => [Cover]),
  frontbackmatter.entry("long", position: -1, generator-function: cfg => [
    Long frontmatter <long-front>
    #lorem(1500)
  ]),
  feature.print(),
)
= Body <long-front-body>
#context {
  let body = query(<long-front-body>).first().location()
  assert(body.page() > 4)
  assert(calc.odd(body.page()))
  assert.eq(counter(page).at(body).first(), 1)
}
