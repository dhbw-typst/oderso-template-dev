// LTeX: enabled=false
#import "_shared.typ": make-header, make-footer, make-toc, make-page

/// Configure the table of contents entry for the appendix. -> dictionary
#let toc = make-toc("appendix")

/// Configure the header for the appendix section only. -> dictionary
#let header = make-header("appendix")

/// Configure the footer for the appendix section only. -> dictionary
#let footer = make-footer("appendix")

/// Configure the page settings (numbering, margin) for the appendix section only. -> dictionary
#let page = make-page("appendix")
