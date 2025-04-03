#import "macros.typ": *
#import "conf.typ": *
// #import "main.typ": *

// #set text(font: "New Computer Modern", size: 10pt)
// #set par(justify: true, leading: 1em)

// #show: thmrules
// #show: thmrules.with(qed-symbol: $square$)


= Introduction

The goal of this thesis is to serve as a blueprint for creating quantum channels that can prepare thermal states of arbitrary systems. This framework was primarily created as an algorithmic process to prepare input states of the form $rho (beta) = (e^(-beta H)) / tr (e^(-beta H))$, known as Gibbs, Boltzmann, or thermal states, for simulations on a digital, fault-tolerant quantum computer. As $rho (beta)$ approaches the ground state as the inverse temperature $beta$ diverges, meaning Gibbs states serve as useful proxies for problems in which ground states dictate features of dynamics, such as the electron wavefunction in banded condensed matter systems or in chemical scenarios. One of the key features of our algorithm is the addition of only one single extra qubit outside of those needed to store the state of quantum system being simulated. This may seem like a minor technical achievement, given the existence of Gibbs samplers that also have only one extra qubit or at worst a constant number of qubits overhead, but the way in which this single qubit is utilized in our algorithm highlights the connections between our channel as an algorithmic tool to prepare states of interest and the model of thermalization that we believe the physical world may actually follow. The rest of this introduction is to provide context for how the technical results contained in later chapters of this thesis contribute to the growing interplay between Physics and Theoretical Computer Science within the realm of Quantum Computing.

The easiest way to grasp the context of this thesis is to first understand classical thermal states. In classical mechanics we typically have access to a Hamiltonian $H$ that is a function on phase space $(x, p)$ to the reals $RR$. We can turn this function into a probability distribution via the canonical ensemble $p_beta (x, p) = (e^(- \beta H(x, p))) / (integral d x d p e^(-beta H(x, p)))$, which can be thought of as the ``density'' of particles near a particular $(x,p)$ in phase space for a thermodynamically large collection of non-interacting particles under the same Hamiltonian $H$. The inverse temperature $beta$, typically taken to be $ 1/ (k_beta T)$ where $k_beta$ is Boltzmann's constant and T the temperature, plays an important role in shaping the distribution $p_beta(x,p)$. For example, in the $beta -> oo$ the distribution becomes concentrated at the minimum energy points of $H(x, p)$, which correspond to points with zero momentum $p=0$ and are minimums of the potential energy $V(x)$. This shows that the problem of preparing classical thermal states somehow ``contains'' the problem of function optimization, and in fact being able to sample from classical thermal states for arbitrarily large $\beta$ allows us to approximate the partition function $cal(Z) = integral e^(-\beta H(x,p)) d x d p$, which is known to be a \#P-Hard computational problem.


// asdf
// In everyday life we interact with temperature on an intuitive sense: hot objects cool down, refrigerators consume energy to keep things cold, and the winters here in Toronto suck all possible heat out of every living thing. We typically don't think too much about how these systems equilibrate, we now that there are convection currents in liquids that transport heat, that solids, metals in particular, conduct heat naturally and that radiation can transmit heat, which occurs in microwaves and from sunlight. If you are cooking a roast and want to know if it's done, you just stick the thermometer in and wait a few seconds for it to equilibrate. You don't need for the thermometer to meet some kind of interaction model between the thermometer and the food, it just equilibrates given enough time.

// This intuitive understanding breaks down at the quantum level. For starters, to observe delicate quantum effects experimentalists will typically try to isolate their desired system as much as possible from the environment, which can decohere sensitive wavefunctions. When the system is completely isolated from the environment, what does "equilibrium" even refer to? One of the leading answers to this question says that for large systems, sufficiently "random looking" Hamiltonians can appear to be in thermal equilibrium to local observables. A large enough, random enough system can act as it's own bath to small subsystems. The codification of these conditions is known as the Eigenstate Thermalization Hypothesis (ETH), which is yet to be proven for all possible systems (hence the name Hypothesis).

// The picture of thermalization that we address is an intermediate model of the two previously mentioned, where instead of modeling infinite baths or having no baths at all we instead consider a very tiny environment that is consistently refreshed. This model, known as the Repeated Interactions (RI) model, is appealing for many different reasons. For starters, since the environment is small enough we can often compute the effects on the system directly. So far, physicists have mostly studied this model for small systems in which these interactions can be explicitly modeled, such as 2 or 3 level systems. Oftentimes the interaction model between these small systems and the environment is chosen to lead to a thermal state on the system.

// We extend the Repeated Interactions model to arbitrary non-degenerate systems via a randomized interaction. This not only extends the validity of the Repeated Interactions model greatly, thus providing a physically plausible model for thermalization, but also provides an algorithm for preparing thermal states on digital quantum computers. We are able to prove both correctness, meaning the output of the algorithm is $epsilon$ close to the thermal state, and bound the runtime in the weak coupling limit. This runtime bound is interesting in it's own right as bounding the runtime of the algorithm in the ground state limit is difficult, however in our scenario the runtime bound becomes completely explicit.

// Although the resulting quantum channel we develop almost directly resembles the Repeated Interactions framework, the route we took was inspired entirely by the classical sampling algorithm called Hamiltonian Monte Carlo (HMC). HMC takes the original Metropolis-Hastings algorithm, which involves a filtered random walk over the state space, and modifies the random walk steps to instead simulate time evolution under Hamiltonian dynamics. This modification drastically improved the original algorithm's scaling with respect to the dimension of the problem and offered less correlated samples empirically. This thesis can be viewed as an effort to extend this algorithm, which is heavily inspired by physics, to the realm of quantum computing.

// This thesis is organized as follows. The rest of this chapter will be devoted to preliminary discussion on relevant quantum computing topics, namely how to implement time evolution operators for Pauli sum Hamiltonians. The next chapter is devoted to improvements in basic product formula techniques via a composite or partially randomized compilation scheme. We then utilize these results in Chapter to develop our quantum algorithm for preparing thermal states. To complement our analytic discussions we provide extensive numeric evidence in support of our routines.

// == Introduction to Product Formulae

// One of the key themes in this thesis is that time dynamics can be used to generate thermal states. In this section we introduce one of the most straightforward methods for implementing time independent Hamiltonian evolution on a quantum computer. We will not introduce basic quantum computing preliminaries, such as universality and various gate sets, but we will take strides to reduce the algorithms to primitives that are as simple as possible.

// Quantum mechanics starts with the notion of a Hilbert space. Oftentimes problems can become much clearer once one can clearly identify and manipulate the Hilbert space under investigation. We will work with relatively straightforward Hilbert spaces in this thesis, those consisting of $n$ qubits $cal(H) = CC^(2) times CC^(2) times ... times CC^(2) = CC^(2^n)$. Watrous prefers the term "Complex Euclidean Spaces" for these finite dimensional Hilbert spaces. A state $ket(psi)$ is an $L_2$ normalized vector and given a Hamiltonian $H$ that dictates the dynamics of the system, the time evolution is given by the time independent Schrodinger equation
// $
//     i planck.reduce (diff psi(t)) / (diff t) = H(t) psi(t)
// $
// For the rest of this thesis $planck.reduce = 1$.

// Our use of qubit Hilbert spaces gives us access to the Pauli operators $I_i, X_i, Y_i, Z_i$ for each qubit $i$, which we can then string together to form a Pauli string, here is an example on 4 qubits $P = X_1 tp I_2 tp Y_3 tp Z_4$. Typically we will drop the tensor product symbol $tp$ and drop the identity factors, so the previous example will be written as $P = X_1 Y_3 Z_4$. A useful fact about Pauli operators is that they can be exponentiated fairly easily due to the identity $e^(i theta P) = cos(theta) I + i sin(theta) P$. We now will show how these rotations can be implemented given only single qubit rotations and CNOT gates. Here is a basic example of how to do a two qubit rotation $e^(i theta Z tp Z)$.

// - TODO: Convert to quill
// ```tex
// \begin{table}[h]
//     \[
//     \begin{array}{c c c}
//         \Qcircuit @C=1em @R=.7em {
//             & \ctrl{2} & \qw      & \qw                & \qw      & \ctrl{2} & \qw \\
//             & \qw      & \ctrl{1} & \qw                & \ctrl{1} & \qw      & \qw\\
//             & \targ    & \targ    & \gate{R_Z(2 \theta)} & \targ    & \targ    & \qw
//         } &  = & \Qcircuit @C=1em @R = 0.7em {
//              & \gate{e^{i \theta Z_1 Z_2}} & \qw
//         }
//     \end{array}
//     \]
//     \caption{$Z_1 Z_2$ rotation.}
// \end{table}
// ```
// This is a slightly abstracted circuit, as arbitrary angle $Z$ rotations are not typical circuits that real quantum computers can do. To further compile this, one would need to decompose the single qubit $Z$ rotation into some universal gate set, typically Clifford + T, using an algorithm such as the Ross-Sellinger single qubit rotation algorithm. For this thesis we will assume access to single qubit rotations and CNOT gates as our universal gate set.


// To extend this to arbitary $n$ qubit Paulis with possibly $X$ or $Y$ Paulis as well we can repeat the same circuit but with a change of basis. With the basic circuit identities that $X = H Z H$ and $Y = S Z S^dagger$. We can then change basis from the computation basis states to those of the Pauli we are interested in, do the computation in the $Z$ basis, and then change back to the computation basis. For instance, here is how we could do the rotation $e^{i X_1 Y_2 Z_3 theta}$
// - TODO: Convert to quill
// ```tex
// \begin{table}[h]
// \[
// \begin{array}{c}
//     \Qcircuit @C=1em @R=0.8em {
//         & \gate{H} & \ctrl{3} & \qw & \qw & \qw & \qw & \qw & \ctrl{3} & \gate{H} \\
//         & \gate{S^\dagger} & \qw & \ctrl{2} & \qw & \qw & \qw & \ctrl{2} & \qw & \gate{S} \\
//         & \gate{I} &\qw & \qw & \ctrl{1} & \qw & \ctrl{1} & \qw & \qw & \gate{I} \\
//         \lstick{\ket{0}} & \qw & \targ & \targ & \targ & \gate{R_Z(2\theta)} & \targ & \targ & \targ & \qw
//     }
// \end{array}
// \]
// \caption{Mixed Pauli rotations}
// \end{table}
// \todo{Lemmize this}
// ```

// We will now collect these basic observations, along with an optimization that eliminates the ancilla qubit, in the following lemma.
// #lemma("Pauli Rotations")[
//     Let $P$ be an $n$ qubit Pauli operator and $U_P$ the change of basis unitary from a product of $Z$ operators, i.e
//     $
//         P = U_P (Z_1^{p_1} Z_2^{p_2} dots Z_n^{p_n}) U_P^dagger,
//     $

//     where each power $p_i$ is 0 or 1. The support of $P$, or the qubits in which $P$ acts nontrivially on, is denoted $"supp"(P)$ and is the set of nonzero $p_i$. We denote the cardinality $|"supp"(P)| = w$, as it is typically referred to as the weight of $P$, and let $s_w$ denote the largest index in supp$(P)$. The time evolution operator $e^(i P t)$ can be performed with $2(w-1)$ CNOT gates and one single qubit $Z$ rotation via the following identity
//     $
//         e^{i P t} = U_P (product_(i in "supp"(P) without s_w) "CNOT"(i, s_w) R_(Z_(s_w))(t) product_(i in "supp"(P) without s_w) "CNOT"(i, s_w) ) U_P^dagger.
//     $
//     This construction uses no additional ancilla qubits.
//     asdf
//     straightforwardsdaf
//     dsf
//     dsf


//     food
// ]
// #proof[
//     We first note that
//     $
//         e^(i P t) = sum_(k = 0)^infinity (i t)^k / k! P^k = sum_(k = 0)^infinity (i t)^k / k! (U_P product_i Z_i^(p_i) U_P^dagger)^k = U_P ( sum_(k = 0)^(oo) (i t)^k / k! (product_i Z_i^(p_i) )^k ) U_P^dagger = U_P e^(i product_i Z_i^(p_i) t) U_P^dagger.
//     $

//     This reduces our problem from arbitrary Pauli rotations to just Pauli $Z$ rotations. We now need to show that the CNOT sequence and single qubit $Z$ rotation perform arbitrary tensor product $Z$ rotations. Let CNOT$(i,j)$ be a controlled NOT gate with control qubit $i$ and target qubit $j$. Let $ket(s) = ket(s_1) ket(s_2) dots ket(s_w)$ denote a basis state for the qubits that are in the support of $P$. As CNOT$(1,2) ket(a) ket(b) = ket(a) ket(a plus.circle b)$, where $a plus.circle b$ is the addition of $a$ and $b$ mod 2, we have that the product
//     $
//         product_(i in "supp"(P) without s_w) "CNOT"(i, s_w) ket(s) = ket(s_1) dots ket(s_(w-1)) ket(s_1 plus.circle s_2 plus.circle dots plus.circle s_w)
//     $
//     stores the parity of the entire basis state in the last qubit. Applying a $Z$ rotation on the last qubit then yields the following
//     $
//         R_(Z_(s_w)) (t) ket(s_1) dots ket(s_(w-1)) &= ket(s_1) dots ket(s_(w- 1)) ( R_Z(t) ket(s_1 plus.circle dots plus.circle s_w) ) \
//         &= e^(i plus.circle_(i = 1)^w s_i t) ket(s_1) dots ket(s_(w- 1)) ket(s_1 plus.circle dots plus s_w).
//     $
// ]

