#let ket(psi) = $lr(|#psi angle.r)$
#let bra(psi) = $lr(angle.l #psi|)$
#let ketbra(a, b) = $|#a angle.r angle.l #b|$

#let tp = $times.circle$
#let id = [$bb(1)$]


#import "@preview/ctheorems:1.1.3": *
#let lemma = thmplain("lemma", "Lemma", inset: (x: 0cm, top: 0cm))
#let proof = thmproof("proof", "Proof")
#show: thmrules.with(qed-symbol: $square$)
