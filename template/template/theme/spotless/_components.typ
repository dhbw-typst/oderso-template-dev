#import "../../config/lib.typ" as config
#let linguify-content = config.util.linguify-content
#import "../../component/lib.typ" as component
#import "@preview/hydra:0.6.3": anchor, hydra
#import "../../institution/_shared.typ": _cover-metadata, _require-authors
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
  return component.coversheet(generator-function: config => {
    let authors = _require-authors(config.general.metadata, "Coversheet")
    let presentation = _cover-metadata(config.general.metadata)
    // Coversheet
    grid(
      rows: (1fr, auto, 1fr),
      align: (_, row) => (center + top, center + top, center + bottom).at(row),
      // Left and right logo
      {
        set image(height: 2.5cm)

        grid(
          columns: (1fr, 1fr),
          align(left, config.general.metadata.at("logo-left", default: none)),
          align(right, config.general.metadata.at("logo-right", default: none)),
        )
      },

      // Title
      align(center)[
        #set par(justify: false)

        #text(20pt)[*#config.general.metadata.at("title-long", default: none)*]

        #smallcaps(text(
          1.25em,
          weight: "semibold",
        )[#config.general.metadata.at("thesis-type", default: none)])

        #presentation.submission-info

        #linguify-content("by")

        #for author in authors {
          [*#author.firstname #author.lastname*\ ]
        }
      ],

      // Meta
      place(center + bottom, {
        show table.cell.where(x: 0): set text(weight: "semibold")

        set par(leading: .6em)

        table(
          columns: (1fr, 1fr),
          align: (right + top, left + top),
          stroke: none,
          ..presentation.misc-key-value
        )
      }),
    )

    let clause = config.front-back-matter.at(
      "confidentiality-clause",
      default: (:),
    )
    let confidentiality-enabled = (
      clause.at("enable", default: true)
        and clause.at("generator", default: none) != none
        and type(clause.at("position", default: none)) == int
    )
    if confidentiality-enabled {
      place(top + center, dy: 5cm, link(<_confidentiality-clause>)[
        #text(
          size: 12pt,
          weight: "bold",
          fill: gray,
          linguify-content("confidentiality-stamp"),
        )
      ])
    }
  })
}

#let _body-header() = {
  return component.body.header(
    generator-function: (config, _) => context {
      anchor()
      grid(
        columns: (auto, 1fr),
        align(left, config.general.metadata.at("title-short", default: [])),
        align(right, emph(hydra(1, display: (_, it) => {
          it.body
        }))),
      )
      line(length: 100%, stroke: (paint: gray))
    },
    height: 1cm,
  )
}

#let _page-number(cfg, total) = context {
  let section = cfg.resolved-section
  let fmt = section.page.numbering
  if fmt != none {
    // Native page numbering callbacks always receive current and total. The
    // total-page convenience suffix reuses the same formatter for the total.
    let format-number(n) = if type(fmt) == function { fmt(n, total) } else {
      numbering(fmt, n)
    }
    align(center, {
      format-number(counter(page).get().first())
      if section.footer.at("show-total-pages", default: false) {
        text(" / ")
        format-number(total)
      }
    })
  }
}

// Shared theme numbering preserves the formerly implicit native page footer,
// but now all footer hooks and explicit suppression apply consistently.
#let _shared-footer() = component.footer(generator-function: _page-number)

#let _body-footer(show-total-pages: false) = component.body.footer(
  show-total-pages: show-total-pages,
)
