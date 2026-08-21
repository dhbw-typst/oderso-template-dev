#import "../config/lib.typ" as config

/// Configure arbitrary metadata of the document, used by adapters and components. Low level configuration, is only called from adapters but may be used modify internal behaviour. -> dictionary
#let metadata(
  ..metadata,
) = {
  assert(metadata.pos().len() > 0, message: "Only named arguments are allowed, remove positional arguments.")

  let named = metadata.named()
  return (
    general: (
      metadata: named,
    ),
  )
}
