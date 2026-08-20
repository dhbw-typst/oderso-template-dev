#import "../config/lib.typ" as config

/// Configure options regarding drafting.
/// This includes notes and the watermark.
/// See #link("https://typst.app/universe/package/drafting/")[Drafting] for more information on how to add notes.
/// -> dictionary
#let drafting(
  /// A watermark to show on the document margins -> content
  watermark: config.util.default-value,
  /// Generator function used to display the watermark -> function
  watermark-generator: config.util.default-value,
  /// Whether to display a list of notes at the very first page of the document. -->
  notes-listing: config.util.default-value,
) = {
  validate-enable(notes-listing)
  return (
    drafting: config.util.get-dict-without-default((
      watermark: watermark,
      notes-listing: notes-listing,
    )),
  )
}