import Mathlib

namespace CFPC

universe u v w

structure State (α : Type u) where
  value : α

def invariant {α : Type u} (x : α) : Prop :=
  x = x

theorem invariant_trivial {α : Type u} (x : α) :
  invariant x := by
  rfl

def Transport (α : Type u) (β : Type v) :=
  α → β

def applyTransport {α β : Type u} (f : Transport α β) (x : α) : β :=
  f x

def compose {α β γ : Type u}
  (f : α → β)
  (g : β → γ) :
  α → γ :=
  fun x => g (f x)

theorem compose_assoc
  {α β γ δ : Type u}
  (f : α → β)
  (g : β → γ)
  (h : γ → δ) :
  h ∘ (g ∘ f) = (h ∘ g) ∘ f := by
  rfl

def SelfAnchor (α : Type u) :=
  α → α

theorem self_anchor_identity {α : Type u} (x : α) :
  x = x := by
  rfl

theorem cfpc_shell {P : Prop} (h : P) : P := by
  exact h

theorem transport_invariant
  {α β : Type u}
  (f : α → β)
  (x : α) :
  f x = f x := by
  rfl

end CFPC
