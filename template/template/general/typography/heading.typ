#import "../../config/lib.typ" as config

/// Compute explicit sizes for heading levels 1–4 from a calibrated font preset
/// and a positive scale. These are snapshots of this preset, not live links to
/// later body overrides. See https://alistapart.com/article/more-meaningful-typography/.
/// -> dictionary
#let modular-scale(font-config, scale) = {
  config.validation.validate-typography(font-config)
  assert(
    type(font-config) == dictionary
      and "font" in font-config
      and "size" in font-config,
    message: "`font-config` must contain font and size",
  )
  assert(
    type(scale) in (int, float) and scale > 0,
    message: "`scale` must be a positive number",
  )
  return (
    font: font-config.font,
    sizes: (
      font-config.size * calc.pow(scale, 3), // h1
      font-config.size * calc.pow(scale, 2), // h2
      font-config.size * calc.pow(scale, 1), // h3
      font-config.size * calc.pow(scale, 0), // h4
    ),
  )
}
