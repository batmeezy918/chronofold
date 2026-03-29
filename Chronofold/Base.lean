namespace Chronofold

structure State where
  vec : List Float

def Operator := State → State

def id_op : Operator := fun s => s

end Chronofold
