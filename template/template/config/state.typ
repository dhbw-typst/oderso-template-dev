#let _config = state("oderso-config", (:))

#let config() = context {
  return _config.at(here())
}

/// Internal state to track whether we are currently rendering an outline.
/// -> state
#let _in-outline = state("in-outline", false)
#let in-outline = context {
  return _in-outline.at(here())
}