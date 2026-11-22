// Base rendering: no implicit theme, cover, outline, header, or footer.
#import "../template/template/lib.typ": project

#show: project.with()

= Minimal document

This example uses only the base template. Typography and layout retain Typst's
defaults because no theme or institution is selected.

== Basic content

Text can be *bold*, _emphasized_, or `inline code`.

- An unordered list item
- Another list item

+ A numbered item
+ Another numbered item

A footnote is ordinary document content.#footnote[An example footnote.]
