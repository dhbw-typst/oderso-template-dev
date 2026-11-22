// Layout assertions execute inside components, not at configuration time.
#import "../template/template/lib.typ": *
#let front = int(sys.inputs.at("front", default: "0"))
#let back = int(sys.inputs.at("back", default: "0"))
#let appendix = sys.inputs.at("appendix", default: "false") == "true"
#let header = sys.inputs.at("header", default: "true") == "true"
#let footer = sys.inputs.at("footer", default: "true") == "true"
#let totals = (frontmatter: front, body: 2, backmatter: back, appendix: 2)
#let global-rule(it) = {
  set text(fill: black)
  it
}
#let local-rule(fill) = it => {
  set text(fill: fill)
  it
}
#let section-rule(it) = {
  set par(spacing: 12pt)
  it
}
#let header-gen(cfg, total) = context {
  assert.eq(text.fill, red)
  assert.eq(total, totals.at(cfg.resolved-section.name))
  assert.eq(cfg.resolved-section.header.height, 7mm)
  metadata((kind: "header", section: cfg.resolved-section.name))
  [Header]
}
#let footer-gen(cfg, total) = context {
  assert.eq(text.fill, blue)
  assert.eq(total, totals.at(cfg.resolved-section.name))
  assert.eq(cfg.resolved-section.footer.height, 13mm)
  metadata((kind: "footer", section: cfg.resolved-section.name))
  [Footer]
}
#let pages(count, spacing) = {
  for i in range(count) {
    if i > 0 { pagebreak() }
    context {
      assert.eq(text.fill, black)
      assert.eq(par.spacing, spacing)
    }
    [Matter page #i.]
  }
}
#show: project.with(
  component.page(margin: 2cm),
  component.show-rules(show-key: "global", show-fun: global-rule),
  component.header(
    enable: header,
    height: 7mm,
    generator-function: header-gen,
    show-key: "header",
    show-fun: local-rule(red),
  ),
  component.footer(
    enable: footer,
    height: 13mm,
    generator-function: footer-gen,
    show-key: "footer",
    show-fun: local-rule(blue),
  ),
  component.body.show-rules(show-key: "body", show-fun: section-rule),
  component.frontmatter.show-rules(show-key: "front", show-fun: it => {
    set par(spacing: 21pt)
    it
  }),
  component.backmatter.show-rules(show-key: "back", show-fun: it => {
    set par(spacing: 31pt)
    it
  }),
  component.appendix.show-rules(show-key: "appendix", show-fun: it => {
    set par(spacing: 41pt)
    it
  }),
  frontbackmatter.acknowledgements(
    position: -1,
    generator-function: cfg => if front > 0 { pages(front, 21pt) },
  ),
  frontbackmatter.abstracts(position: 1, generator-function: cfg => if back
    > 0 { pages(back, 31pt) }),
  component.appendix.entries(appendices: if appendix {
    (
      (
        title: [Unreferenced],
        text: [#context assert.eq(par.spacing, 41pt) First appendix.],
      ),
      (
        title: [Referenced],
        reference: "test-appendix",
        text: [Second appendix.],
      ),
    )
  } else { () }),
  component.appendix.toc(
    generator-function: cfg => context {
      assert.eq(text.fill, purple)
      metadata((kind: "toc"))
    },
    show-key: "toc",
    show-fun: local-rule(purple),
  ),
)

Body first page.
#context {
  assert.eq(par.spacing, 12pt)
  assert.eq(text.fill, black)
}
#pagebreak()
Body second page.
#context {
  assert.eq(counter(page).at(<_body-end>).first(), 2)
  assert.eq(query(<_frontmatter-end>).len(), if front > 0 { 1 } else { 0 })
  assert.eq(query(<_backmatter-end>).len(), if back > 0 { 1 } else { 0 })
  assert.eq(query(<_appendix-end>).len(), if appendix { 1 } else { 0 })
  if appendix { assert.eq(query(<test-appendix>).len(), 1) }
  let markers = query(metadata)
    .map(it => it.value)
    .filter(value => type(value) == dictionary and "kind" in value)
  assert.eq(markers.filter(v => v.kind == "header").len(), if header {
    front + 2 + back + if appendix { 2 } else { 0 }
  } else { 0 })
  assert.eq(markers.filter(v => v.kind == "footer").len(), if footer {
    front + 2 + back + if appendix { 2 } else { 0 }
  } else { 0 })
  assert.eq(markers.filter(v => v.kind == "toc").len(), if appendix { 1 } else {
    0
  })
}
