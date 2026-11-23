#import "../template/template/lib.typ": *
#let mode = sys.inputs.at("mode", default: "string")
#let total = sys.inputs.at("total", default: "false") == "true"
#let fmt = if mode == "none" { none } else if mode == "function" {
  (n, last) => {
    assert.eq(last, 2)
    "Page" + str(n)
  }
} else { "i" }
#show: project.with(
  theme.spotless(),
  component.body.footer(show-total-pages: not total),
  component.coversheet(enable: false),
  component.body.header(enable: false),
  frontbackmatter.toc(enable: false),
  component.body.page(numbering: fmt),
  component.body.footer(
    show-total-pages: total,
    show-key: "capture-footer",
    show-fun: it => {
      show text: node => [#metadata(node.text)<footer-text>#node]
      it
    },
  ),
)
First page.
#pagebreak()
Second page.
#context {
  let texts = query(<footer-text>)
    .map(it => it.value)
    .fold("", (acc, value) => acc + value)
  if mode == "none" { assert.eq(texts, "") } else {
    assert(texts.contains(if mode == "function" { "Page1" } else { "i" }))
    assert(texts.contains(if mode == "function" { "Page2" } else { "ii" }))
    assert.eq(texts.contains("/"), total)
  }
}
