#import "../template/template/lib.typ": *
#show: project.with(
  theme.spotless(),
  institution.dhbw-ka.setup(authors: (
    (firstname: "Name", lastname: "Surname"),
  )),
  institution.dhbw-ka.frontbackmatter.statutory-declaration(enable: false),
  institution
    .dhbw-ka
    .frontbackmatter
    .confidentiality-clause(generator-function: none),
  general.metadata(
    submission-info: [#context assert.eq(text.fill, green) CustomSubmission],
    misc-key-value: ([Key], [CustomValue]),
  ),
  component.coversheet(show-key: "cover", show-fun: it => {
    set text(fill: green)
    it
  }),
  component.show-rules(show-key: "capture", show-fun: it => {
    set text(fill: black)
    show text: node => [#metadata(node.text)<rendered-text>#node]
    it
  }),
)
Body.
#context {
  assert.eq(text.fill, black)
  let texts = query(<rendered-text>).map(it => it.value).join(" ")
  assert(texts.contains("CustomSubmission"))
  assert(texts.contains("CustomValue"))
}
