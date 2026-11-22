// Independent typography scopes, using fonts bundled with Typst.
#import "../template/template/lib.typ": (
  component, frontbackmatter, general, project, theme,
)

#show: project.with(
  theme.spotless(),
  component.coversheet(enable: false),
  frontbackmatter.toc(enable: false),
  general.layout(pagebreak-heading: false),
  general.typography.body(..general.typography.font.new-computer-modern),
  // A later size/spacing patch does not clear the inherited font or leading.
  general.typography.body(size: 11pt, spacing: 0.8em),
  general.typography.heading(
    font: "Libertinus Serif",
    sizes: (20pt, 16pt, 13pt),
    numbering: "1.1",
  ),
  general.typography.caption(font: "Libertinus Serif", size: 0.85em),
  general.typography.code(font: "DejaVu Sans Mono", size: 0.9em),
  general.typography.math(font: "New Computer Modern Math", size: 1.1em),
)

= Body and headings

The body uses New Computer Modern at eleven points. Heading sizes are explicit
and do not rescale with the body. *Bold*, _italic_, and `inline_code()` provide
contrasting text samples.

This second paragraph makes the paragraph spacing visible. It contains several
lines of text so that changes to font metrics and line leading can be inspected
independently of the spacing between paragraphs.

== Second-level heading

=== Third-level heading

#figure(
  rect(width: 60%, height: 12mm, fill: teal.lighten(85%)),
  caption: [A caption with independent font and size.],
)

```python
def square(value):
    return value * value
```

$ sum_(k=1)^n k = (n(n + 1)) / 2 $ <typography-equation>

Equation @typography-equation uses the separate math typography settings.
