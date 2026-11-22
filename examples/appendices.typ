// Appendix headings, references, outline, and section-local page components.
#import "../template/template/lib.typ": component, general, project, theme

#show: project.with(
  theme.spotless(),
  component.coversheet(enable: false),
  general.metadata(title-short: "Appendix example"),
  component.appendix.header(
    height: 8mm,
    generator-function: (cfg, total) => align(right)[Supplementary material],
  ),
  // The theme disables appendix footers; re-enabling keeps its generator.
  component.appendix.footer(enable: true, show-total-pages: true),
  component.appendix.entries(appendices: (
    (
      title: [Measurements],
      reference: "appendix-measurements",
      text: [
        == Experimental setup
        This nested heading belongs to the first appendix.

        #table(
          columns: 2,
          table.header([*Trial*], [*Value*]),
          [1], [42],
          [2], [43],
        )
      ],
    ),
    (
      // An entry without a reference is valid and still appears in the outline.
      title: [Additional notes],
      text: [This is a second, unreferenced appendix.],
    ),
  )),
)

= Results

The measurements are provided in @appendix-measurements. The main table of
contents excludes appendix headings, while the appendix has its own outline.
Appendix page numbering and header/footer settings are independent of the body.
