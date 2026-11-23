#import "../template/template/lib.typ": *

// Capabilities work without a theme; visual helpers compose independently.
#show: project.with(
  general.typography.body(size: 11pt),
  component.page(margin: 2cm),
  feature.codly(display-icon: false, display-name: false),
  feature.codly(fill: luma(245)),
  feature.drafting(notes-listing: true, notes-position: 10, watermark: [Proof]),
  theme.shared.watermark(),
  theme.shared.notes(),
  theme.shared.inline-code(fill: luma(245)),
)

= Theme-independent features
Inline `code` uses a visual preset. Block code uses the Codly adapter.

```typ
#let answer = 42
```

#dependency.drafting.inline-note[Replace this example before submitting.]
