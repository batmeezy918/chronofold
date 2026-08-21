import Lake
open Lake DSL

package chronofold

lean_lib Verify
lean_lib Chronofold

@[default_target]
lean_exe Main where
  root := `Main
