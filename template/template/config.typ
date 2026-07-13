// Configure general page settings
#let config-page(
  margin: (rest: 2.5cm)
  bleed: 0cm
) = {
  return ()
}

// Allows replacing the cover completely
#let config-cover(content) = {
  return ()
}

// Allows providing functions that will be included at various parts of the document AFTER default set and show rules to add aditional styling.
#let config-includes(
  inlcude-cover: none,
  include-abstracts: none,
  include-tocs: none,
  include-content: none,
  inlcude-postamble: none,
  include-appendix: none,
) = {
  return ()
}

// Configure general typography
#let config-typography(
  font: none,
  size: none,
  justify: none,
  leading: none,
  spacing: none,
)

// We can provide some default implementations here
#let config-typography-new-computer-modern = config-typography(
  font: "New Computer Modern",
  size: 12pt,
  justify: true,
  leading: 1.05em,
  spacing: 1.5em,
)

// Configure content layout
#let config-layout(
  columns: 1
  margin: none
  total-page-numbering: false
  chapter-opening-pagebreak: true
)

// Replace the content header
#let config-header(
  content: none
  ascent: none
)

// Replace the footer header
#let config-footer(
  content: none
  descent: none
)

#let config-output(
  digital-submission: true,
  digital-only: true,
  draft: false,
)

#let config-print-submission(
  margins: (),
  bleed: 0cm,
  // Allowed: none, "recto" (right-hand page), "verso" (left-hand page), "next" (normal page-break)
  chapter-opening: "recto"
  // Whether to export two files: cover.pdf (including the front and back cover as well as the spine) and content.pdf or just a single file including both the cover and content.
  // The spine is only included with bundled export enabled and cover page configurations only apply to bundled export.
  bundled-export: true
  // Whether to start with an blank verso page (sometimes needed for printing)
  blank-verso: true
  back-cover: [],
  spine: [],
  spine-width: none,
  cover-height: none,
  cover-width: none,
  cover-bleed: none,
  cover-margin: none,
)