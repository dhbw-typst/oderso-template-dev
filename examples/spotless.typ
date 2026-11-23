// A theme can be used without an institution; cover metadata is supplied directly.
#import "../template/template/lib.typ": component, general, project, theme

#show: project.with(
  theme.spotless(),
  component.body.footer(show-total-pages: true),
  general.metadata(
    lang: "en",
    title-long: "A theme without an institution",
    title-short: "Spotless theme",
    thesis-type: "Feature example",
    authors: ((firstname: "Alex", lastname: "Example"),),
    submission-info: [A standalone demonstration of the Spotless theme.],
    misc-key-value: ([Submission date], [24.12.2026]),
  ),
)

= First chapter

The cover and table of contents precede the body. The running header contains
the short title and current chapter; the footer shows current and total body
pages.

== Subsection

This heading also appears in the table of contents. A
#link("https://typst.app/", [link]) uses the theme's academic link styling.

= Second chapter

Level-one headings start new pages. The chapter name in the header changes,
while the short document title stays the same.

#quote(attribution: [Example author])[
  A short block quote demonstrates the theme's quotation defaults.
]
