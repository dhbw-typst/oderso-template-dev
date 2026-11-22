// LTeX: enabled=false
#import "../template/template/lib.typ": *
#import "../template/template/config/util.typ": (
  default-value, get-config, merge-configs,
)
#import "../template/template/config/resolve.typ": _resolve
#import "../template/template/render.typ": _compose-show-rules

#let ka = institution.dhbw-ka.frontbackmatter.ai-declaration
#let ma = institution.dhbw-ma.frontbackmatter.ai-declaration-form
#let entries = ((tool: "AI", usage: [Editing]),)
#let authors = (
  (
    product-name: "AI",
    topic: "Topic",
    topic-editing: "Editing",
    research: "Research",
    design: "Design",
  ),
)
#let merged = merge-configs((:), ka(entries: entries), ka(position: -20), ka(
  generator-function: cfg => none,
))
#assert.eq(merged.front-back-matter.ai-acknowledgement.entries, entries)
#assert.eq(
  merge-configs(merged, ka(entries: ()))
    .front-back-matter
    .ai-acknowledgement
    .entries,
  (),
)
#assert.eq(
  merge-configs((:), ma(authors: authors), ma(position: -10))
    .front-back-matter
    .ai-declaration-form
    .authors,
  authors,
)
#assert.eq(
  merge-configs((:), ma(authors: authors), ma(authors: ()))
    .front-back-matter
    .ai-declaration-form
    .authors,
  (),
)
#assert.eq(ka().front-back-matter.ai-acknowledgement, (:))
#assert.eq(ma().front-back-matter.ai-declaration-form, (:))
#assert.eq(get-config("a.b.c", "missing", (a: none)), "missing")
#assert.eq(get-config("a.b", "missing", (a: (b: none))), none)
#assert.eq(
  merge-configs((a: (x: 1, y: 2), list: (1, 2)), (a: (:), list: ())).a,
  (x: 1, y: 2),
)

#let margin = (top: 3cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm)
#assert.eq(
  _resolve(component.page(margin: 2.5cm), component.page(margin: (top: 3cm)))
    .resolved-sections
    .body
    .page
    .margin,
  margin,
)
#assert.eq(
  _resolve(component.page(margin: 2.5cm), component.body.page(margin: (
    top: 3cm,
  )))
    .resolved-sections
    .body
    .page
    .margin,
  margin,
)
#assert.eq(component.page(margin: (top: 3cm)).component.page.margin, (top: 3cm))
#assert.eq(
  _resolve(component.page(margin: (rest: 1cm, x: 2cm, y: 3cm, top: 4cm)))
    .resolved-sections
    .body
    .page
    .margin,
  (top: 4cm, bottom: 3cm, left: 2cm, right: 2cm),
)
#assert.eq(
  _resolve(component.page(margin: 2.5cm), component.body.page(margin: (
    inside: 3cm,
  )))
    .resolved-sections
    .body
    .page
    .margin,
  (top: 2.5cm, bottom: 2.5cm, inside: 3cm, outside: 2.5cm),
)
#assert.eq(
  _resolve(
    component.page(margin: (inside: 2cm, outside: 4cm)),
    component.body.page(margin: (left: 3cm)),
  )
    .resolved-sections
    .body
    .page
    .margin,
  (top: 0pt, bottom: 0pt, left: 3cm, right: 4cm),
)

#for (header, footer) in (
  (true, true),
  (true, false),
  (false, true),
  (false, false),
) {
  let cfg = _resolve(
    component.page(margin: 2cm),
    component.header(generator-function: (cfg, total) => [], height: 7mm),
    component.footer(generator-function: (cfg, total) => [], height: 13mm),
    component.body.header(enable: header),
    component.body.footer(enable: footer),
  )
  assert.eq(cfg.resolved-sections.body.reserved-margin, (
    top: 2cm + if header { 7mm } else { 0mm },
    bottom: 2cm + if footer { 13mm } else { 0mm },
    left: 2cm,
    right: 2cm,
  ))
}
#let suppressed = _resolve(
  component.header(generator-function: (cfg, total) => [], height: 7mm),
  component.body.header(generator-function: none),
)
#assert.eq(suppressed.resolved-sections.body.header.generator, none)
#assert("reserved-margin" not in suppressed.resolved-sections.body)

#let rules = (
  merge-configs(
    (:),
    component.show-rules(show-key: "first", show-order: 2, show-fun: it => (
      it + ("first",)
    )),
    component.show-rules(show-key: "second", show-order: 2, show-fun: it => (
      it + ("second",)
    )),
    component.show-rules(show-key: "first", show-order: 1),
  )
    .component
    .show-rules
)
#assert.eq(_compose-show-rules(rules)(()), ("first", "second"))
#assert.eq(
  _compose-show-rules((
    first: (order: 0, function: it => it + ("first",)),
    second: (order: 0, function: it => it + ("second",)),
  ))(()),
  ("first", "second"),
)
#let replaced = merge-configs(
  (component: (show-rules: rules)),
  component.show-rules(show-key: "first", show-fun: it => (
    it + ("replacement",)
  )),
)
#assert.eq(replaced.component.show-rules.first.order, 1)
#assert.eq(_compose-show-rules(replaced.component.show-rules)(()), (
  "replacement",
  "second",
))
#let disabled = merge-configs(replaced, component.show-rules(
  show-key: "first",
  show-enable: false,
))
#assert.eq(_compose-show-rules(disabled.component.show-rules)(()), ("second",))
#let cleared = merge-configs(replaced, component.show-rules(
  show-key: "second",
  show-fun: none,
))
#assert.eq(_compose-show-rules(cleared.component.show-rules)(()), (
  "replacement",
))
#assert.eq(
  _resolve(
    theme.spotless(show-total-pages: true),
    component.body.footer(show-total-pages: false),
  )
    .resolved-sections
    .body
    .footer
    .show-total-pages,
  false,
)
#assert.eq(_resolve().component.appendix.entries, ())
#assert.eq(_resolve().front-back-matter, (:))
#assert.eq(general.metadata(title-long: default-value).general.metadata, (:))
#for producer in (
  frontbackmatter.abbreviations,
  frontbackmatter.glossary,
  frontbackmatter.acknowledgements,
  frontbackmatter.abstracts,
  frontbackmatter.bibliography,
  frontbackmatter.figure-listings,
  frontbackmatter.toc,
  institution.dhbw-ka.frontbackmatter.statutory-declaration,
  institution.dhbw-ka.frontbackmatter.confidentiality-clause,
) {
  assert.eq(producer().front-back-matter.values().first(), (:))
  assert.eq(producer(enable: false).front-back-matter.values().first(), (
    enable: false,
  ))
}

Configuration assertions passed.
