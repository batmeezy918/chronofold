import AGD.State
import AGD.Operator
import AGD.Quotient
import AGD.Transport
import AGD.Geometry
import AGD.GEMM

/-- AGDCertificate contains complexity and reconstruction metrics. -/
structure AGDCertificate where
  quotient_size : ℕ
  original_size : ℕ
  compression_ratio : Float
  reconstruction_error : Float

namespace AGD
def main : IO Unit :=
  IO.println "AGD Formalization Build Success"
end AGD
