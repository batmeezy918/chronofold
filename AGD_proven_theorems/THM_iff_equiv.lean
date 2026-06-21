theorem iff_equiv (P Q : Prop) : (P ↔ Q) ↔ ((P → Q) ∧ (Q → P)) := by
  constructor
  · intro h; exact ⟨h.mp, h.mpr⟩
  · intro h; exact ⟨h.1, h.2⟩
