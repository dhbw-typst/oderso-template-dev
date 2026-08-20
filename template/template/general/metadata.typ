#import "../config/lib.typ" as config

/// Configure arbitrary metadata of the document, used by adapters and components. Low level configuration, is only called from adapters but may be used modify internal behaviour. -> dictionary
#let metadata(
  metadata: config.util.default-value,
) = {
  assert(
    metadata == config.util.default-value or type(metadata) == dictionary,
    message: "`metadata` must be a dictionary, got "
      + repr(metadata)
      + " of type "
      + str(type(metadata)),
  )

  if metadata == config.util.default-value {
    return (
      metadata: (:),
    )
  } else {
    return (
      metadata: metadata,
    )
  }
}