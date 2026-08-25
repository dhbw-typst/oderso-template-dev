// https://alistapart.com/article/more-meaningful-typography/
#let modular-scale(font-config, scale) = {
  return (
    font: font-config.font,
    sizes: (
      font-config.size * calc.pow(scale, 4), // h1
      font-config.size * calc.pow(scale, 3), // h2
      font-config.size * calc.pow(scale, 2), // h3
      font-config.size * calc.pow(scale, 1), // h4
    ),
  )
}
