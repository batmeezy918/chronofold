import Lake
open Lake DSL

package chronofold

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git"

lean_lib Verify
lean_lib ChronoFold

@[default_target]
lean_exe Main where
  root := `Main
