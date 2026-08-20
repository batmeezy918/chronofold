import Chronofold.AgdProductionWitness

namespace Chronofold.AGD

example : witness₁ ≠ witness₂ := witness_ne
example : WitnessOmega witness₁ = WitnessOmega witness₂ := witness_omega
example : WitnessCovariant witness₁ = WitnessCovariant witness₂ := witness_covariant
example : pi Unit WitnessOmega WitnessCovariant witness₁ =
    pi Unit WitnessOmega WitnessCovariant witness₂ := witness_fibre
example : ¬ Function.Injective (pi Unit WitnessOmega WitnessCovariant) :=
  witness_noninjective

end Chronofold.AGD
