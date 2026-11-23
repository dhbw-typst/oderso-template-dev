#import "../config/lib.typ" as config

/// Basic layout policy, independent of output features. -> dictionary
#let layout(
  /// Paper identifier accepted by Typst. -> str
  paper: config.util.default-value,
  /// Whether paragraphs are justified. -> bool
  justify: config.util.default-value,
  /// Whether quotes are block quotes by default. -> bool
  block-quotes: config.util.default-value,
  /// Level-1 chapter breaks: true, false, "even", or "odd".
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
  (
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
