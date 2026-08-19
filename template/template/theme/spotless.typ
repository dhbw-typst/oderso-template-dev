#import "../component/lib.typ" as component
#import "../config/lib.typ" as config

/// Configure the coversheet of style _spotless_.
///
/// TODO: Add what metadata is required to dispay this coversheet
///
/// -> dictionary
#let spotless() = {
  config.utils.merge-configs(
    _coversheet(),
  )
}

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
          align(left, config.metadata.at("logo-left", default: none)),
          align(right, config.metadata.at("logo-right", default: none)),
        )
      },

      // Title
      align(center)[
        #set par(justify: false)

        #text(20pt)[*#config.metadata.title-long*]

        #smallcaps(text(
          1.25em,
          weight: "semibold",
        )[#config.metadata.thesis-type])

        #config.metadata.submission-info

        #_linguify-content("by")

        #for author in config.metadata.authors {
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
          ..config.metadata.misc-key-value
        )
      }),
    )

    if config.front-back-matter.confidentiality-clause.enable {
      place(top + center, dy: 5cm, link(<_confidentiality-clause>)[
        #text(
          size: 12pt,
          weight: "bold",
          fill: gray,
          _linguify-content("confidentiality-stamp"),
        )
      ])
    }
  })
}
