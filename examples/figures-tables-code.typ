// Figures, tables, code, and their independent outlines.
#import "../template/template/lib.typ": (
  component, frontbackmatter, general, project, theme, util,
)

#show: project.with(
  theme.spotless(),
  component.coversheet(enable: false),
  frontbackmatter.toc(enable: false),
  general.layout(pagebreak-heading: false),
  frontbackmatter.figure-listings(
    figure-listing: true,
    table-listing: true,
    code-listing: true,
  ),
)

= Figures and tables

#figure(
  image("assets/diagram.svg", width: 75%),
  caption: util.caption-with-source(
    [A three-stage process],
    [(Source: example authors)],
  ),
) <process-figure>

The source appears beside the caption of @process-figure but not in the list
of figures.

#util.tablefigure(
  columns: (1fr, auto, auto),
  caption: [Measurements with an academic table style],
  reference: "measurements-table",
  table-content: (
    table.header([*Trial*], [*Value*], [*Unit*]),
    [Control],
    [10],
    [ms],
    [Candidate],
    [8],
    [ms],
  ),
)

@measurements-table uses Roman table numbering and a caption above the table.

#pagebreak()

= Code figures

#figure(caption: [A small function])[
  ```python
  def double(value):
      return value * 2
  ```
] <code-figure>

@code-figure appears in the list of code rather than the list of figures.

#figure(
  kind: image,
  caption: [Command output, explicitly classified as an image],
)[
  ```text
  $ example --version
  example 1.0.0
  ```
]
