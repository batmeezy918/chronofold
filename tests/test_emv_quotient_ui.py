import pathlib
import sys
import unittest

ROOT = pathlib.Path(__file__).parents[1]
sys.path.insert(0, str(ROOT))
sys.path.insert(0, str(ROOT / "ui"))

from ui.emv_quotient_engine import (
    BASE_SCENARIO,
    analyze,
    falsification_matrix,
    project,
    perturbation_matrix,
)


class EMVQuotientTests(unittest.TestCase):
    def test_projection_idempotence(self):
        first = project(BASE_SCENARIO)
        second = project(first.canonical())
        self.assertEqual(first, second)

    def test_timing_is_residual(self):
        a = dict(BASE_SCENARIO)
        b = dict(BASE_SCENARIO)
        b["timing"] = "100000"
        self.assertEqual(project(a), project(b))

    def test_apdu_mutation_changes_quotient(self):
        a = dict(BASE_SCENARIO)
        b = dict(BASE_SCENARIO)
        b["ins"] = "B0"
        self.assertNotEqual(project(a), project(b))

    def test_falsification_is_deterministic(self):
        first = analyze(falsification_matrix(BASE_SCENARIO))
        second = analyze(falsification_matrix(BASE_SCENARIO))
        self.assertEqual(first, second)

    def test_perturbation_matrix_size(self):
        self.assertEqual(len(perturbation_matrix(BASE_SCENARIO)), 9)


if __name__ == "__main__":
    unittest.main()
