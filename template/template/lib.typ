// LTeX: enabled=false
// Public API for the oderso Typst template.
//
// Import with: #import "template/lib.typ": *
// Then use: #show: project.with(theme.spotless(), institution.dhbw-ka.setup(...), ...)
// Content helpers use util.*; third-party packages use dependency.*.

#import "dependency.typ" as dependency

#import "theme/lib.typ" as theme
#import "general/lib.typ" as general
#import "feature/lib.typ" as feature
#import "institution/lib.typ" as institution
#import "frontbackmatter/lib.typ" as frontbackmatter
#import "component/lib.typ" as component

#import "util.typ" as util

#import "base.typ": project
