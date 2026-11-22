// Mirrored margins and odd-page chapters on a smaller paper size.
#import "../template/template/lib.typ": (
  component, frontbackmatter, general, project, theme,
)

#show: project.with(
  theme.spotless(),
  component.coversheet(enable: false),
  frontbackmatter.toc(enable: false),
  general.metadata(title-short: "Mirrored layout"),
  general.layout(paper: "a5", justify: false, pagebreak-heading: "odd"),
  general.typography.body(size: 11pt),
  component.page(margin: (rest: 16mm, inside: 24mm, outside: 12mm)),
  // Only the top changes; the other sides inherit the global margin patch.
  component.body.page(
    margin: (top: 20mm),
    numbering: (current, total) => [Page #current of #total],
  ),
)

= First chapter

The inner margin is wider than the outer margin. Chapters start on odd pages;
the short first chapter leaves a blank even page before the next chapter.

#rect(width: 100%, height: 2mm, fill: teal, stroke: none)

= Second chapter

This is another odd page. The footer is a numbering callback receiving both
the current body page and the total number of body pages.

#rect(width: 100%, height: 2mm, fill: teal, stroke: none)

#pagebreak()

The continuation is an even page. Its inner and outer margins swap sides,
while the top-only section patch still applies.

#rect(width: 100%, height: 2mm, fill: teal, stroke: none)
