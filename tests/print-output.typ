#import "../template/template/lib.typ": *
#import "../template/template/config/resolve.typ": _resolve
#let mode = sys.inputs.at("mode", default: "duplex")
#let cover = sys.inputs.at("cover", default: "true") == "true"
#let front = int(sys.inputs.at("front", default: "1"))
#let logical = sys.inputs.at("logical", default: "false") == "true"
#let binding = int(sys.inputs.at("binding", default: "3")) * 1mm
#let enabled = mode not in ("screen", "disabled", "later-disabled")
#let duplex = enabled and mode != "simplex"
#let base-margin = if logical {
  (top: 12mm, bottom: 14mm, inside: 10mm, outside: 20mm)
} else { (top: 12mm, bottom: 14mm, left: 10mm, right: 20mm) }
#let output = feature.print(
  two-sided: mode != "simplex",
  binding-space: binding,
)
#let final = if mode in ("later-disabled", "disabled") {
  feature.print(enable: false)
} else { (:) }
#let probe(name) = [
  XBOUND
  #context [#metadata((
    name: name,
    physical: here().page(),
    displayed: counter(page).get().first(),
  ))<print-page>]
]
#let layers = (
  component.page(margin: base-margin),
  general.layout(pagebreak-heading: true),
  component.body.page(margin: if logical { (inside: 15mm) } else {
    (left: 15mm)
  }),
  component.header(height: 7mm, generator-function: (cfg, _) => [CustomHeader]),
  component.footer(height: 9mm, generator-function: (cfg, _) => [CustomFooter]),
  component.coversheet(enable: cover, generator-function: cfg => probe(
    "cover",
  )),
  frontbackmatter.entry(
    "front",
    position: -1,
    enable: front > 0,
    generator-function: cfg => {
      for i in range(front) {
        pagebreak(weak: true)
        probe("front-" + str(i))
      }
    },
  ),
  frontbackmatter.entry("back", position: 1, generator-function: cfg => probe(
    "back",
  )),
  component.appendix.entries(appendices: (
    (title: "Annex", reference: "print-annex", text: probe("appendix")),
  )),
  general.metadata(digital-only: true, digital-submission: true),
  frontbackmatter.statutory-declaration(
    enable: false,
    digital-only: true,
    digital-submission: true,
  ),
  if mode == "screen" { (:) } else { output },
  final,
)
#let cfg = _resolve(..layers)
#assert.eq(cfg.general.metadata.digital-only, true)
#assert.eq(cfg.general.metadata.digital-submission, true)
#assert.eq(cfg.front-back-matter.statutory-declaration.digital-only, true)
#assert.eq(cfg.front-back-matter.statutory-declaration.digital-submission, true)
#assert.eq(cfg.resolved-sections.body.base-page.margin, if logical {
  (top: 12mm, bottom: 14mm, inside: 15mm, outside: 20mm)
} else { (top: 12mm, bottom: 14mm, left: 15mm, right: 20mm) })
#assert.eq(cfg.resolved-output.two-sided, duplex)
#assert.eq(cfg.resolved-sections.body.reserved-margin.top, 19mm)
#assert.eq(cfg.resolved-sections.body.reserved-margin.bottom, 23mm)
#let effective = cfg.resolved-sections.body.page.margin
#if enabled {
  assert.eq(
    effective.at(if duplex { "inside" } else { "left" }),
    15mm + binding,
  )
  assert.eq(effective.at(if duplex { "outside" } else { "right" }), 20mm)
} else { assert.eq(effective, cfg.resolved-sections.body.base-page.margin) }
#set page(width: 100mm, height: 140mm)
#set par(first-line-indent: 0pt)
#show: project.with(..layers)
= Chapter one <print-one>
#probe("body-one")
#pagebreak()
#probe("body-verso")
= Chapter two <print-two>
#probe("body-two")
#context {
  let one = query(<print-one>).first().location()
  let two = query(<print-two>).first().location()
  if duplex {
    assert(calc.odd(one.page()))
    assert(calc.odd(two.page()))
    assert(calc.odd(query(<print-annex>).first().location().page()))
  }
  assert.eq(counter(page).at(one).first(), 1)
  let pages = query(<print-page>).map(it => it.value)
  assert.eq(pages.filter(it => it.name.starts-with("front-")).len(), front)
  assert.eq(pages.filter(it => it.name == "cover").len(), if cover { 1 } else {
    0
  })
  assert.eq(pages.filter(it => it.name == "back").first().displayed, 1)
}
