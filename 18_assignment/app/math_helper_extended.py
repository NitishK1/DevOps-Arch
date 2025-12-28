"""
Extended Math Helper Library
Additional mathematical functions to demonstrate Git branching and updates.

New Functions:
- Power calculation
- Square root
- Factorial
- Modulo operation
"""

import math


def power(base, exponent):
    """
    Calculate base raised to exponent.

    Args:
        base (float): Base number
        exponent (float): Exponent

    Returns:
        float: base^exponent

    Example:
        >>> power(2, 3)
        8
        >>> power(5, 2)
        25
    """
    return base ** exponent


def square_root(number):
    """
    Calculate square root of a number.

    Args:
        number (float): Number to find square root of (must be non-negative)

    Returns:
        float: Square root of the number

    Raises:
        ValueError: If number is negative

    Example:
        >>> square_root(16)
        4.0
        >>> square_root(25)
        5.0
    """
    if number < 0:
        raise ValueError("Cannot calculate square root of negative number")
    return math.sqrt(number)


def factorial(n):
    """
    Calculate factorial of a number.

    Args:
        n (int): Non-negative integer

    Returns:
        int: Factorial of n

    Raises:
        ValueError: If n is negative

    Example:
        >>> factorial(5)
        120
        >>> factorial(0)
        1
    """
    if n < 0:
        raise ValueError("Factorial is not defined for negative numbers")
    return math.factorial(n)


def modulo(a, b):
    """
    Calculate remainder of a divided by b.

    Args:
        a (int): Dividend
        b (int): Divisor (must be non-zero)

    Returns:
        int: Remainder of a/b

    Raises:
        ValueError: If b is zero

    Example:
        >>> modulo(10, 3)
        1
        >>> modulo(15, 4)
        3
    """
    if b == 0:
        raise ValueError("Division by zero")
    return a % b


# Main execution for demonstration
if __name__ == "__main__":
    print("=" * 60)
    print("Extended Math Helper Library - Function Demonstrations")
    print("=" * 60)

    # Power
    print("\n1. Power:")
    result = power(2, 8)
    print(f"   power(2, 8) = {result}")

    # Square root
    print("\n2. Square Root:")
    result = square_root(144)
    print(f"   square_root(144) = {result}")

    # Factorial
    print("\n3. Factorial:")
    result = factorial(6)
    print(f"   factorial(6) = {result}")

    # Modulo
    print("\n4. Modulo:")
    result = modulo(17, 5)
    print(f"   modulo(17, 5) = {result}")

    print("\n" + "=" * 60)
    print("All extended functions executed successfully!")
    print("=" * 60)
