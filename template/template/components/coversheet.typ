#import "../config.typ": (
  __default, __get-dict-without-default, __validate-generator,
)
#import "../utils.typ": __linguify-content

/// Configure the coversheet. Low-level configuration function for providing a completly custom coversheet. Use `configure-coversheet-*` for predefined coversheets. -> dictionary
#let configure-coversheet(
  /// A function receiving a single position argument `config` holding the configuration dictionary and returing the conversheet `content` -> function.
  generator-function: __default,
) = {
  __validate-generator(generator-function)

  return (
    coversheet: __get-dict-without-default((
      generator: generator-function,
    )),
  )
}

/// Configure the coversheet of style _spotless_.
///
/// -> dictionary
#let configure-coversheet-spotless() = {
  return configure-coversheet(generator-function: config => {
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

        #__linguify-content("by")

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
      place(top + center, dy: 5cm, link(<__confidentiality-clause>)[
        #text(
          size: 12pt,
          weight: "bold",
          fill: gray,
          __linguify-content("confidentiality-stamp"),
        )
      ])
    }
  })
}
