#!/usr/bin/env python3
"""
COCO/BBO-Bench Smoke Test Script

This script verifies that the COCO benchmark suite and BBO-Bench tooling
are correctly installed and functional.
"""
import sys
import traceback


def test_cocoex():
    """Test COCO Python bindings."""
    print("Testing cocoex...")
    import cocoex
    print(f"  Version: {cocoex.__version__}")
    
    # Instantiate BBOB suite
    suite = cocoex.Suite('bbob', '', 'dimensions: 2')
    problem = suite.get_problem(0)
    
    print(f"  Problem: {problem.name}")
    print(f"  Dimension: {problem.dimension}")
    
    # Evaluate a simple solution
    import numpy as np
    x = np.zeros(2)
    y = problem(x)
    print(f"  f(0,0) = {y:.4f}")
    
    assert problem.evaluations >= 1, "Problem evaluation failed"
    print("  PASSED")
    return True


def test_nevergrad():
    """Test nevergrad optimizer."""
    print("Testing nevergrad...")
    import nevergrad as ng
    print(f"  Version: {ng.__version__}")
    
    import numpy as np
    
    # Simple sphere function
    def sphere(x):
        return np.sum(np.array(x) ** 2)
    
    # Optimize
    optimizer = ng.optimizers.OnePlusOne(parametrization=2, budget=20)
    for _ in range(10):
        x = optimizer.ask()
        y = sphere(x.value)
        optimizer.tell(x, y)
    
    recommendation = optimizer.provide_recommendation()
    print(f"  Best value: {recommendation.loss:.6f}")
    assert recommendation.loss < 1.0, "Optimization failed"
    print("  PASSED")
    return True


def test_cocopp():
    """Test cocopp post-processing."""
    print("Testing cocopp...")
    import cocopp
    print(f"  Version: {cocopp.__version__}")
    print("  PASSED")
    return True


def test_integration():
    """Test nevergrad + COCO integration."""
    print("Testing nevergrad + COCO integration...")
    import cocoex
    import nevergrad as ng
    import numpy as np
    
    suite = cocoex.Suite('bbob', '', 'dimensions: 2')
    problem = suite.get_problem(0)
    
    optimizer = ng.optimizers.OnePlusOne(parametrization=problem.dimension, budget=10)
    for _ in range(5):
        x = optimizer.ask()
        y = problem(np.array(x.value))
        optimizer.tell(x, y)
    
    recommendation = optimizer.provide_recommendation()
    print(f"  Integrated best value: {recommendation.loss:.6f}")
    print("  PASSED")
    return True


def main():
    print("=" * 50)
    print("COCO/BBO-Bench Smoke Tests")
    print("=" * 50)
    
    tests = [
        test_cocoex,
        test_nevergrad,
        test_cocopp,
        test_integration,
    ]
    
    passed = 0
    failed = 0
    
    for test in tests:
        try:
            if test():
                passed += 1
        except Exception as e:
            print(f"  FAILED: {e}")
            traceback.print_exc()
            failed += 1
    
    print("=" * 50)
    print(f"Results: {passed} passed, {failed} failed")
    print("=" * 50)
    
    if failed > 0:
        sys.exit(1)
    print("\nAll smoke tests PASSED!")


if __name__ == '__main__':
    main()
