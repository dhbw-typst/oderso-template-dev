// Private shared section rendering. Generator signatures remain unchanged.
#import "config/resolve.typ": _enabled

#let _compose-show-rules(rules) = {
  // Stable, explicit insertion-index tie breaking; patched keys keep their slot.
  let sorted = rules
    .pairs()
    .enumerate()
    .filter(((index, pair)) => (
      pair.at(1).at("enable", default: true)
        and pair.at(1).at("function", default: none) != none
    ))
    .sorted(key: ((index, pair)) => (pair.at(1).at("order", default: 0), index))
  it => {
    let result = it
    for (_, pair) in sorted { result = (pair.at(1).function)(result) }
    result
  }
}

// Drafting 0.2.2 fails with equal margins. Keep this tiny adjustment solely at
// the rendering boundary, never in resolved user configuration.
#let _transform-margin(margin) = {
  if margin.values().all(value => value == margin.top) { margin.top += 0.01pt }
  margin
}

#let _render-section(cfg, name, end-label, body) = {
  let spec = cfg.resolved-sections.at(name)
  let local-cfg = cfg + (resolved-section: spec)
  let component-content(component) = context {
    let total = counter(page).at(end-label).first()
    _compose-show-rules(component.at("show-rules", default: (:)))((
      component.generator
    )(local-cfg, total))
  }
  pagebreak(weak: true, to: if cfg.resolved-output.two-sided
    and name in ("body", "appendix")
    and cfg.resolved-output.pagebreak-heading == "odd" { "odd" } else { none })
  counter(page).update(1)
  set page(
    numbering: spec.page.numbering,
    header: if _enabled(spec.header) { component-content(spec.header) } else {
      none
    },
    footer: if _enabled(spec.footer) { component-content(spec.footer) } else {
      none
    },
  )
  show: set page(margin: _transform-margin(spec.reserved-margin)) if (
    "reserved-margin" in spec
  )
  show: _compose-show-rules(spec.show-rules)
  body(local-cfg)
  // Label the actual zero-size element, not a context wrapper.
  [#metadata(name)#end-label]
  pagebreak(weak: true)
}

#let _matter(cfg, name) = {
  let entries = cfg
    .front-back-matter
    .pairs()
    .enumerate()
    .filter(((index, pair)) => {
      let entry = pair.at(1)
      (
        _enabled(entry)
          and type(entry.at("position", default: none)) == int
          and (
            if name == "frontmatter" { entry.position < 0 } else {
              entry.position >= 0
            }
          )
      )
    })
    .sorted(key: ((index, pair)) => (pair.at(1).position, index))
  let rendered = ()
  let local-cfg = cfg + (resolved-section: cfg.resolved-sections.at(name))
  for (_, pair) in entries {
    let entry = pair.at(1)
    let content = (entry.generator)(local-cfg)
    if content != none and content != [] {
      rendered.push(
        _compose-show-rules(entry.at("show-rules", default: (:)))(content),
      )
    }
  }
  rendered
}
