// Suppression should not leave empty cover, matter, or appendix pages behind.
#import "../template/template/lib.typ": (
  component, feature, frontbackmatter, institution, project, theme,
)

#show: project.with(
  theme.spotless(),
  institution.dhbw-ka.setup(
    authors: (),
    submission-date: "24.12.2026",
  ),
  // No author metadata is required once author-dependent components are disabled.
  component.coversheet(enable: false),
  frontbackmatter.statutory-declaration(enable: false),
  frontbackmatter.confidentiality-clause(enable: false),
  frontbackmatter.toc(enable: false),
  frontbackmatter.acknowledgements(text: [This text must not be rendered.]),
  frontbackmatter.acknowledgements(enable: false),
  component.body.header(enable: false),
  component.body.footer(generator-function: none),
  feature.drafting(watermark: [HIDDEN], watermark-generator: none),
  component.appendix.entries(appendices: (
    (
      title: [Hidden appendix],
      text: [This appendix must not be rendered.],
    ),
  )),
  // Arrays replace rather than merge: this clears the previously supplied entry.
  component.appendix.entries(appendices: ()),
)

= Body only

This document has no cover, table of contents, acknowledgements, declarations,
header, footer, watermark, or appendix. Explicit suppression overrides the
theme and institution while retaining body typography.
