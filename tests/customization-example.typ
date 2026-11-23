// A compilable example also included verbatim in the generated reference.
#import "../template/template/lib.typ": *
#show: project.with(
  theme.spotless(),
  component.body.footer(show-total-pages: true),
  institution.dhbw-ka.setup(
    title-long: "Customizing a thesis",
    title-short: "Customization",
    thesis-type: "Bachelorarbeit",
    processing-period-weeks: 12,
    authors: (
      (
        firstname: "Jane",
        lastname: "Doe",
        matriculation-number: "1234567",
        course: "TINF24B1",
      ),
    ),
  ),
  // Unspecified sides keep the inherited 2.5 cm margin.
  component.body.page(margin: (top: 3cm), numbering: "i"),
  institution
    .dhbw-ka
    .frontbackmatter
    .ai-declaration(
      entries: ((tool: "Example AI", usage: [Editing]),),
    ),
  // A position-only patch preserves entries. Signed positions sort ascending.
  institution.dhbw-ka.frontbackmatter.ai-declaration(position: -50),
  // Explicit disabling preserves configuration for a later re-enable.
  component.frontmatter.header(enable: false),
  frontbackmatter.confidentiality-clause(enable: false),
  general.typography.body(size: 12pt, spacing: 1em),
  // Override an earlier footer patch without replacing the theme generator.
  component.body.footer(show-total-pages: false),
  component.show-rules(show-key: "custom", show-fun: it => {
    set text(fill: teal)
    it
  }),
  // Replacing a function retains its order; order can also be patched alone.
  component.show-rules(show-key: "custom", show-order: 10),
  component.show-rules(show-key: "custom", show-fun: it => {
    set text(fill: blue)
    it
  }),
  component.show-rules(show-key: "custom", show-enable: false),
  // Advanced replacement uses the unchanged generator signature.
  component.body.header(generator-function: (cfg, last-page) => {
    align(right, cfg.general.metadata.title-short)
  }),
)
= Introduction
Body content.
