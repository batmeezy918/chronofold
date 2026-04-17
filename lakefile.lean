import Lake
open Lake DSL

package chronofold

lean_lib Verify

@[default_target]
lean_exe Main where
  root := `Main
