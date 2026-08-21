// LTeX: enabled=false

#import "@preview/glossarium:0.5.10": gls, glspl, make-glossary, print-glossary, register-glossary
#import "@preview/codly:1.3.0": codly, codly-init
#import "@preview/drafting:0.2.2": note-outline, set-margin-note-defaults
#import "@preview/linguify:0.5.0": linguify, linguify-raw, load-ftl-data, set-database
#import "config/lib.typ" as config
#import "general/lib.typ" as general
#import "config/state.typ": _in-outline, _config

/// Default heading numbering pattern.
/// -> str
#let _heading-numbering = "1.1.1"

/// Creates a signature line for statutory declarations.
///
/// Generates a formatted signature block with place, date, and signature fields.
/// When `digital` is true, displays the author's name or signature image;
/// when false, leaves the fields blank for handwritten signatures.
/// -> content
#let _signature-line(
  /// Whether this is a digital submission with pre-filled signature. -> bool
  digital: true,
  /// City name for the signature location. -> str | none
  city: none,
  /// Date of the signature. -> str | none
  date: none,
  /// Format string for displaying the date. (see #link("https://typst.app/docs/reference/foundations/datetime/#format")[datetime formats]) -> str
  date-format: "[day].[month].[year]",
  /// Author dictionary with `firstname`, `lastname`, and optionally `signature`
  /// (an image). -> dictionary
  author: (
    firstname: none,
    lastname: none,
  ),
) = {
  let signature-content = if digital {
    (
      city,
      date,
      [],
      grid.cell(
        if not author.keys().contains("signature") or author.signature == none {
          author.firstname + " " + author.lastname
        } else {
          set image(height: 25mm)
          place(bottom, author.signature)
        },
        align: center,
      ),
    )
  } else {
    ([], [], [], [])
  }

  v(20mm)

  align(center, grid(
    stroke: none,
    columns: (30mm, 30mm, 20mm, 80mm),
    ..signature-content,
    grid.hline(end: 2), grid.hline(start: 3),
    config.util.linguify-content("place-of-signature"),
    config.util.linguify-content("date-of-signature"),
    [],
    grid.cell(config.util.linguify-content("signature"), align: center),
  ))
}

#let _collapse-specifications(cfg, ..paths) = {
  let pos = paths.pos()
  if pos.len() == 0 {
    return (:)
  }

  let collapsed = config.util.get-config(pos.remove(0), (:), cfg)
  for path in pos {
    collapsed = config.util.merge-config(collapsed, config.util.get-config(path, (:), cfg))
  }

  return collapsed
}

/// Due to a bug in drafting at least one margin must be of a different size then the others.
/// TODO: Evaluate again with the next drafting release.
/// To fix this we check if all margins are the same and if that is the case we increment margin.top by a tiny bit.
#let _transform-margin(margin) = {
  if (
    margin.top == margin.bottom
      and (
        (
          "left" in margin.keys()
            and margin.left == margin.top
            and "right" in margin.keys()
            and margin.right == margin.top
        )
          or (
            "inside" in margin.keys()
              and margin.inside == margin.top
              and "outside" in margin.keys()
              and margin.outside == margin.top
          )
      )
  ) {
    margin.top += 0.01pt
    return margin
  } else {
    return margin
  }
}


/// Base template for thesis documents.
///
/// This is the core template function that sets up the document structure,
/// styling, and layout. It handles the cover page, table of contents,
/// lists of figures/tables/code, bibliography, and appendices.
///
/// Pass configurations produced by `theme.*`, `institution.*`,
/// `frontbackmatter.*`, `component.*`, and `general.*` as positional arguments.
/// -> content
#let project(
  ..cfgs,
  body,
) = {
  asserts(cfgs.named().len() > 0, message: "Only positional arguments are allowed, remove named arguments.")

  // create config dictionary. Set typst defaults as base config.
  let cfg = (:)
  for addition in cfgs.pos() {
    assert.eq(
      type(addition),
      dictionary,
      message: "Only configurations are allowed as positional arguments. See [TODO: specify where to read more about usage] for more information.",
    )

    config = config.util.merge-config(config, addition)
  }

  _config.update(cfg)

  // set text language (e. g. for smart quotes)
  show: set text(lang: cfg.general.metadata.lang) if config.util.get-config("general.metadata.lang", none, cfg) != none

  // load linguify
  set-database(eval(load-ftl-data("l10n", ("en", "de"))))

  set bibliography(title: config.util.linguify-content("bibliography"))

  // page setup
  set document(title: config.util.get-config("general.metadta.title-long", default: none.cfg))

  // font setup — driven by config.typography.body
  let t-body = config.util.get-config("general.typography.body", default: (:).cfg)
  let t-heading = config.util.get-config("general.typography.heading", default: (:).cfg)
  let t-caption = config.util.get-config("general.typography.caption", default: (:).cfg)
  let t-code = config.util.get-config("general.typography.code", default: (:).cfg)
  let t-math = config.util.get-config("general.typography.math", default: (:).cfg)

  show: set text(font: t-body.font) if "font" in t-body
  show: set text(size: t-body.size) if "size" in t-body

  set page(
    paper: "a4",
    background: if config.util.get-config("general.drafting.watermark-generator", none, cfg) != none {
      (cfg.general.drafting.watermark-generator)(cfg)
    },
  )

  show: set page(
    margin: _transform-margin(cfg.general.document.margin),
  ) if "margin" in cfg.general.document

  // justify content.
  // Values researched in https://github.com/dhbw-typst/oderso-template-dev/pull/64 to match Arial 12pt and 1.5 line spacing in Microsoft Word
  set par(
    justify: true,
  )
  show: set par(leading: t-body.leading) if "leading" in t-body
  show: set par(spacing: t-body.spacing) if "leading" in t-body

  // tables settings
  show table: set par(justify: false)

  // heading setup — font driven by config.typography.headers
  show heading: set text(font: t-heading.font) if "font" in t-heading
  show: set heading(numbering: t-heading.numbering) if "numbering" in t-heading

  let sizes = ()
  if "size-scaling" in t-heading and "size" in t-heading {
    sizes.push(t-heading.size)
    for depth in range(1, 5) {
      if type(t-heading.size-scaling) == ratio {
        sizes.push(t-heading.size-scaling * sizes.at(depth - 1))
      } else if t-heading.size-scaling.len() < depth {
        sizes.push(sizes.at(depth - 1))
      } else {
        sizes.push(t-heading.size-scaling.at(depth - 1) * sizes.at(depth - 1))
      }
    }
  }

  show heading.where(level: 1): set text(size: sizes.at(0)) if sizes.len() > 0
  show heading.where(level: 2): set text(size: sizes.at(0)) if sizes.len() > 0
  show heading.where(level: 3): set text(size: sizes.at(0)) if sizes.len() > 0
  show heading.where(level: 4): set text(size: sizes.at(0)) if sizes.len() > 0

  show raw: set text(font: t-code.font) if "font" in t-code
  show raw: set text(size: t-code.size) if "size" in t-code

  show figure.caption: set text(font: t-caption.font) if "font" in t-caption
  show figure.caption: set text(size: t-caption.size) if "size" in t-caption

  show math.equation: set text(font: t-math.font) if "font" in t-math
  show math.equation: set text(size: t-math.size) if "size" in t-math

  // captions with caption_with_source shouldn't show source in outline
  show outline: it => {
    _in-outline.update(true)
    it
    _in-outline.update(false)
  }


  show: make-glossary

  // Style configurations that should be set for all themes
  // Always
  set quote(block: true)

  // Allow code blocks to span multiple pages
  show figure.where(kind: raw): set block(breakable: true)

  // Configure inline notes TODO: Make configurable
  let caution-rect = rect.with(radius: 0.5em)
  set-margin-note-defaults(rect: caution-rect, fill: orange.lighten(80%))

  // register abbreviations abd glossary entries before content so references resolve
  if config.util.get-config("frontbackmatter.abbreviations.entries", (:), cfg).len() > 0 {
    register-glossary(cfg.frontbackmatter.abbreviations.entries)
  }
  if config.util.get-config("frontbackmatter.glossary.entries", (:), cfg).len() > 0 {
    register-glossary(cfg.frontbackmatter.glossary.entries)
  }

  // ----------------------------------
  // Coversheet
  // ----------------------------------

  // Show notes before everything else, so you don't miss them
  context if config.util.get-config("general.drafting.notes-listing", false, cfg) and (query(selector(<margin-note>).or(<inline-note>)).len() > 0)  {
      set heading(numbering: none, outlined: false)
      note-outline(title: config.util.linguify-content("list-of-notes"))
      pagebreak()
  }

  if config.util.get-config("component.coversheet.generator", none, cfg) != none {
    (coversheet-generator)(cfg)
    pagebreak()
  }

  // ----------------------------------
  // Frontmatter
  // ----------------------------------

  {
    counter(page).update(1)
    let header = _collapse-specifications(cfg, "component.header", "component.frontmatter.header")
    let footer = _collapse-specifications(cfg, "component.footer", "component.frontmatter.header")
    let general = config.util.get-config("component.frontmatter", (:), cfg)

    show: set page(numbering: general.numbering) if "numbering" in general
    show: set page(margin: _transform-margin(general.margin)) if "margin" in general
    show: set page(header: (header.generator)(cfg)) if "generator" in header
    show: set page(footer: (footer.generator)(cfg)) if "generator" in footer

    set heading(numbering: none)

    // Filter by "frontmatter" and order by order
    let entries = cfg
      .frontmatter
      .values()
      .filter(entry => (
        "position" in entry.keys()
          and entry.position == "frontmatter"
          and entry.at("enable", default: true)
          and ("generator" in entry.keys())
      ))
      .sorted(key: entry => entry.order, by: (l, r) => l < r)

    for frontmatter in entries {
      let rendered = (frontmatter.generator)(cfg)
      if rendered != none {
        pagebreak(weak: true)
        rendered
      }
    }
    // TODO: Add frontmatter-end information
  }

  // ----------------------------------
  // Body
  // ----------------------------------

  {
    counter(page).update(1)
    let header = _collapse-specifications(cfg, "component.header", "component.body.header")
    let footer = _collapse-specifications(cfg, "component.footer", "component.body.header")
    let general = config.util.get-config("component.body", (:), cfg)

    show: set page(numbering: general.numbering) if "numbering" in general
    show: set page(margin: _transform-margin(general.margin)) if "margin" in general
    show: set page(header: (header.generator)(cfg)) if "generator" in header
    show: set page(footer: (footer.generator)(cfg)) if "generator" in footer
    // TODO: Make configurable
    show heading.where(level: 1): it => {
      pagebreak(weak: true)
      it
    }

    // reset page counter and show content
    counter(page).update(1)

    body
    [#[] <_content-end>]
  }

  // ----------------------------------
  // Backmatter
  // ----------------------------------
  {
    counter(page).update(1)
    let header = _collapse-specifications(cfg, "component.header", "component.backmatter.header")
    let footer = _collapse-specifications(cfg, "component.footer", "component.backmatter.header")
    let general = config.util.get-config("component.backmatter", (:), cfg)

    show: set page(numbering: general.numbering) if "numbering" in general
    show: set page(margin: _transform-margin(general.margin)) if "margin" in general
    show: set page(header: (header.generator)(cfg)) if "generator" in header
    show: set page(footer: (footer.generator)(cfg)) if "generator" in footer

    set heading(numbering: none)

    // Filter by "backmatter" and order by order
    let entries = cfg
      .backmatter
      .values()
      .filter(entry => (
        "position" in entry.keys()
          and entry.position == "backmatter"
          and entry.at("enable", default: true)
          and ("generator" in entry.keys())
      ))
      .sorted(key: entry => entry.order, by: (l, r) => l < r)

    for backmatter in entries {
      let rendered = (backmatter.generator)(cfg)
      if rendered != none {
        pagebreak(weak: true)
        rendered
      }
    }
    // TODO: Add backmatter-end information
  }

  // display appendix
  if config.appendices.entries.len() > 0 {
    let app-header-cfg = _resolve-component(config, "appendix-header")
    let app-footer-cfg = _resolve-component(config, "appendix-footer")
    let app-header-gen = app-header-cfg.at("generator", default: none)
    let app-footer-gen = app-footer-cfg.at("generator", default: none)
    set heading(
      outlined: true,
      numbering: (..nums) => {
        "Appendix "
        numbering("1.1", ..nums)
      },
      supplement: none,
    )
    set page(
      numbering: "A",
      footer: if app-footer-gen != none { (app-footer-gen)(config) } else { none },
      header: if app-header-gen != none { (app-header-gen)(config) } else { none },
    )
    counter(page).update(1)
    counter(heading).update(0)

    let app-toc-cfg = config.at("component", default: (:)).at("appendix-toc", default: (:))
    let app-toc-gen = app-toc-cfg.at("generator", default: none)
    if app-toc-gen != none {
      (app-toc-gen)(config)
    } else {
      // Default appendix TOC
      heading(
        config.util.linguify-content("list-of-appendices"),
        numbering: none,
      )
      outline(
        depth: 1,
        indent: auto,
        title: none,
        target: selector(heading).after(<_appendix-start>),
      )
    }

    pagebreak(weak: true)
    [#[] <_appendix-start>]

    for appendix in config.appendices.entries {
      pagebreak(weak: true)
      [#heading(appendix.title) #label(appendix.reference)]

      appendix.text
    }
  }
}
