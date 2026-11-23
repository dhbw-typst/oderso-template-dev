#import "../template/template/lib.typ": *

// typst compile --root . --input print=true examples/printing.typ proof.pdf
// The same configuration produces screen output with --input print=false.
#show: project.with(
  theme.spotless(),
  general.metadata(
    title-long: "Duplex proof",
    title-short: "Proof",
    authors: ((firstname: "Jane", lastname: "Doe"),),
    digital-only: true,
    digital-submission: true,
  ),
  component.page(margin: (left: 25mm, right: 20mm, y: 25mm)),
  feature.print(
    enable: sys.inputs.at("print", default: "false") == "true",
    two-sided: true,
    binding-space: 5mm,
  ),
)

= First chapter
Printing mirrors resolved margins and reserves binding space. Physical parity
includes the cover and frontmatter, despite section numbering resets.

#pagebreak()
This is the verso of the chapter's first page in duplex output.

= Second chapter
A printed proof does not change submission metadata or declaration wording.
