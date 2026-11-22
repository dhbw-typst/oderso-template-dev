// LTeX: enabled=false
#import "@preview/glossarium:0.5.10": make-glossary, register-glossary
#import "@preview/codly:1.3.0": codly-init
#import "@preview/drafting:0.2.2": note-outline
#import "@preview/linguify:0.5.0": load-ftl-data, set-database
#import "config/lib.typ" as config
#import "config/resolve.typ": _enabled, _resolve
#import "config/state.typ": _config, _in-outline
#import "render.typ": _compose-show-rules, _matter, _render-section

/// Compose pure configuration dictionaries in positional order, then render.
/// Structural defaults come first; theme, institution, and user patches follow
/// in the supplied order. Dictionaries merge recursively, arrays replace, and
/// omitted sentinel arguments inherit. No theme is implicitly installed.
///
/// Existing generators keep `(cfg)` or `(cfg, last-page)` signatures. Section
/// generators can read `cfg.resolved-section` (name, page, header, footer, rules).
/// -> content
#let project(
  /// Ordered configuration dictionaries from themes, institutions, and patches.
  ..cfgs,
  /// Document body. -> content
  body,
) = {
  assert(
    cfgs.named().len() == 0,
    message: "Only positional configuration arguments are allowed",
  )
  let cfg = _resolve(..cfgs.pos())
  _config.update(cfg)

  show: set text(lang: cfg.general.metadata.lang) if (
    "lang" in cfg.general.metadata
  )
  set-database(eval(load-ftl-data("l10n", ("en", "de"))))
  set bibliography(title: config.util.linguify-content("bibliography"))
  set document(title: cfg.general.metadata.at("title-long", default: none))

  let typography = cfg.general.typography
  let t-body = typography.at("body", default: (:))
  let t-heading = typography.at("heading", default: (:))
  let t-caption = typography.at("caption", default: (:))
  let t-code = typography.at("code", default: (:))
  let t-math = typography.at("math", default: (:))
  show: set text(font: t-body.font) if "font" in t-body
  show: set text(size: t-body.size) if "size" in t-body
  show: set par(leading: t-body.leading) if "leading" in t-body
  show: set par(spacing: t-body.spacing) if "spacing" in t-body
  let layout = cfg.general.layout
  show: set page(paper: layout.paper) if "paper" in layout
  show: set par(justify: layout.justify) if "justify" in layout
  show: set quote(block: layout.block-quotes) if "block-quotes" in layout
  let watermark = cfg.general.drafting.at("watermark-generator", default: none)
  set page(background: if watermark != none { watermark(cfg) })

  show heading: set text(font: t-heading.font) if "font" in t-heading
  show: set heading(numbering: t-heading.numbering) if "numbering" in t-heading
  let sizes = t-heading.at("sizes", default: ())
  show heading.where(level: 1): set text(size: sizes.at(0)) if sizes.len() > 0
  show heading.where(level: 2): set text(size: sizes.at(1)) if sizes.len() > 1
  show heading.where(level: 3): set text(size: sizes.at(2)) if sizes.len() > 2
  show heading.where(level: 4): set text(size: sizes.at(3)) if sizes.len() > 3
  show heading.where(level: 5): set text(size: sizes.at(4)) if sizes.len() > 4
  show heading.where(level: 6): set text(size: sizes.at(5)) if sizes.len() > 5
  show raw: set text(font: t-code.font) if "font" in t-code
  show raw: set text(size: t-code.size) if "size" in t-code
  show figure.caption: set text(font: t-caption.font) if "font" in t-caption
  show figure.caption: set text(size: t-caption.size) if "size" in t-caption
  show math.equation: set text(font: t-math.font) if "font" in t-math
  show math.equation: set text(size: t-math.size) if "size" in t-math

  // Package integration stays structural; appearance belongs to presets.
  show: codly-init.with()
  show figure.where(kind: raw): set block(breakable: true)
  show outline: it => {
    _in-outline.update(true)
    it
    _in-outline.update(false)
  }
  show: make-glossary
  for name in ("abbreviations", "glossary") {
    let entry = cfg.front-back-matter.at(name, default: (:))
    let entries = entry.at("entries", default: ())
    if entry.at("enable", default: true) and entries.len() > 0 {
      register-glossary(entries)
    }
  }
  show: _compose-show-rules(cfg.component.at("show-rules", default: (:)))

  context if (
    cfg.general.drafting.at("notes-listing", default: false)
      and query(selector(<margin-note>).or(<inline-note>)).len() > 0
  ) {
    set heading(numbering: none, outlined: false)
    note-outline(title: config.util.linguify-content("list-of-notes"))
    pagebreak()
  }

  let cover = cfg.component.at("coversheet", default: (:))
  if _enabled(cover) {
    // Cover hooks do not leak into subsequent sections.
    show: _compose-show-rules(cover.at("show-rules", default: (:)))
    (cover.generator)(cfg)
    pagebreak(weak: true)
  }
  let frontmatter = _matter(cfg, "frontmatter")
  if frontmatter.len() > 0 {
    _render-section(cfg, "frontmatter", <_frontmatter-end>, local-cfg => {
      set heading(numbering: none)
      for entry in frontmatter {
        pagebreak(weak: true)
        entry
      }
    })
  }
  _render-section(cfg, "body", <_body-end>, local-cfg => {
    show heading.where(level: 1): it => {
      let breaking = cfg.general.layout.at("pagebreak-heading", default: false)
      if breaking == true { pagebreak(weak: true) } else if (
        breaking in ("even", "odd")
      ) { pagebreak(weak: true, to: breaking) }
      it
    }
    body
  })
  let backmatter = _matter(cfg, "backmatter")
  if backmatter.len() > 0 {
    _render-section(cfg, "backmatter", <_backmatter-end>, local-cfg => {
      set heading(numbering: none)
      for entry in backmatter {
        pagebreak(weak: true)
        entry
      }
    })
  }
  let appendices = cfg.component.appendix.entries
  if appendices.len() > 0 {
    _render-section(cfg, "appendix", <_appendix-end>, local-cfg => {
      set heading(
        outlined: true,
        numbering: (..nums) => "Appendix " + numbering("1.1", ..nums),
        supplement: none,
      )
      counter(heading).update(0)
      let toc = cfg.component.appendix.at("toc", default: (:))
      if _enabled(toc) {
        _compose-show-rules(toc.at("show-rules", default: (:)))(
          (toc.generator)(local-cfg),
        )
      }
      pagebreak(weak: true)
      [#metadata("appendix-start") <_appendix-start>]
      for appendix in appendices {
        pagebreak(weak: true)
        if appendix.at("reference", default: none) == none {
          heading(appendix.title)
        } else { [#heading(appendix.title)#label(appendix.reference)] }
        appendix.text
      }
    })
  } else {
    // Ordinary outlines need this boundary even when the appendix is absent.
    [#metadata("appendix-start") <_appendix-start>]
  }
}
