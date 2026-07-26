#import "@preview/codly:1.3.0" as codly
#import "@preview/drafting:0.2.2" as drafting
#import "@preview/glossarium:0.5.10" as glossarium

#import "adapters/dhbw-ka.typ": dhbw-ka-adapter
#import "adapters/dhbw-ma.typ": dhbw-ma-adapter
#import "adapters/ihk.typ": ihk-adapter
#import "adapters/config.typ": (
  configure-confidentiality-clause, configure-dhbw-ka-ai-acknowledgement,
  configure-dhbw-ma-ai-declaration-form, configure-statutory-declaration,
)
#import "utils.typ": (
  caption-with-source, inline-glossary, styled-table, table-hline-spaced,
  tablefigure, tablefigure-raw,
)
#import "config.typ": (
  configure-abbreviations, configure-abstracts, configure-acknowledgements,
  configure-appendices, configure-bibliography, configure-figure-listings,
  configure-glossary, configure-page, configure-toc,
)
#import "base.typ": project
