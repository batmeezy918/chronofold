import Mathlib.Tactic

namespace AGD

structure BenchmarkSpecification where
  problem_id : ℕ
  algorithm_id : ℕ
  measurement_protocol : ℕ

def same_benchmark (A B : BenchmarkSpecification) : Prop :=
  A = B

def same_result_class (A B : BenchmarkSpecification) : Prop :=
  A.problem_id = B.problem_id ∧ A.algorithm_id = B.algorithm_id

theorem benchmark_reproducible
  (A B : BenchmarkSpecification)
  (h : same_benchmark A B) :
  same_result_class A B := by
  unfold same_benchmark at h
  unfold same_result_class
  rw [h]
  simp

end AGD
