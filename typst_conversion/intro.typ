#import("macros.typ"): *
= Motivation

In everyday life we interact with temperature on an intuitive sense: hot objects cool down, refrigerators consume energy to keep things cold, and the winters here in Toronto suck all possible heat out of every living thing. We typically don't think too much about how these systems equilibrate, we now that there are convection currents in liquids that transport heat, that solids, metals in particular, conduct heat naturally and that radiation can transmit heat, which occurs in microwaves and from sunlight. If you are cooking a roast and want to know if it's done, you just stick the thermometer in and wait a few seconds for it to equilibrate. You don't need for the thermometer to meet some kind of interaction model between the thermometer and the food, it just equilibrates given enough time. 

This intuitive understanding breaks down at the quantum level. For starters, to observe delicate quantum effects experimentalists will typically try to isolate their desired system as much as possible from the environment, which can decohere sensitive wavefunctions. When the system is completely isolated from the environment, what does "equilibrium" even refer to? One of the leading answers to this question says that for large systems, sufficiently "random looking" Hamiltonians can appear to be in thermal equilibrium to local observables. A large enough, random enough system can act as it's own bath to small subsystems. The codification of these conditions is known as the Eigenstate Thermalization Hypothesis (ETH), which is yet to be proven for all possible systems (hence the name Hypothesis).

The picture of thermalization that we address is an intermediate model of the two previously mentioned, where instead of modeling infinite baths or having no baths at all we instead consider a very tiny environment that is consistently refreshed. This model, known as the Repeated Interactions (RI) model, is appealing for many different reasons. For starters, since the environment is small enough we can often compute the effects on the system directly. So far, physicists have mostly studied this model for small systems in which these interactions can be explicitly modeled, such as 2 or 3 level systems. Oftentimes the interaction model between these small systems and the environment is chosen to lead to a thermal state on the system.

We extend the Repeated Interactions model to arbitrary non-degenerate systems via a randomized interaction. This not only extends the validity of the Repeated Interactions model greatly, thus providing a physically plausible model for thermalization, but also provides an algorithm for preparing thermal states on digital quantum computers. We are able to prove both correctness, meaning the output of the algorithm is $epsilon$ close to the thermal state, and bound the runtime in the weak coupling limit. This runtime bound is interesting in it's own right as bounding the runtime of the algorithm in the ground state limit is difficult, however in our scenario the runtime bound becomes completely explicit. 

Although the resulting quantum channel we develop almost directly resembles the Repeated Interactions framework, the route we took was inspired entirely by the classical sampling algorithm called Hamiltonian Monte Carlo (HMC). HMC takes the original Metropolis-Hastings algorithm, which involves a filtered random walk over the state space, and modifies the random walk steps to instead simulate time evolution under Hamiltonian dynamics. This modification drastically improved the original algorithm's scaling with respect to the dimension of the problem and offered less correlated samples empirically. This thesis can be viewed as an effort to extend this algorithm, which is heavily inspired by physics, to the realm of quantum computing. 

This thesis is organized as follows. The rest of this chapter will be devoted to preliminary discussion on relevant quantum computing topics, namely how to implement time evolution operators for Pauli sum Hamiltonians. The next chapter is devoted to improvements in basic product formula techniques via a composite or partially randomized compilation scheme. We then utilize these results in Chapter  to develop our quantum algorithm for preparing thermal states. To complement our analytic discussions we provide extensive numeric evidence in support of our routines. 

= Introduction to Product Formulae

One of the key themes in this thesis is that time dynamics can be used to generate thermal states. In this section we introduce one of the most straightforward methods for implementing time independent Hamiltonian evolution on a quantum computer. We will not introduce basic quantum computing preliminaries, such as universality and various gate sets, but we will take strides to reduce the algorithms to primitives that are as simple as possible. 

Quantum mechanics starts with the notion of a Hilbert space. Oftentimes problems can become much clearer once one can clearly identify and manipulate the Hilbert space under investigation. We will work with relatively straightforward Hilbert spaces in this thesis, those consisting of $n$ qubits $cal(H) = CC^(2) times CC^(2) times ... times CC^(2) = CC^(2^n)$. Watrous prefers the term "Complex Euclidean Spaces" for these finite dimensional Hilbert spaces. A state $ket(psi)$ is an $L_2$ normalized vector and given a Hamiltonian $H$ that dictates the dynamics of the system, the time evolution is given by the time independent Schrodinger equation

$
i h.slash (diff psi(t))/(diff t) = H(t) psi(t)
$

For the rest of this thesis $h.slash = 1$. 

Our use of qubit Hilbert spaces gives us access to the Pauli operators $I_i, X_i, Y_i, Z_i$ for each qubit $i$, which we can then string together to form a Pauli string, here is an example on 4 qubits $P = X_1 times I_2 times Y_3 times Z_4$. Typically we will drop the tensor product symbol $times$ and drop the identity factors, so the previous example will be written as $P = X_1 Y_3 Z_4$. A useful fact about Pauli operators is that they can be exponentiated fairly easily due to the identity $e^(i theta P) = cos(theta) I + i sin(theta) P$. 


First-order Trotter decomposition:
$
U_("TS")^(1)(t) := e^(i h_1 H_1 t)e^(i h_2 H_2 t) ... e^(i h_L H_L t)
$

Second-order Trotter formula:
$
U_("TS")^(2) = e^(i h_1 H_1 t/2) e^(i h_2 H_2 t/2) ... e^(i h_L H_L t/2) e^(i h_L H_L t/2) ... e^(i h_2 H_2 t/2) e^(i h_1 H_1 t/2)
$

QDrift Channel:
$
cal(U)_("QD")(rho; t) := sum_(i = 1)^L (h_i)/(norm(h)) e^(-i H_i tau) rho e^(+i H_i tau)
$