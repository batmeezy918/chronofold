theorem compose_assoc {α β γ δ : Type u} (f : α → β) (g : β → γ) (h : γ → δ) :
  h ∘ (g ∘ f) = (h ∘ g) ∘ f := rfl
