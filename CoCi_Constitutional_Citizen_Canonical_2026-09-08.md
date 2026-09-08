# CoCi Constitutional Citizen — Canonical Formal Definition

**Status:** Canonical formal specification draft, frozen 2026-09-08. External novelty is not asserted by this document; novelty remains subject to adversarial prior-art and formal reduction analysis.

## Definitive formal definition

Let the closed Constitutional Calculus be

\[
\mathcal C=(X,U,T,\Omega,C,\pi,Q,\bar T,\rho,\mathcal W).
\]

A **Constitutional Citizen (CoCi)** is a constructively generated quotient-level inhabitant \(c\in Q\) for which a constitutional witness \(w_c\) establishes the minimum constitutional obligations:

\[
\operatorname{CoCi}_{\mathcal C}(c,w_c)
\iff
\begin{cases}
c\in Q,\\
\exists x\in X:\pi(x)=c,\\
\operatorname{Adm}_{\mathcal C}(c,u)\Rightarrow \bar T(c,u)\in Q,\\
\pi(T(x,u))=\bar T(\pi(x),u),\\
\pi(\rho(c))=c,\\
\operatorname{Invariant}_{\mathcal C}(c),\\
\operatorname{Witness}_{\mathcal C}(w_c,c),\\
\operatorname{Constitutional}(w_c).
\end{cases}
\]

In words: a CoCi is a constructively generated quotient inhabitant whose identity, lawful transformations, invariants, reconstruction, and witness are constitutionally closed and bidirectionally related to the underlying system.

## Constitutional quotient and Convex

\[
x\sim_C y \iff \Omega(x)=\Omega(y)\land C(x)=C(y),
\qquad Q=X/{\sim_C}.
\]

Define the constitutional admissible region

\[
\mathfrak K_{\mathcal C}=\{c\in Q:\operatorname{CoCi}_{\mathcal C}(c)\}.
\]

At this stage, “Constitutional Convex” denotes the closed admissible constitutional region. Strict geometric convexity is a separate theorem obligation and is not assumed.

## Minimum requirement basis

The candidate minimum constitutional dimensions are

\[
\mathcal D_C=(I,D,T,A,\Omega,W,\rho),
\]

where \(I\) is identity, \(D\) domain membership, \(T\) lawful transformation, \(A\) admissibility, \(\Omega\) invariant/observable structure, \(W\) constructive witness, and \(\rho\) reverse reconstruction.

Minimality is a theorem obligation. For each component \(f\), define \(\operatorname{CoCi}^{-f}\) by deletion and seek a counterexample showing that the declared CoCi properties can no longer be established. No component is mathematically indispensable until that deletion-counterexample program succeeds.

## Construction

\[
\operatorname{Construct}_{\mathcal C}:D_C\subseteq X\to Q,
\qquad
\operatorname{Construct}_{\mathcal C}(x)=\pi(x).
\]

Construction is admissible only when the minimum constitutional obligations are satisfied.

## Transformation and rights

\[
\bar T:Q\times U\to Q.
\]

A transformation \(c\xrightarrow{u}\bar T(c,u)\) is permitted only when

\[
\operatorname{Adm}_{\mathcal C}(c,u)=1.
\]

The fundamental descent law is

\[
\boxed{\pi\circ T_u=\bar T_u\circ\pi}.
\]

The constitutionally derived transformation-right set is

\[
A_C(c)=\{u\in U:\operatorname{Adm}_{\mathcal C}(c,u)\}.
\]

No capability is granted merely by declaration.

## Responsibilities

For every admitted transformation \(c\xrightarrow{u}c'\), the Citizen must preserve:

\[
c'\in Q,
\quad \pi(T(x,u))=c',
\quad \Omega_Q(c')=\Omega_Q^{*}(c,u),
\quad W(c,u,c'),
\quad \pi(\rho(c'))=c'.
\]

Thus:

\[
\boxed{\text{right to transform}\Longleftrightarrow\text{responsibility to remain constitutional}.}
\]

## Micro-bidirectional closure

Every primitive CoCi function \(f\) has four proof obligations:

\[
\boxed{\mathsf{MB}(f)=(F_f,R_f,I_f,W_f)}
\]

with forward execution \(F_f(c)=c'\), reverse correspondence \(R_f(c')\sim_C c\), invariant preservation \(I_f(c,c')=\mathrm{true}\), and an independent witness \(W_f(c,c')\).

A function is not closed CoCi mathematics until all four obligations are satisfied.

## Bidirectional construction and recursive closure

\[
x\overset{\pi}{\longrightarrow}c\overset{\rho}{\longrightarrow}[x]_{\sim_C},
\qquad \pi(\rho(c))=c.
\]

This is constitutional reversibility, not microscopic invertibility.

For an input sequence \(\mathbf u=(u_0,\ldots,u_{n-1})\), with \(c_{i+1}=\bar T(c_i,u_i)\), recursive closure requires

\[
\boxed{\forall n\ge0:\pi\circ T_{\mathbf u}^{\,n}=\bar T_{\mathbf u}^{\,n}\circ\pi.}
\]

## Witness

The witness is constructive:

\[
w_c=\operatorname{Witness}_{\mathcal C}(c),
\qquad
w_c\vdash_{\mathcal C}\operatorname{CoCi}(c),
\qquad
\operatorname{Constitutional}(w_c).
\]

The Citizen therefore cannot certify itself by proclamation.

## Constitutional Convict

A Constitutional Convict is a constructive constitutional-failure object

\[
\operatorname{CoConvict}_{\mathcal C}(x,d,w_d)
\]

where \(d\) is an explicitly demonstrated constitutional defect and \(w_d\) witnesses that defect. For example,

\[
d_{\mathrm{descent}}:\quad \pi(T(x,u))\ne\bar T(\pi(x),u).
\]

Failure of proof alone is not sufficient to classify an object as a Convict.

## Person / CoCi / state separation

\[
\boxed{\text{Physical Person}\ne\text{CoCi}\ne\text{Quotient State}.}
\]

A physical person may be represented by a CoCi only through an explicit realization relation. Formal constitutional proofs apply to the mathematical representation unless an additional realization theorem establishes physical correspondence.

## Physical realization

A physical realization may be represented by

\[
\mathcal R_{\mathrm{phys}}:\mathsf{CoCi}\rightharpoonup\mathcal P
\]

with declared observable correspondence such as

\[
\Omega_{\mathrm{phys}}(\mathcal R_{\mathrm{phys}}(c))=\Omega_C(c).
\]

Physical realization is not itself mathematical proof; realization fidelity is a separate proof/test layer.

## Minimality theorem program

For each \(f\in\mathcal D_C\), construct \(\operatorname{CoCi}^{-f}\) and seek

\[
\exists x_f:\operatorname{CoCi}^{-f}(x_f)\not\Rightarrow\operatorname{CoCi}(x_f).
\]

The target theorem is

\[
\boxed{\operatorname{MinimalCoCi}}.
\]

Until these obligations are machine-checked, minimality remains a theorem target rather than a completed theorem.

## Canonical core

\[
\boxed{\text{Identity}+\text{Domain}+\text{Admissibility}+\text{Transformation}+\text{Invariant}+\text{Witness}+\text{Reconstruction}}
\]

under the universal micro-obligation

\[
\boxed{\text{Forward}\;|\;\text{Reverse}\;|\;\text{Invariant}\;|\;\text{Witness}.}
\]

## Governing principles

\[
\boxed{\textbf{Nothing is a Citizen because we call it one.}}
\]

\[
\boxed{\textbf{A thing becomes a Citizen by satisfying the minimum Constitution, and remains a Citizen only through constitutionally closed transformation.}}
\]

\[
\boxed{\textbf{A Convict is not something merely lacking approval; it carries a demonstrated constitutional defect.}}
\]

\[
\boxed{\textbf{The quotient is the constitutional semantic identity space; the CoCi is its witnessed inhabitant.}}
\]
