#import "../config/lib.typ" as config
#import "@preview/codly:1.3.0" as package

/// Configure Codly without a theme. Presence activates by default; option-only
/// patches inherit an explicit enable value. Disabling retains all options.
/// Initialization and final merged options apply once via the `feature-codly`
/// document rule (order -2000); dependency.codly remains available locally.
/// -> dictionary
#let codly(
  /// Explicit activation/deactivation; omission inherits. -> bool
  enable: config.util.default-value,
  /// Named options forwarded to Codly, merged recursively; arrays replace.
  ..options,
) = {
  config.validation.validate-enable(enable)
  assert(options.pos().len() == 0, message: "Codly options must be named")
  (
    feature: (
      codly: config.util.get-dict-without-default((
        enable: enable,
        options: options.named(),
      )),
    ),
  )
}

// Called only after all layers merge; no setup-time settings are captured.
#let _codly-rule(settings) = it => {
  show: package.codly-init
  package.codly(..settings.options)
  it
}
