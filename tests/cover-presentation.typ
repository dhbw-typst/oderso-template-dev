#import "../template/template/lib.typ": *
#let mode = sys.inputs.at("mode", default: "computed")
#show: project.with(
  theme.spotless(),
  frontbackmatter.toc(enable: false),
  general.metadata(
    institution: "new-university",
    title-long: "Old title",
    authors: ((firstname: "New", lastname: "Author"),),
  ),
  component.page(margin: 2cm),
  if mode == "printing" { feature.print(binding-space: 5mm) } else { (:) },
  component.coversheet(
    presentation-generator: m => (
      submission-info: [Submitted to #m.institution: #m.title-long],
      misc-key-value: ([Final title], m.title-long),
    ),
    show-key: "cover-layout",
    show-fun: it => {
      set page(margin: 4cm, columns: 1)
      context assert.eq(page.margin, 4cm)
      it
    },
  ),
  general.metadata(title-long: "Final title"),
  if mode == "cleared" {
    general.metadata(submission-info: none, misc-key-value: ())
  } else { (:) },
  component.show-rules(show-key: "capture", show-fun: it => {
    show text: node => [#metadata(node.text)<presentation-text>#node]
    it
  }),
)
Body
#context {
  if mode == "printing" { assert.eq(page.margin.inside, 2cm + 5mm) } else {
    assert.eq(page.margin.left, 2cm)
  }
  let texts = query(<presentation-text>).map(it => it.value).join(" ")
  assert.eq(texts.contains("Submitted to"), mode != "cleared")
  assert(texts.contains("Final title"))
}
