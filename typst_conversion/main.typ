#import "conf.typ": ut-thesis, chapter
// #import("conf.typ")
#include "macros.typ"

// Example Usage
#show: ut-thesis.with(
    title: "Preparing Thermal States on a Digital Quantum Computer",
    author: "Matthew Hagan",
    degree: "Doctor of Philosophy",
    department: "Physics",
)

// #import "@preview/ctheorems:1.1.3": *
// #show: thmrules
// #show: thmrules.with(qed-symbol: $square$)

Junk.

#chapter("test one")

= Introduction
#include "intro.typ"

== Research Background
More detailed content about the research context.

= Conclusion
Concluding remarks of the dissertation.

#figure(
    table(
        "1", "2", "3"
    ),
    caption: [],
)

#bibliography("references.bib")
