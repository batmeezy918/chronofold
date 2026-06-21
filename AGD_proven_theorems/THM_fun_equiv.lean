theorem fun_equiv {α β : Type u} (f g : α → β) (h : ∀ x, f x = g x) : f = g := by
  funext x
  exact h x
