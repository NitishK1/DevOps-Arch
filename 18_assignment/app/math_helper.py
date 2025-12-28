"""
Math Helper Library
A collection of mathematical utility functions for Hooli Inc.

Functions:
- Addition
- Multiplication
- Trigonometric calculations (sin/cos)
- Distance calculation between two points
"""

import math


def add(a, b):
    """
    Add two numbers.

    Args:
        a (float): First number
        b (float): Second number

    Returns:
        float: Sum of a and b

    Example:
        >>> add(5, 3)
        8
        >>> add(10.5, 2.5)
        13.0
    """
    return a + b


def multiply(a, b):
    """
    Multiply two numbers.

    Args:
        a (float): First number
        b (float): Second number

    Returns:
        float: Product of a and b

    Example:
        >>> multiply(5, 3)
        15
        >>> multiply(2.5, 4)
        10.0
    """
    return a * b


def calculate_sin(angle_degrees):
    """
    Calculate sine of an angle.

    Args:
        angle_degrees (float): Angle in degrees

    Returns:
        float: Sine of the angle

    Example:
        >>> calculate_sin(30)
        0.5
        >>> calculate_sin(90)
        1.0
    """
    angle_radians = math.radians(angle_degrees)
    return math.sin(angle_radians)


def calculate_cos(angle_degrees):
    """
    Calculate cosine of an angle.

    Args:
        angle_degrees (float): Angle in degrees

    Returns:
        float: Cosine of the angle

    Example:
        >>> calculate_cos(0)
        1.0
        >>> calculate_cos(60)
        0.5
    """
    angle_radians = math.radians(angle_degrees)
    return math.cos(angle_radians)


def calculate_distance(x1, y1, x2, y2):
    """
    Calculate Euclidean distance between two points.

    Args:
        x1 (float): X-coordinate of first point
        y1 (float): Y-coordinate of first point
        x2 (float): X-coordinate of second point
        y2 (float): Y-coordinate of second point

    Returns:
        float: Distance between the two points

    Example:
        >>> calculate_distance(0, 0, 3, 4)
        5.0
        >>> calculate_distance(1, 1, 4, 5)
        5.0
    """
    return math.sqrt((x2 - x1)**2 + (y2 - y1)**2)


# Main execution for demonstration
if __name__ == "__main__":
    print("=" * 60)
    print("Math Helper Library - Function Demonstrations")
    print("=" * 60)

    # Addition
    print("\n1. Addition:")
    result = add(15, 25)
    print(f"   add(15, 25) = {result}")

    # Multiplication
    print("\n2. Multiplication:")
    result = multiply(7, 8)
    print(f"   multiply(7, 8) = {result}")

    # Sine calculation
    print("\n3. Sine Calculation:")
    result = calculate_sin(30)
    print(f"   sin(30°) = {result:.4f}")
    result = calculate_sin(90)
    print(f"   sin(90°) = {result:.4f}")

    # Cosine calculation
    print("\n4. Cosine Calculation:")
    result = calculate_cos(0)
    print(f"   cos(0°) = {result:.4f}")
    result = calculate_cos(60)
    print(f"   cos(60°) = {result:.4f}")

    # Distance calculation
    print("\n5. Distance Calculation:")
    result = calculate_distance(0, 0, 3, 4)
    print(f"   distance((0,0), (3,4)) = {result:.2f}")
    result = calculate_distance(1, 1, 4, 5)
    print(f"   distance((1,1), (4,5)) = {result:.2f}")

    print("\n" + "=" * 60)
    print("All functions executed successfully!")
    print("=" * 60)
