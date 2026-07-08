import Chronofold.BenchmarkCertificate

namespace AGD

-- Re-exposing from Chronofold.BenchmarkCertificate as needed.
def speedup_ratio := @Chronofold.measured_speedup

abbrev speedup_positive := @Chronofold.speedup_positive
abbrev benchmark_claim_valid := @Chronofold.benchmark_claim_valid

end AGD
