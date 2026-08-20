import Lake
open Lake DSL

package chronofold

@[default_target]
lean_lib Chronofold where
  srcDir := "src"

@[default_target]
lean_exe Main where
  root := "Main"
