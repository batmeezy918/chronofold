import Chronofold.AgdCore
import Chronofold.AgdOperators
import Chronofold.AgdUniversal
import Chronofold.AgdFibreClosure

namespace Chronofold.AGD

universe u

abbrev WitnessState := State Unit

def WitnessOmega : Omega Unit :=
  fun _ => 0

def WitnessCovariant : Covariant Unit :=
  fun _ => 0

def witness₁ : WitnessState :=
  { id := 0, payload := () }

def witness₂ : WitnessState :=
  { id := 1, payload := () }

theorem witness_ne : witness₁ ≠ witness₂ := by
  intro h
  have hid : witness₁.id = witness₂.id := congrArg State.id h
  simp [witness₁, witness₂] at hid

theorem witness_omega :
    WitnessOmega witness₁ = WitnessOmega witness₂ := by
  rfl

theorem witness_covariant :
    WitnessCovariant witness₁ = WitnessCovariant witness₂ := by
  rfl

theorem witness_agd_equiv :
    AGDEquiv Unit WitnessOmega WitnessCovariant witness₁ witness₂ := by
  exact ⟨witness_omega, witness_covariant⟩

theorem witness_fibre :
    pi Unit WitnessOmega WitnessCovariant witness₁ =
      pi Unit WitnessOmega WitnessCovariant witness₂ := by
  exact Quotient.sound witness_agd_equiv

theorem witness_noninjective :
    ¬ Function.Injective (pi Unit WitnessOmega WitnessCovariant) := by
  intro hinj
  exact witness_ne (hinj witness_fibre)

theorem witness_is_nontrivial_fibre :
    NontrivialAGDFibre Unit WitnessOmega WitnessCovariant := by
  exact ⟨witness₁, witness₂, witness_ne, witness_omega, witness_covariant⟩

end Chronofold.AGD
