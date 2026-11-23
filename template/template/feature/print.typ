#import "../config/lib.typ" as config

/// Reversible print-output policy; never changes submission metadata. Duplex
/// mirrors final left/right margins to inside/outside, preserving asymmetry and
/// existing logical margins. Binding space is an intentional additive transform.
/// Native scoped page rules can override effective output for unusual layouts.
/// -> dictionary
#let print(
  /// Presence activates by default; omission inherits explicit disabling. -> bool
  enable: config.util.default-value,
  /// Mirror margins using physical page parity, not reset page counters. -> bool
  two-sided: config.util.default-value,
  /// Extra inner/left space; added to the intact resolved base margins. -> relative
  binding-space: config.util.default-value,
  /// auto starts ordinary chapters on recto in duplex. Explicit false/even/odd
  /// general.layout chapter policies are retained; false disables recto policy. -> auto | bool
  recto-chapters: config.util.default-value,
) = {
  config.validation.validate-enable(enable)
  config.validation.validate-enable(two-sided)
  config.validation.validate-relative(binding-space, "binding-space")
  assert(
    recto-chapters == config.util.default-value
      or recto-chapters in (auto, true, false),
    message: "`recto-chapters` must be auto or boolean",
  )
  (
    feature: (
      print: config.util.get-dict-without-default((
        enable: enable,
        two-sided: two-sided,
        binding-space: binding-space,
        recto-chapters: recto-chapters,
      )),
    ),
  )
}

#let _output-policy(cfg) = {
  let settings = cfg.feature.at("print", default: (:))
  let enabled = "print" in cfg.feature and settings.at("enable", default: true)
  let duplex = enabled and settings.at("two-sided", default: true)
  let recto = settings.at("recto-chapters", default: auto)
  let breaking = cfg.general.layout.at("pagebreak-heading", default: false)
  // Only ordinary/unspecified chapter breaks are transformed. Explicit false
  // and parity selectors remain authoritative, even when contributed by a theme.
  if (
    duplex
      and recto != false
      and (breaking == true or "pagebreak-heading" not in cfg.general.layout)
  ) {
    breaking = "odd"
  }
  (
    print: enabled,
    two-sided: duplex,
    binding-space: if enabled {
      settings.at("binding-space", default: 0pt)
    } else { 0pt },
    pagebreak-heading: breaking,
  )
}

#let _print-margin(margin, output) = {
  if not output.print { return margin }
  if output.two-sided {
    if "left" in margin { margin.insert("inside", margin.remove("left")) }
    if "right" in margin { margin.insert("outside", margin.remove("right")) }
    margin.inside = margin.at("inside", default: 0pt) + output.binding-space
  } else {
    // Simplex uses the same binding edge on every physical sheet.
    if "inside" in margin { margin.insert("left", margin.remove("inside")) }
    if "outside" in margin { margin.insert("right", margin.remove("outside")) }
    margin.left = margin.at("left", default: 0pt) + output.binding-space
  }
  margin
}
