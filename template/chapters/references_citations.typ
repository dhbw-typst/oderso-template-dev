#import "../utils.typ": codefigure
#import "basic_formatting.typ": typst-preview
= References and Citations

== Local Elements
You can reference local elements like figures, code blocks, and sections using the `ref()` function. You can also use the synax sugar `<ref>` to define and `@<ref>` to reference references.

#typst-preview(
  "Local Element References in Typst",
  "=== Important Section <section-1>
Some important text

=== Other Section
More important text, just like @section-1",
)

== Code Blocks
If you use the provided `codefigure` function, you can specify a reference name via the `reference` parameter. This allows you to reference the code block later in the document.

#typst-preview(
  "Code Figure Referencing in typst",
  "#import \"../utils.typ\": codefigure
#codefigure(caption: [Code with Reference], reference: \"my-rust-code\")[```rust
  fn main() {
    panic!(\"Hilfe!\");
  }
  ```]

  Look at my code in @my-rust-code!",
)

== Bibliography
Typst supports references to external sources, such as books, articles, and websites. You can include a `.yaml` or `.bib` file with your references and use the `cite()` function to reference them in your document. Again, you can use the same syntax sugar `@<ref>` to cite.

#typst-preview(
  "Bibliography Referencing in Typst",
  "#quote(attribution: [Molly Weasley\ @harry[S.~768]])[
  Just Because You're Allowed To Use Magic Now Does Not Mean You Have To Whip Your Wands Out For Everything!]",
)

== Acronyms
Specify acronyms in the project configuration to use them throughout your document. You can use the `@acr` function to reference acronyms and the `@acr:pl` function to reference their plural form.

#typst-preview(
  "Acronyms in Typst",
  "I don't understand @NN or @NN:pl and never will understand.",
)

On the first usage, the full form of the acronym is displayed, and on subsequent usages, only the acronym is shown. Additionally, used acronyms are displayed in the glossary section in the preamble.
