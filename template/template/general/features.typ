#import "../config/lib.typ" as config

/// Configure options regarding drafting.
/// This includes notes and the watermark.
/// See #link("https://typst.app/universe/package/drafting/")[Drafting] for more information on how to add notes.
/// -> dictionary
#let drafting(
  /// A watermark to show on the document margins -> content
  watermark: config.util.default-value,
  /// Generator `(cfg) -> content`. Omission inherits the theme; none suppresses it. -> function | none
  watermark-generator: config.util.default-value,
  /// Whether to display a list of notes at the very first page of the document. --> bool
  notes-listing: config.util.default-value,
) = {
  config.validation.validate-enable(notes-listing)
  config.validation.validate-generator(watermark-generator)
  return (
    general: (
      drafting: config.util.get-dict-without-default((
        watermark: watermark,
        watermark-generator: watermark-generator,
        notes-listing: notes-listing,
      )),
    ),
  )
}

#let layout(
  /// Paper identifier accepted by Typst. -> str
  paper: config.util.default-value,
  /// Whether paragraphs are justified. -> bool
  justify: config.util.default-value,
  /// Whether quotes are block quotes by default. -> bool
  block-quotes: config.util.default-value,
  /// Whether level 1 headings should start on next page (`true`), even (`"even"`) or odd (`"odd"`) page.
  pagebreak-heading: config.util.default-value,
) = {
  config.validation.validate-enable(justify)
  config.validation.validate-enable(block-quotes)
  assert(
    paper == config.util.default-value or type(paper) == str,
    message: "`paper` must be a string",
  )
  assert(
    pagebreak-heading == config.util.default-value
      or pagebreak-heading in (true, false, "even", "odd"),
    message: "`pagebreak-heading` must be true, false, even, or odd",
  )
  return (
    general: (
      layout: config.util.get-dict-without-default((
        paper: paper,
        justify: justify,
        block-quotes: block-quotes,
        pagebreak-heading: pagebreak-heading,
      )),
    ),
  )
}
