#import "../../config/lib.typ" as config
#let linguify-content = config.util.linguify-content
#import "../../component/lib.typ" as component
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

        #text(20pt)[*#config.general.metadata.title-long*]

        #smallcaps(text(
          1.25em,
          weight: "semibold",
        )[#config.general.metadata.thesis-type])

        #config.general.metadata.submission-info

        #linguify-content("by")

        #for author in config.general.metadata.authors {
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
          ..config.general.metadata.misc-key-value
        )
      }),
    )

    let confidentiality-enabled = config
      .front-back-matter
      .at("confidentiality-clause", default: (:))
      .at("enable", default: false)
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
  return component.body-header(
    generator-function: config => context {
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

#let _body-footer() = {
  return component.body-footer(
    generator-function: config => context align(center, {
      numbering("1", counter(page).get().at(0))
    }),
    height: 0cm,
  )
}
