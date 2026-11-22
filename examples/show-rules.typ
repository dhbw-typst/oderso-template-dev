// Keyed rules merge field by field, and section-local rules do not leak.
#import "../template/template/lib.typ": (
  component, frontbackmatter, general, project, theme,
)

#show: project.with(
  theme.spotless(),
  component.coversheet(enable: false),
  frontbackmatter.toc(enable: false),
  general.layout(pagebreak-heading: false),
  component.show-rules(show-key: "headings", show-order: 10, show-fun: it => {
    show heading: set text(fill: purple)
    it
  }),
  component.body.show-rules(
    show-key: "emphasis",
    show-order: 20,
    show-fun: it => {
      show strong: set text(fill: red)
      it
    },
  ),
  // Replacing the function keeps its order; the order can also be patched alone.
  component.body.show-rules(show-key: "emphasis", show-fun: it => {
    show strong: set text(fill: teal)
    it
  }),
  component.body.show-rules(show-key: "emphasis", show-order: 30),
  component.body.show-rules(show-key: "emphasis", show-enable: false),
  component.body.show-rules(show-key: "emphasis", show-enable: true),
  component.body.show-rules(
    show-key: "disabled-color",
    show-order: 100,
    show-fun: it => {
      set text(fill: orange)
      it
    },
  ),
  component.body.show-rules(show-key: "disabled-color", show-enable: false),
  component.appendix.entries(appendices: (
    (
      title: [Scope comparison],
      text: [*This bold text is not teal*: the emphasis rule only wraps the body.],
    ),
  )),
)

= Rule composition

Headings are purple because of the global rule. *Bold body text is teal*
because the later callback replaces the red callback at the same key.
Ordinary text is not orange because that rule is disabled.

== Section boundaries

The appendix retains the global heading color but does not inherit the
body-only strong-text rule.
