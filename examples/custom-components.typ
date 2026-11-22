// Replace generators while retaining the public (cfg) / (cfg, total) signatures.
#import "../template/template/lib.typ": (
  component, frontbackmatter, general, project, theme,
)

#let section-header(cfg, total) = {
  grid(
    columns: (1fr, auto),
    cfg.general.metadata.title-short,
    [#cfg.resolved-section.name / #total pages],
  )
  line(length: 100%, stroke: 0.5pt)
}
#let section-footer(cfg, total) = context {
  align(center)[
    #cfg.resolved-section.name: #counter(page).get().first() / #total
  ]
}

#show: project.with(
  theme.spotless(),
  general.metadata(
    title-long: "Custom document components",
    title-short: "Custom components",
  ),
  component.coversheet(
    generator-function: cfg => align(center + horizon)[
      #text(24pt, weight: "bold", cfg.general.metadata.title-long)

      This cover replaces the theme's metadata-based cover generator.
    ],
    show-key: "cover-color",
    show-fun: it => {
      set text(fill: teal)
      it
    },
  ),
  component.header(height: 9mm, generator-function: section-header),
  // Body-specific theme generators must be replaced at the same scope.
  component.body.header(generator-function: section-header),
  component.footer(height: 6mm, generator-function: section-footer),
  component.body.footer(generator-function: section-footer),
  component.frontmatter.header(show-key: "header-color", show-fun: it => {
    set text(fill: purple)
    it
  }),
  frontbackmatter.acknowledgements(text: [A front-matter header is purple.]),
)

= First body page

The header reads effective section metadata and its page count. The footer
combines the section name with current and total pages. Neither inherits the
cover's teal color or the front-matter header's purple color.

= Second body page

All body pages share the replacement generators.
