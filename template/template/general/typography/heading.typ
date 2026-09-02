// https://alistapart.com/article/more-meaningful-typography/
#let modular-scale(font-config, scale) = {
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
