import Chronofold.AgdCore
import Chronofold.AgdOperators

namespace Chronofold.AGD

universe u

abbrev WitnessState := State Unit

def Ωw : Omega Unit := fun _ => 0

def Cw : Covariant Unit := fun _ => 0

def w1 : WitnessState := { id := 0, payload := () }

def w2 : WitnessState := { id := 1, payload := () }

theorem w1_ne_w2 : w1 ≠ w2 := by
  intro h
  have hid := congrArg State.id h
  simp [w1, w2] at hid

theorem w1_omega_eq_w2_omega : Ωw w1 = Ωw w2 := by
  rfl

theorem w1_C_eq_w2_C : Cw w1 = Cw w2 := by
  rfl

theorem w1_w2_same_class : pi Unit Ωw Cw w1 = pi Unit Ωw Cw w2 := by
  apply Quotient.sound
  exact ⟨w1_omega_eq_w2_omega, w1_C_eq_w2_C⟩

theorem w1_w2_nontrivial_fibre :
    ∃ s1 s2 : WitnessState,
      s1 ≠ s2 ∧ Ωw s1 = Ωw s2 ∧ Cw s1 = Cw s2 := by
  exact ⟨w1, w2, w1_ne_w2, w1_omega_eq_w2_omega, w1_C_eq_w2_C⟩

theorem pi_witness_not_injective :
    ¬ Function.Injective (pi Unit Ωw Cw) := by
  intro hinj
  exact w1_ne_w2 (hinj w1_w2_same_class)

end Chronofold.AGD
