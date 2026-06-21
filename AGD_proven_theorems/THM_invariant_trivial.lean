def invariant {α : Type u} (x : α) : Prop := x = x
theorem invariant_trivial {α : Type u} (x : α) : invariant x := rfl
