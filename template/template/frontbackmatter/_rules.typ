#import "../config/lib.typ" as config
#import "../component/_shared.typ": _build-show-rules-entry

// All matter producers accept the same named hook arguments through ..rules.
#let _local-rules(
  show-key: config.util.default-value,
  show-order: config.util.default-value,
  show-fun: config.util.default-value,
  show-enable: config.util.default-value,
) = {
  let rules = _build-show-rules-entry(
    show-key,
    show-order,
    show-fun,
    show-enable: show-enable,
  )
  if rules.len() > 0 { (show-rules: rules) } else { (:) }
}
