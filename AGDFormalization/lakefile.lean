import Lake
open Lake DSL

package agd where

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git"

@[default_target]
lean_lib AGD where
  srcDir := "."

lean_exe agd_exe where
  root := `Main
