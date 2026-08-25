// LTeX: enabled=false

#import "@preview/glossarium:0.5.10": (
  gls, glspl, make-glossary, print-glossary, register-glossary,
)
#import "@preview/codly:1.3.0": codly, codly-init
#import "@preview/drafting:0.2.2": note-outline, set-margin-note-defaults
#import "@preview/linguify:0.5.0": (
  linguify, linguify-raw, load-ftl-data, set-database,
)
#import "config/lib.typ" as config
#import "general/lib.typ" as general
#import "config/state.typ": _config, _in-outline

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
    collapsed = config.util.merge-config(collapsed, config.util.get-config(
      path,
      (:),
      cfg,
    ))
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
  assert(
    cfgs.named().len() == 0,
    message: "Only positional arguments are allowed, remove named arguments.",
  )

  // create config dictionary. Set typst defaults as base config.
  let cfg = (:)
  for addition in cfgs.pos() {
    assert.eq(
      type(addition),
      dictionary,
      message: "Only configurations are allowed as positional arguments. See [TODO: specify where to read more about usage] for more information.",
    )

    cfg = config.util.merge-config(cfg, addition)
  }

  _config.update(cfg)

  // set text language (e. g. for smart quotes)
  show: set text(lang: cfg.general.metadata.lang) if (
    config.util.get-config("general.metadata.lang", none, cfg) != none
  )

  // load linguify
  set-database(eval(load-ftl-data("l10n", ("en", "de"))))

  set bibliography(title: config.util.linguify-content("bibliography"))

  // page setup
  set document(title: config.util.get-config(
    "general.metadata.title-long",
    none,
    cfg,
  ))

  // font setup — driven by config.typography.body
  let t-body = config.util.get-config("general.typography.body", (:), cfg)
  let t-heading = config.util.get-config("general.typography.heading", (:), cfg)
  let t-caption = config.util.get-config("general.typography.caption", (:), cfg)
  let t-code = config.util.get-config("general.typography.code", (:), cfg)
  let t-math = config.util.get-config("general.typography.math", (:), cfg)

  show: set text(font: t-body.font) if "font" in t-body
  show: set text(size: t-body.size) if "size" in t-body

  set page(
    paper: "a4",
    background: if config.util.get-config(
      "general.drafting.watermark-generator",
      none,
      cfg,
    )
      != none {
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

  let sizes = if "sizes" in t-heading {t-heading.sizes} else {()}

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
  if (
    config
      .util
      .get-config("front-back-matter.abbreviations.entries", (:), cfg)
      .len()
      > 0
  ) {
    register-glossary(config.util.get-config(
      "front-back-matter.abbreviations.entries",
      (),
      cfg,
    ))
  }
  if (
    config.util.get-config("front-back-matter.glossary.entries", (:), cfg).len()
      > 0
  ) {
    register-glossary(config.util.get-config(
      "front-back-matter.glossary.entries",
      (),
      cfg,
    ))
  }

  // Apply general.document.show rule AFTER all base set/show rules
  show: (
    config.util.get-config("general.document.show-rule", it => it, cfg)
  ).with()

  // ----------------------------------
  // Coversheet
  // ----------------------------------

  // Show notes before everything else, so you don't miss them
  context if (
    config.util.get-config("general.drafting.notes-listing", false, cfg)
      and (query(selector(<margin-note>).or(<inline-note>)).len() > 0)
  ) {
    set heading(numbering: none, outlined: false)
    note-outline(title: config.util.linguify-content("list-of-notes"))
    pagebreak()
  }

  if (
    config.util.get-config("component.coversheet.generator", none, cfg) != none
  ) {
    show: (
      config.util.get-config("component.coversheet.show-rule", it => it, cfg)
    ).with()
    (config.util.get-config("component.coversheet.generator", none, cfg))(cfg)
    pagebreak()
  }

  // ----------------------------------
  // Frontmatter
  // ----------------------------------

  {
    counter(page).update(1)
    let header = _collapse-specifications(
      cfg,
      "component.header",
      "component.frontmatter.header",
    )
    let footer = _collapse-specifications(
      cfg,
      "component.footer",
      "component.frontmatter.header",
    )
    let general = config.util.get-config("component.frontmatter", (:), cfg)

    show: set page(numbering: general.numbering) if "numbering" in general
    show: set page(margin: _transform-margin(general.margin)) if (
      "margin" in general
    )
    show: set page(header: (header.generator)(cfg)) if "generator" in header
    show: set page(footer: (footer.generator)(cfg)) if "generator" in footer
    set heading(numbering: none)

    show: (
      config.util.get-config("component.frontmatter.show-rule", it => it, cfg)
    ).with()

    // Filter front-back-matter entries with negative position (frontmatter) and sort ascending
    let entries = cfg
      .front-back-matter
      .values()
      .filter(entry => (
        "position" in entry.keys()
          and type(entry.position) == int
          and entry.position < 0
          and entry.at("enable", default: true)
          and ("generator" in entry.keys())
      ))
      .sorted(key: entry => entry.position, by: (l, r) => l < r)

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
    let header = _collapse-specifications(
      cfg,
      "component.header",
      "component.body.header",
    )
    let footer = _collapse-specifications(
      cfg,
      "component.footer",
      "component.body.footer",
    )
    let general = config.util.get-config("component.body", (:), cfg)

    show: set page(numbering: general.numbering) if "numbering" in general
    show: set page(margin: _transform-margin(general.margin)) if (
      "margin" in general
    )
    show: set page(header: (header.generator)(cfg)) if "generator" in header
    show: set page(footer: (footer.generator)(cfg)) if "generator" in footer


    // TODO: Make configurable
    show heading.where(level: 1): it => {
      pagebreak(weak: true)
      it
    }

    show: (
      config.util.get-config("component.body.show-rule", it => it, cfg)
    ).with()

    body
    [#[] <_content-end>]
  }

  // ----------------------------------
  // Backmatter
  // ----------------------------------
  {
    counter(page).update(1)
    let header = _collapse-specifications(
      cfg,
      "component.header",
      "component.backmatter.header",
    )
    let footer = _collapse-specifications(
      cfg,
      "component.footer",
      "component.backmatter.header",
    )
    let general = config.util.get-config("component.backmatter", (:), cfg)

    show: set page(numbering: general.numbering) if "numbering" in general
    show: set page(margin: _transform-margin(general.margin)) if (
      "margin" in general
    )
    show: set page(header: (header.generator)(cfg)) if "generator" in header
    show: set page(footer: (footer.generator)(cfg)) if "generator" in footer

    show: (
      config.util.get-config("component.backmatter.show-rule", it => it, cfg)
    ).with()

    set heading(numbering: none)

    // Filter front-back-matter entries with non-negative position (backmatter) and sort ascending
    let entries = cfg
      .front-back-matter
      .values()
      .filter(entry => (
        "position" in entry.keys()
          and type(entry.position) == int
          and entry.position >= 0
          and entry.at("enable", default: true)
          and ("generator" in entry.keys())
      ))
      .sorted(key: entry => entry.position, by: (l, r) => l < r)

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
  if cfg.at("appendices", default: (:)).at("entries", default: ()).len() > 0 {
    let app-header-cfg = _collapse-specifications(
      cfg,
      "component.header",
      "component.appendix.header",
    )
    let app-footer-cfg = _collapse-specifications(
      cfg,
      "component.footer",
      "component.appendix.footer",
    )
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
      footer: if app-footer-gen != none { (app-footer-gen)(cfg) } else { none },
      header: if app-header-gen != none { (app-header-gen)(cfg) } else { none },
    )
    counter(page).update(1)
    counter(heading).update(0)

    let app-toc-cfg = cfg
      .at("component", default: (:))
      .at("appendix", default: (:))
      .at("toc", default: (:))
    let app-toc-gen = app-toc-cfg.at("generator", default: none)
    if app-toc-gen != none {
      (app-toc-gen)(cfg)
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

    for appendix in cfg.appendices.entries {
      pagebreak(weak: true)
      [#heading(appendix.title) #label(appendix.reference)]

      appendix.text
    }
  }
}
