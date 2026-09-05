namespace AgdDerivedComputationalDomain

universe u v

def Projection (H : Type u) (Q : Type v) := H -> Q
def Operator (H : Type u) := H -> H
def QuotientOperator (Q : Type v) := Q -> Q

def Descends {H : Type u} {Q : Type v}
    (pi : Projection H Q) (T : Operator H)
    (Tbar : QuotientOperator Q) : Prop :=
  forall x, pi (T x) = Tbar (pi x)

def WellDefined {H : Type u} {Q : Type v}
    (pi : Projection H Q) (T : Operator H) : Prop :=
  forall x y, pi x = pi y -> pi (T x) = pi (T y)

def iterate {alpha : Type u} (T : alpha -> alpha) : Nat -> alpha -> alpha
  | 0, x => x
  | n + 1, x => T (iterate T n x)

structure DerivedDomain {H : Type u} {Q : Type v}
    (pi : Projection H Q) (T : Operator H) where
  Tbar : QuotientOperator Q
  descend : Descends pi T Tbar
  coarsest : Prop

theorem descends_implies_wellDefined
    {H : Type u} {Q : Type v}
    (pi : Projection H Q) {T : Operator H} {Tbar : QuotientOperator Q}
    (h : Descends pi T Tbar) :
    WellDefined pi T := by
  intro x y hxy
  calc
    pi (T x) = Tbar (pi x) := h x
    _ = Tbar (pi y) := by rw [hxy]
    _ = pi (T y) := (h y).symm

theorem quotient_operator_unique
    {H : Type u} {Q : Type v}
    (pi : Projection H Q) (T : Operator H)
    {B1 B2 : QuotientOperator Q}
    (h1 : Descends pi T B1)
    (h2 : Descends pi T B2)
    (surj : forall q, exists x, pi x = q) :
    B1 = B2 := by
  funext q
  rcases surj q with ⟨x, hx⟩
  calc
    B1 q = B1 (pi x) := by rw [hx]
    _ = pi (T x) := (h1 x).symm
    _ = B2 (pi x) := h2 x
    _ = B2 q := by rw [hx]

theorem derived_recursive_closure
    {H : Type u} {Q : Type v}
    (pi : Projection H Q) (T : Operator H)
    (D : DerivedDomain pi T) :
    forall n x, pi (iterate T n x) = iterate D.Tbar n (pi x) := by
  intro n
  induction n with
  | zero => intro x; rfl
  | succ n ih =>
      intro x
      calc
        pi (iterate T (n + 1) x) = pi (T (iterate T n x)) := rfl
        _ = D.Tbar (pi (iterate T n x)) := D.descend (iterate T n x)
        _ = D.Tbar (iterate D.Tbar n (pi x)) := by rw [ih x]
        _ = iterate D.Tbar (n + 1) (pi x) := rfl

theorem recursive_closure_implies_descent
    {H : Type u} {Q : Type v}
    (pi : Projection H Q) (T : Operator H) (Tbar : QuotientOperator Q)
    (h : forall n x, pi (iterate T n x) = iterate Tbar n (pi x)) :
    Descends pi T Tbar := by
  intro x
  simpa [iterate] using h 1 x

theorem descent_iff_recursive_closure
    {H : Type u} {Q : Type v}
    (pi : Projection H Q) (T : Operator H) (Tbar : QuotientOperator Q) :
    Descends pi T Tbar <->
      forall n x, pi (iterate T n x) = iterate Tbar n (pi x) := by
  constructor
  · intro h
    let D : DerivedDomain pi T := { Tbar := Tbar, descend := h, coarsest := True }
    exact derived_recursive_closure pi T D
  · exact recursive_closure_implies_descent pi T Tbar

theorem derived_domain_is_executable
    {H : Type u} {Q : Type v}
    (pi : Projection H Q) (T : Operator H)
    (D : DerivedDomain pi T) :
    WellDefined pi T /\
      (forall n x, pi (iterate T n x) = iterate D.Tbar n (pi x)) := by
  constructor
  · exact descends_implies_wellDefined pi D.descend
  · exact derived_recursive_closure pi T D

end AgdDerivedComputationalDomain
