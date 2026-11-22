// The theme provides watermark styling and drafting note defaults.
#import "../template/template/lib.typ": (
  component, frontbackmatter, general, project, theme,
)
#import "@preview/drafting:0.2.2": inline-note, margin-note

#show: project.with(
  theme.spotless(),
  component.coversheet(enable: false),
  frontbackmatter.toc(enable: false),
  general.metadata(title-short: "Drafting example"),
  general.drafting(watermark: [DRAFT], notes-listing: true),
  // Extra outside space keeps margin notes readable.
  component.page(margin: (left: 25mm, right: 40mm, y: 25mm)),
)

= Work in progress

This sentence needs a source.#margin-note[Add a source for this statement.]
The watermark is visible behind the body and the note has the theme's margin
note styling.

#inline-note[Rewrite this paragraph before submitting the document.]

The automatic list of notes appears before the body. It should contain both
the margin note and the inline note, with links back to their positions.

= Another chapter

The same watermark appears on subsequent pages. Removing all notes would
also remove the automatic notes listing.
