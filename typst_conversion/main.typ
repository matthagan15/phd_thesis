#import "conf.typ": ut-thesis, chapter
// #import("conf.typ")
#import "@preview/hydra:0.6.1": hydra
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

#include "intro.typ"
#include "composite.typ"

#bibliography("references.bib")
