#import "../template/template/lib.typ": *
#import dependency: drafting
#let mode = sys.inputs.at("mode", default: "before-cover")
#let enabled = mode != "disabled"
#show: project.with(
  theme.shared.watermark(),
  theme.shared.notes(),
  component.page(margin: 2cm),
  component.coversheet(generator-function: cfg => [Cover <draft-cover>]),
  feature.drafting(watermark: [DraftWatermark], notes-listing: true),
  feature.drafting(enable: false),
  feature.drafting(notes-position: if mode in ("matter", "empty") { 10 } else {
    none
  }),
  if enabled { feature.drafting(enable: true) } else { (:) },
  frontbackmatter.entry("drafting-notes", show-key: "notes", show-fun: it => {
    set text(fill: green)
    it
  }),
  component.show-rules(show-key: "capture", show-fun: it => {
    show text: node => [#metadata(node.text)<draft-text>#node]
    it
  }),
)
Body <draft-body>
#if mode != "empty" { dependency.drafting.inline-note[An editing note] }
#context {
  let texts = query(<draft-text>).map(it => it.value).join(" ")
  assert.eq(texts.contains("DraftWatermark"), enabled)
  let cover = query(<draft-cover>).first().location().page()
  let body = query(<draft-body>).first().location().page()
  assert.eq(cover, if mode == "before-cover" { 2 } else { 1 })
  assert(body > cover)
  if mode == "empty" {
    assert.eq(query(<_backmatter-end>).first().location().page(), body)
    assert.eq(query(<inline-note>).len(), 0)
  }
}
