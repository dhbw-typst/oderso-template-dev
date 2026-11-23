// Small internal resolver. Structural containers do not imply rendered content.
#import "util.typ": get-config, merge-config
#import "validation.typ" as validation
#import "../component/_shared.typ": _normalize-margin
#import "../feature/codly.typ": _codly-rule
#import "../feature/drafting.typ": _notes
#import "../feature/print.typ": _output-policy, _print-margin

#let _enabled(value) = (
  value.at("enable", default: true)
    and value.at("generator", default: none) != none
)

#let _validate-rules(rules) = {
  assert(
    type(rules) == dictionary,
    message: "`show-rules` must be a keyed dictionary",
  )
  for (key, rule) in rules {
    assert(
      type(rule) == dictionary,
      message: "Show rule " + key + " must be a dictionary",
    )
    validation.validate-enable(rule.at("enable", default: true))
    let order = rule.at("order", default: 0)
    assert(
      type(order) in (int, float),
      message: "Show rule " + key + " order must be numeric",
    )
    validation.validate-show(rule.at("function", default: none))
    assert(
      not rule.at("enable", default: true) or "function" in rule,
      message: "Enabled show rule "
        + key
        + " needs a callback; supply show-fun or disable the rule",
    )
  }
}

#let _validate-component(value, name) = {
  assert(type(value) == dictionary, message: name + " must be a dictionary")
  validation.validate-enable(value.at("enable", default: true))
  validation.validate-generator(value.at("generator", default: none))
  if "height" in value {
    validation.validate-relative(value.height, name + ".height")
  }
  if "show-total-pages" in value {
    validation.validate-enable(value.show-total-pages)
  }
  _validate-rules(value.at("show-rules", default: (:)))
}

#let _resolve-section(cfg, name) = {
  let local = get-config("component." + name, (:), cfg)
  assert(
    type(local) == dictionary,
    message: "Section " + name + " must be a dictionary",
  )
  let spec = (name: name, show-rules: local.at("show-rules", default: (:)))
  _validate-rules(spec.show-rules)
  for key in ("header", "footer", "page") {
    let shared = get-config("component." + key, (:), cfg)
    let patch = local.at(key, default: (:))
    assert(
      type(shared) == dictionary and type(patch) == dictionary,
      message: "Section " + name + "." + key + " must be a dictionary",
    )
    // Normalize each scope before merging: no shorthand can overwrite sides
    // that were not explicitly supplied in that scope.
    if key == "page" {
      if "margin" in shared { shared.margin = _normalize-margin(shared.margin) }
      if "margin" in patch { patch.margin = _normalize-margin(patch.margin) }
    }
    spec.insert(key, merge-config(shared, patch))
  }
  _validate-component(spec.header, name + ".header")
  _validate-component(spec.footer, name + ".footer")
  spec.page = merge-config((numbering: none), spec.page)
  // Preserve underlying configuration; print transforms only this derived view.
  spec.insert("base-page", spec.page)
  if cfg.resolved-output.print {
    let margin = spec.page.at("margin", default: (rest: 2.5cm))
    spec.page.insert("margin", _print-margin(
      _normalize-margin(margin),
      cfg.resolved-output,
    ))
  }
  validation.validate-numbering(spec.page.numbering)
  let top = if _enabled(spec.header) {
    spec.header.at("height", default: 0pt)
  } else { 0pt }
  let bottom = if _enabled(spec.footer) {
    spec.footer.at("height", default: 0pt)
  } else { 0pt }
  if "margin" in spec.page or top != 0pt or bottom != 0pt {
    let margin = spec.page.at("margin", default: (:))
    let horizontal = if "inside" in margin or "outside" in margin {
      ("inside", "outside")
    } else { ("left", "right") }
    let complete = (top: 0pt, bottom: 0pt)
    for side in horizontal { complete.insert(side, 0pt) }
    spec.page.margin = merge-config(complete, margin)
    spec.reserved-margin = spec.page.margin
    spec.reserved-margin.top += top
    spec.reserved-margin.bottom += bottom
  }
  spec
}

#let _resolve(..layers) = {
  let cfg = (
    general: (metadata: (:), typography: (:), layout: (:)),
    component: (appendix: (entries: ())),
    front-back-matter: (:),
    feature: (:),
  )
  for layer in layers.pos() {
    assert(
      type(layer) == dictionary,
      message: "Pass configuration dictionaries as positional project arguments",
    )
    cfg = merge-config(cfg, layer)
  }
  for key in ("general", "component", "front-back-matter", "feature") {
    assert(
      type(cfg.at(key)) == dictionary,
      message: key + " must be a dictionary",
    )
  }
  for key in ("metadata", "typography", "layout") {
    assert(
      type(cfg.general.at(key)) == dictionary,
      message: "general." + key + " must be a dictionary",
    )
  }
  for (name, settings) in cfg.feature {
    assert(
      type(settings) == dictionary,
      message: "Feature " + name + " must be a dictionary",
    )
    validation.validate-enable(settings.at("enable", default: true))
  }
  let code = cfg.feature.at("codly", default: (:))
  assert(
    type(code.at("options", default: (:))) == dictionary,
    message: "Codly options must be a dictionary",
  )
  if "codly" in cfg.feature and code.at("enable", default: true) {
    let defaults = (
      "feature-codly": (
        order: -2000,
        function: _codly-rule(
          code + (options: code.at("options", default: (:))),
        ),
      ),
    )
    cfg.component.insert("show-rules", merge-config(defaults, cfg.component.at(
      "show-rules",
      default: (:),
    )))
  }
  let drafting = cfg.feature.at("drafting", default: (:))
  let notes-position = drafting.at("notes-position", default: none)
  assert(
    notes-position == none or type(notes-position) == int,
    message: "`notes-position` must be an integer or none",
  )
  if (
    drafting.at("enable", default: true)
      and drafting.at("notes-listing", default: false)
      and notes-position != none
  ) {
    let defaults = (enable: true, position: notes-position, generator: _notes)
    cfg.front-back-matter.insert("drafting-notes", merge-config(
      defaults,
      cfg.front-back-matter.at("drafting-notes", default: (:)),
    ))
  }
  let printing = cfg.feature.at("print", default: (:))
  validation.validate-enable(printing.at("two-sided", default: true))
  validation.validate-relative(
    printing.at("binding-space", default: 0pt),
    "binding-space",
  )
  assert(
    printing.at("recto-chapters", default: auto) in (auto, true, false),
    message: "`recto-chapters` must be auto or boolean",
  )
  cfg.insert("resolved-output", _output-policy(cfg))
  let layout = cfg.general.layout
  if "pagebreak-heading" in layout {
    assert(
      layout.pagebreak-heading in (true, false, "even", "odd"),
      message: "`pagebreak-heading` must be true, false, even, or odd",
    )
  }
  for key in ("justify", "block-quotes") {
    if key in layout { validation.validate-enable(layout.at(key)) }
  }
  if "paper" in layout {
    assert(type(layout.paper) == str, message: "`paper` must be a string")
  }
  validation.validate-generator(drafting.at(
    "watermark-generator",
    default: none,
  ))
  validation.validate-enable(drafting.at(
    "notes-listing",
    default: false,
  ))
  for (_, typography) in cfg.general.typography {
    validation.validate-typography(typography)
  }
  _validate-rules(cfg.component.at("show-rules", default: (:)))
  _validate-component(
    cfg.component.at("coversheet", default: (:)),
    "coversheet",
  )
  validation.validate-generator(get-config(
    "component.coversheet.presentation-generator",
    none,
    cfg,
  ))
  for (name, entry) in cfg.front-back-matter {
    _validate-component(entry, "Matter entry " + name)
    if "position" in entry { validation.validate-position(entry.position) }
    for key in ("entries", "authors") {
      if key in entry {
        assert(
          type(entry.at(key)) == array,
          message: "Matter " + name + "." + key + " must be an array",
        )
      }
    }
  }
  assert(
    type(cfg.component.appendix) == dictionary,
    message: "component.appendix must be a dictionary",
  )
  let appendix = cfg.component.appendix
  assert(
    type(appendix.entries) == array,
    message: "Appendix entries must be an array",
  )
  for entry in appendix.entries {
    assert(
      type(entry) == dictionary and "title" in entry and "text" in entry,
      message: "Each appendix entry needs title and text",
    )
    assert(
      entry.at("reference", default: none) == none
        or type(entry.reference) == str,
      message: "Appendix reference must be a string or none",
    )
  }
  _validate-component(appendix.at("toc", default: (:)), "appendix.toc")
  let sections = (:)
  for name in ("frontmatter", "body", "backmatter", "appendix") {
    sections.insert(name, _resolve-section(cfg, name))
  }
  cfg.insert("resolved-sections", sections)
  cfg
}
