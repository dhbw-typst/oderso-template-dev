// LTeX: enabled=false

#import "../../config/lib.typ" as config
#let linguify-content = config.util.linguify-content
#import "../../component/lib.typ" as component
#import "@preview/hydra:0.6.3": anchor, hydra
/// Configure the theme _spotless_.
///
/// Sets defaults for:
/// - Coversheet (two-logo layout with title block and metadata table)
/// - Body header (short title left + current heading right, with rule)
/// - Body footer (centred page number)
///
/// All section defaults can be overridden by passing further config
/// dictionaries after `theme.spotless()` in the `project` call.
/// -> dictionary
#let _coversheet() = {
  return component.coversheet(generator-function: cfg => {
    // ---------- Page Setup ---------------------------------------

    set page(
      // identical to document
      margin: (top: 4cm, bottom: 3cm, left: 4cm, right: 3cm),
    )
    let page-grid = 16pt
    set text(font: "Source Sans 3", size: page-grid)


    set align(center)

    // ---------- Logo(s) ---------------------------------------
    if (
      config.util.get-config("general.metadata.logo-left", none, cfg) != none
        and config.util.get-config("general.metadata.logo-right", none, cfg) == none
    ) {
      // one logo: centered
      place(
        top + center,
        dy: -3 * page-grid,
        box(cfg.general.metadata.logo-left, height: 3 * page-grid),
      )
    } else if (
      config.util.get-config("general.metadata.logo-left", none, cfg) != none
        and config.util.get-config("general.metadata.logo-right", none, cfg) != none
    ) {
      // two logos: left & right
      place(
        top + left,
        dy: -4 * page-grid,
        box(cfg.general.metadata.logo-left, height: 3 * page-grid),
      )
      place(
        top + right,
        dy: -4 * page-grid,
        box(cfg.general.metadata.logo-right, height: 3 * page-grid),
      )
    }

    // ---------- Title ---------------------------------------

    v(7 * page-grid)
    text(weight: "bold", fill: luma(80), size: 1.5 * page-grid, cfg.general.metadata.title-long)
    v(page-grid)

    // ---------- Sub-Title-Infos ---------------------------------------
    align(center, text(size: page-grid, cfg.general.metadata.thesis-type))
    v(0.25 * page-grid)

    text(cfg.general.metadata.submission-info)
    v(0.25 * page-grid)

    // ---------- Authors ---------------------------------------
    place(
    bottom + center,
    dy: -11 * page-grid,
    grid(
      columns: 100%,
      gutter: if (cfg.general.metadata.authors.len() > 1) {
        14pt
      } else {
        1.25 * page-grid
      },
      ..cfg.general.metadata.authors.map(author => align(
        center,
        {
          text(author.firstname + " " + author.lastname)
        },
      ))
    ),
  )

    // ---------- Info-Block ---------------------------------------

    set text(size: 11pt)
    // Meta
    place(center + bottom, {
      show table.cell.where(x: 0): set text(weight: "semibold")

      set par(leading: .6em)

      table(
        columns: (1fr, 1fr),
        align: (right + top, left + top),
        stroke: none,
        ..cfg.general.metadata.misc-key-value
      )
    })
  })
}

#let _body-header() = {
  return component.body.header(
    generator-function: (config, _) => context {
      anchor()
      grid(
        columns: (auto, 1fr),
        align(left, text(config.general.metadata.title-short)),
        align(right, emph(hydra(1, display: (_, it) => {
          it.body
        }))),
      )
      line(length: 100%, stroke: (paint: gray))
    },
    height: 1cm,
  )
}

#let _body-footer(show-total-pages: false) = {
  return component.body.footer(
    generator-function: (cfg, total) => context {
      let numbering-fmt = config.util.get-config(
        "component.body.numbering",
        "1",
        cfg,
      )
      align(center, if show-total-pages {
        numbering(
          numbering-fmt + " / " + numbering-fmt,
          counter(page).get().at(0),
          total,
        )
      } else {
        numbering(numbering-fmt, counter(page).get().at(0))
      })
    },
  )
}
