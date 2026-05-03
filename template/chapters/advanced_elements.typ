#import "basic_formatting.typ": typst-preview
#import "../utils.typ": caption-with-source

= Advanced Elements

== Figures
Inserting figures and code blocks into your Typst document enhances its informational depth. When specifying a `caption` for a figure, the template will automatically generate a list of figures, making it easy to navigate your document.

/ Note: When using "ieee" Sorting for bibliography, the sources for figures will be evaluated before the text. To prevent "false sorting", you can use `#caption-with-source("Text", [@source])` instead. This will display the caption in outlines without source and will evaluate the source at the time the figure is displayed

=== Image Figures
#typst-preview(
  "Image Figures in Typst",
  "#import \"../utils.typ\": caption-with-source
#figure(
  image(\"../do_not_touch/Company-Logo.svg\"),
  caption: caption-with-source(\"Comapny Logo\", [@electronic]),
)",
)

=== Tables

Similar to images you can insert table figures. See more table examples and more advanced usage in @appendix-table-examples.

#typst-preview(
  "Table Figures in Typst",
  "#import \"../utils.typ\": tablefigure
#tablefigure(
  columns: 3,
  caption: [Example table],
  table-content: (
    table.header([Name], [Age], [Gender]),
    [Alice], [28], [Female],
    [Bob], [34], [Male],
    [Charlie], [22], [Male],
  )
)",
)


=== Code Snippets

#import "../utils.typ": codefigure, codefigurefile

This template uses #link("https://typst.app/universe/package/codly")[Codly] for code snippets. Look at their documentation on how to further customize and control your code blocks.

Besides that the template provides two functions to create code snippet figures that get listed in a source code listing: `codefigure` and `codefigurefile`.

Use `codefigure` to display a code figure from the provided code.

#typst-preview(
  "Code Figures in Typst",
  "#import \"../utils.typ\": codefigure

#codefigure(caption: [My Code])[```rust
fn main() {
  println!(\"Hello World!\");
}
```]",
)

Use `codefigurefile` to create a code snippet figure from the content of a file. Note that the provided file is searched relative to the location of your `main.typ` file.

#typst-preview(
  "Code Figure loading from file",
  "#import \"../utils.typ\": codefigurefile

#codefigurefile(\"assets/example-code.typ\", caption: [My Code from a file])",
)

== Math
The math syntax is a loose interpretation of LaTeX, allowing you to create complex mathematical equations with ease.
See #link("https://typst.app/docs/reference/math/", "the Typst documentation") for a detailed overview of the math syntax.

#typst-preview(
  "Math in Typst",
  "$
  sum_(k=0)^n k
  &= 1 + ... + n \
  &= (n(n+1)) / 2 \
$",
)

== Block Quotes

#typst-preview(
  "Quotes in Typst",
  "#quote(
  attribution: [Frankling D. Roosevelt @fdr_inaugural_address]
)[
  The only thing we have to fear is fear itself.
]",
)

== Notes

#import "@preview/drafting:0.2.2": *

This template uses #link("https://typst.app/universe/package/drafting/")[Drafting] for notes.
Using `margin-note` you can add notes to #margin-note("Anywhere in your document!") the margin of your document.

#inline-note[You can also add inline notes to your document with `inline-note`]

Check out their documentation for more advanced use casese.

You might have noticed the notes listing on the first page of this document.
This listing reminds you of the notes still present in your document. Once you remove all notes, the listing will disapear.
