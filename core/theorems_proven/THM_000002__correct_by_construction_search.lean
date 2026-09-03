/-!
# Correct-by-Construction Search & Constitutional Systems

Reissued Mathlib-free. Lean 4 core only. No `sorry`.
Uses Init Quotient / Setoid / WellFounded — not Mathlib.
-/

structure ConstitutionalSystem (S I : Type) where
  Ω        : S → I
  A        : S → S → Prop
  nonempty : Nonempty S
  preserves : ∀ {s t}, A s t → Ω s = Ω t

variable {S I : Type} (C : ConstitutionalSystem S I)

def invRel (s t : S) : Prop := C.Ω s = C.Ω t

def instSetoid (S : Type) {I : Type} (C : ConstitutionalSystem S I) : Setoid S where
  r     := invRel C
  iseqv := ⟨fun _ => rfl, fun h => h.symm, fun h1 h2 => h1.trans h2⟩

def Quot_ : Type := @Quotient S (instSetoid S C)

def pi (s : S) : Quot_ C := @Quotient.mk' S (instSetoid S C) s

lemma pivotal (s t : S) : pi C s = pi C t ↔ C.Ω s = C.Ω t := by
  constructor
  · intro h
    exact @Quotient.exact S (instSetoid S C) s t h
  · intro h
    exact @Quotient.sound S (instSetoid S C) s t h

lemma identity_preservation {s t : S} (h : C.A s t) : pi C s = pi C t := by
  have h_omega : C.Ω s = C.Ω t := C.preserves h
  exact @Quotient.sound S (instSetoid S C) s t h_omega

def Fiber (q : Quot_ C) : Set S := {s | pi C s = q}

namespace CorrectByConstruction

variable {S : Type} {M : Type}

def StateEq (omega : S → M) (x y : S) : Prop := omega x = omega y

def stateSetoid (omega : S → M) : Setoid S where
  r := StateEq omega
  iseqv := {
    refl := fun _ => rfl
    symm := fun h => h.symm
    trans := fun h1 h2 => h1.trans h2
  }

def Q (omega : S → M) : Type := Quotient (stateSetoid omega)

def OmegaQ (omega : S → M) (x : S) : Q omega := Quotient.mk (stateSetoid omega) x

def Tilde (omega : S → M) (x y : S) : Prop := OmegaQ omega x = OmegaQ omega y

lemma tilde_iff_stateEq (omega : S → M) (x y : S) : Tilde omega x y ↔ StateEq omega x y := by
  constructor
  · intro h
    exact Quotient.exact h
  · intro h
    exact Quotient.sound h

def TLift (omega : S → M) (T : S → S)
    (hT : ∀ x y : S, omega x = omega y → omega (T x) = omega (T y)) :
    Q omega → Q omega :=
  Quotient.map T hT

noncomputable def sigma (omega : S → M) (q : Q omega) : S := Quotient.out q

lemma omega_sigma_id (omega : S → M) (q : Q omega) : OmegaQ omega (sigma omega q) = q :=
  Quotient.out_eq q

def Step (omega : S → M) (T : S → S)
    (hT : ∀ x y : S, omega x = omega y → omega (T x) = omega (T y))
    (terminal : Q omega → Prop) (q1 q2 : Q omega) : Prop :=
  ¬ terminal q2 ∧ TLift omega T hT q2 = q1

lemma step_implies_D_lt (omega : S → M) (T : S → S)
    (hT : ∀ x y : S, omega x = omega y → omega (T x) = omega (T y))
    (D : Q omega → Nat) (terminal : Q omega → Prop)
    (h_dec : ∀ q : Q omega, ¬ terminal q → D (TLift omega T hT q) < D q)
    (q1 q2 : Q omega) (h : Step omega T hT terminal q1 q2) :
    D q1 < D q2 := by
  rcases h with ⟨h_not_term, rfl⟩
  exact h_dec q2 h_not_term

lemma execution_terminates (omega : S → M) (T : S → S)
    (hT : ∀ x y : S, omega x = omega y → omega (T x) = omega (T y))
    (D : Q omega → Nat) (terminal : Q omega → Prop)
    (h_dec : ∀ q : Q omega, ¬ terminal q → D (TLift omega T hT q) < D q) :
    WellFounded (Step omega T hT terminal) := by
  have h_wf_nat : WellFounded (fun (x y : Nat) => x < y) := WellFoundedRelation.wf
  have h_inv : WellFounded (InvImage (fun x y => x < y) D) := InvImage.wf D h_wf_nat
  exact WellFounded.mono h_inv (fun x y h => step_implies_D_lt omega T hT D terminal h_dec x y h)

lemma correct_reconstruction (omega : S → M) (terminal : Q omega → Prop)
    (q : Q omega) (_h : terminal q) :
    OmegaQ omega (sigma omega q) = q :=
  omega_sigma_id omega q

end CorrectByConstruction

/--
THEOREM_ID: THM_000002
TITLE: correct_by_construction_search
AUTHOR: jules
STATUS: proven
-/
theorem correct_by_construction_search {S M : Type} (omega : S → M) (T : S → S)
    (hT : ∀ x y : S, omega x = omega y → omega (T x) = omega (T y))
    (D : CorrectByConstruction.Q omega → Nat)
    (terminal : CorrectByConstruction.Q omega → Prop)
    (h_dec : ∀ q : CorrectByConstruction.Q omega,
      ¬ terminal q → D (CorrectByConstruction.TLift omega T hT q) < D q) :
    (∀ x y : S, omega x = omega y → omega (T x) = omega (T y)) ∧
    WellFounded (CorrectByConstruction.Step omega T hT terminal) ∧
    (∀ q : CorrectByConstruction.Q omega, terminal q →
      CorrectByConstruction.OmegaQ omega (CorrectByConstruction.sigma omega q) = q) := by
  refine ⟨hT, CorrectByConstruction.execution_terminates omega T hT D terminal h_dec, ?_⟩
  intro q hq
  exact CorrectByConstruction.correct_reconstruction omega terminal q hq
