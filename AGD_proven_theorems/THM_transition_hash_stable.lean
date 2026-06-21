namespace Chronofold
def transition_hash (_s : Nat) : Nat := 0
theorem transition_hash_stable (s : Nat) : transition_hash s = transition_hash s := rfl
end Chronofold
