// Signed positions determine section and order; position-only patches inherit data.
#import "../template/template/lib.typ": (
  component, frontbackmatter, project, theme,
)

#show: project.with(
  theme.spotless(),
  component.coversheet(enable: false),
  component.frontmatter.footer(show-total-pages: true),
  frontbackmatter.acknowledgements(text: [
    Thanks to the contributors who maintain this template and its examples.
  ]),
  frontbackmatter.acknowledgements(position: -90),
  frontbackmatter.abstracts(abstracts: (
    (
      lang: "de",
      lang-display: "Deutsch",
      text: [Dieses Beispiel zeigt zwei Abstracts vor dem Haupttext.],
    ),
    (
      lang: "en",
      lang-display: "English",
      text: [This example places two abstracts before the main document.],
    ),
  )),
  // Configure glossary first, but render it after the bibliography by position.
  frontbackmatter.glossary(position: 20, generator-function: cfg => [
    #heading(numbering: none)[Second back-matter entry]
    This custom glossary entry follows the entry at position zero.
  ]),
  frontbackmatter.bibliography(position: 0, generator-function: cfg => [
    #heading(numbering: none)[First back-matter entry]
    Zero is a back-matter position, not a front-matter position.
  ]),
)

= Main document

The front matter contains acknowledgements, German and English abstracts, and
the table of contents. Its Roman numbering restarts independently of the body.

== Ordering

The back matter uses alphabetic page numbers and sorts by signed position,
not the order of configuration calls.
