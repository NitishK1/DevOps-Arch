"""
Unit tests for Math Helper Library
Test all mathematical functions to ensure correctness.
"""

import unittest
import math
from math_helper import (
    add, multiply, calculate_sin, calculate_cos, calculate_distance
)


class TestMathHelper(unittest.TestCase):
    """Test cases for basic math helper functions"""

    def test_add_positive_numbers(self):
        """Test addition of positive numbers"""
        self.assertEqual(add(5, 3), 8)
        self.assertEqual(add(10, 20), 30)
        self.assertAlmostEqual(add(1.5, 2.5), 4.0)

    def test_add_negative_numbers(self):
        """Test addition with negative numbers"""
        self.assertEqual(add(-5, 3), -2)
        self.assertEqual(add(-10, -20), -30)
        self.assertEqual(add(10, -5), 5)

    def test_multiply_positive_numbers(self):
        """Test multiplication of positive numbers"""
        self.assertEqual(multiply(5, 3), 15)
        self.assertEqual(multiply(10, 2), 20)
        self.assertAlmostEqual(multiply(2.5, 4), 10.0)

    def test_multiply_negative_numbers(self):
        """Test multiplication with negative numbers"""
        self.assertEqual(multiply(-5, 3), -15)
        self.assertEqual(multiply(-10, -2), 20)
        self.assertEqual(multiply(0, 100), 0)

    def test_calculate_sin(self):
        """Test sine calculation"""
        self.assertAlmostEqual(calculate_sin(0), 0.0, places=5)
        self.assertAlmostEqual(calculate_sin(30), 0.5, places=5)
        self.assertAlmostEqual(calculate_sin(90), 1.0, places=5)
        self.assertAlmostEqual(calculate_sin(180), 0.0, places=5)

    def test_calculate_cos(self):
        """Test cosine calculation"""
        self.assertAlmostEqual(calculate_cos(0), 1.0, places=5)
        self.assertAlmostEqual(calculate_cos(60), 0.5, places=5)
        self.assertAlmostEqual(calculate_cos(90), 0.0, places=5)
        self.assertAlmostEqual(calculate_cos(180), -1.0, places=5)

    def test_calculate_distance(self):
        """Test distance calculation between two points"""
        # Test with origin
        self.assertAlmostEqual(calculate_distance(0, 0, 3, 4), 5.0)
        self.assertAlmostEqual(calculate_distance(0, 0, 0, 0), 0.0)

        # Test with non-origin points
        self.assertAlmostEqual(calculate_distance(1, 1, 4, 5), 5.0)
        self.assertAlmostEqual(calculate_distance(-3, -4, 0, 0), 5.0)

        # Test horizontal and vertical distances
        self.assertAlmostEqual(calculate_distance(0, 0, 5, 0), 5.0)
        self.assertAlmostEqual(calculate_distance(0, 0, 0, 5), 5.0)


def run_tests():
    """Run all tests and display results"""
    print("=" * 60)
    print("Running Math Helper Library Tests")
    print("=" * 60)

    # Create test suite
    suite = unittest.TestLoader().loadTestsFromTestCase(TestMathHelper)

    # Run tests with verbose output
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)

    # Display summary
    print("\n" + "=" * 60)
    print("Test Summary")
    print("=" * 60)
    print(f"Tests Run: {result.testsRun}")
    print(f"Successes: {result.testsRun - len(result.failures) - len(result.errors)}")
    print(f"Failures: {len(result.failures)}")
    print(f"Errors: {len(result.errors)}")

    if result.wasSuccessful():
        print("\n✓ All tests passed successfully!")
    else:
        print("\n✗ Some tests failed. Please review the output above.")

    print("=" * 60)

    return result.wasSuccessful()


if __name__ == "__main__":
    success = run_tests()
    exit(0 if success else 1)
