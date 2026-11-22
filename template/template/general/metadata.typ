#import "../config/lib.typ" as config

/// Patch final semantic metadata (authors, title-long, thesis-type,
/// submission-date, examination, study, company, and supervisors). Institution
/// generators read the effective values, not setup-time snapshots. Explicit
/// submission-info and misc-key-value remain low-level cover escape hatches.
/// Datetime submission dates use submission-date-format at render time.
/// -> dictionary
#let metadata(
  ..metadata,
) = {
  assert(
    metadata.pos().len() == 0,
    message: "Only named arguments are allowed, remove positional arguments.",
  )

  let named = config.util.get-dict-without-default(metadata.named())
  return (
    general: (
      metadata: named,
    ),
  )
}
