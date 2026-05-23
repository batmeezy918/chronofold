namespace Chronofold

def H := Nat → Int

def Ω (x : H) : Int := x 0
def Ξ (x : H) : Int := x 2 - 2 * x 1 + x 0
def Δ (x : H) : Int := 1

def SNAP (x : H) : H :=
  fun i =>
    match i with
    | 0 => x 0
    | 1 => x 1 + Δ x
    | 2 => 2 * (x 1 + Δ x) - x 0 + Ξ x
    | _ => x i

end Chronofold
