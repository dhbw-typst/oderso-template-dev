// Calibrated in font-testbed.typ to approximate Arial 12pt with 1.5-line Word
// spacing across different font metrics. Values are intentional, not rounding.

/// Calibrated Arial body preset. -> dictionary
#let arial = (
  font: "Arial",
  size: 12.04pt,
  spacing: 1.5em,
  leading: 1em,
)

/// Calibrated New Computer Modern body preset. -> dictionary
#let new-computer-modern = (
  font: "New Computer Modern",
  size: 12.7pt,
  spacing: 1.42em,
  leading: 0.946em,
)

/// Calibrated Libertinus Serif body preset used by spotless. -> dictionary
#let libertinus-serif = (
  font: "Libertinus Serif",
  size: 13.2pt,
  spacing: 1.366em,
  leading: 0.905em,
)
