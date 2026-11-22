#import "../template/template/lib.typ": *
#let mode = sys.inputs.at("mode", default: "default")
#show: project.with(
  theme.spotless(),
  component.coversheet(enable: false),
  frontbackmatter.toc(enable: false),
  general.drafting(watermark: [DefaultWatermark]),
  if mode == "replacement" {
    general.drafting(watermark-generator: cfg => [ReplacementWatermark])
  } else if mode == "none" {
    general.drafting(watermark-generator: none)
  } else { (:) },
  component.show-rules(show-key: "capture", show-fun: it => {
    show text: node => [#metadata(node.text)<rendered-text>#node]
    it
  }),
)
Body.
#context {
  let texts = query(<rendered-text>).map(it => it.value).join("")
  assert.eq(texts.contains("DefaultWatermark"), mode == "default")
  assert.eq(texts.contains("ReplacementWatermark"), mode == "replacement")
}
