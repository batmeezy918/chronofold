import Chronofold.MeasurementCertificate

namespace AGD

-- We use the types and theorems from Chronofold.MeasurementCertificate
-- but expose them via the aliases requested in the task.

def jitter_equivalent := @jitter_close

abbrev jitter_equivalence_is_reflexive := @jitter_close_reflexive
abbrev jitter_equivalence_is_symmetric := @jitter_close_symmetric
abbrev jitter_equivalence_is_transitive := @jitter_close_triangle

end AGD
