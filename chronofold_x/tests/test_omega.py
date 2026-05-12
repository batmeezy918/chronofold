import unittest
import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from core.omega import Omega

class TestOmega(unittest.TestCase):
    def test_determinism(self):
        graph = {
            "nodes": [{"id": "B"}, {"id": "A"}],
            "edges": []
        }
        omega = Omega()
        res1 = omega.normalize(graph)
        res2 = omega.normalize(graph)
        self.assertEqual(res1, res2)
        self.assertEqual(res1["nodes"][0]["id"], "A")

if __name__ == "__main__":
    unittest.main()
