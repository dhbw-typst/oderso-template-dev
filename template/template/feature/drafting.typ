#import "../config/lib.typ" as config
#import "@preview/drafting:0.2.2": note-outline

/// Drafting capability and placement, independent of note/watermark appearance.
/// Presence activates by default; patches inherit explicit disabling.
/// -> dictionary
#let drafting(
  /// Disable drafting output while preserving settings. -> bool
  enable: config.util.default-value,
  /// Watermark content; requires a visual preset or custom generator. -> content | none
  watermark: config.util.default-value,
  /// Generator (cfg); none suppresses it. -> function | none
  watermark-generator: config.util.default-value,
  /// Whether to render a note listing. -> bool
  notes-listing: config.util.default-value,
  /// none lists notes before the cover; an integer installs a
  /// keyed drafting-notes matter entry at that signed position. -> int | none
  notes-position: config.util.default-value,
) = {
  config.validation.validate-enable(enable)
  config.validation.validate-enable(notes-listing)
  config.validation.validate-generator(watermark-generator)
  assert(
    notes-position == config.util.default-value
      or notes-position == none
      or type(notes-position) == int,
    message: "`notes-position` must be an integer or none",
  )
  (
    feature: (
      drafting: config.util.get-dict-without-default((
        enable: enable,
        watermark: watermark,
        watermark-generator: watermark-generator,
        notes-listing: notes-listing,
        notes-position: notes-position,
      )),
    ),
  )
}

#let _notes(cfg) = context {
  if query(selector(<margin-note>).or(<inline-note>)).len() > 0 {
    set heading(numbering: none, outlined: false)
    note-outline(title: config.util.linguify-content("list-of-notes"))
  }
}
