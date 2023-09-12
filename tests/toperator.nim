{.used.}
import std/private/[ospaths2], std/unittest

import ./tconfig

const folder = "operator"

suite "Operator":
  test "Add bool nil":
    const
      script = folder / "add_bool_nil.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be two numbers or two strings.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Add bool num":
    const
      script = folder / "add_bool_num.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be two numbers or two strings.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Add bool string":
    const
      script = folder / "add_bool_string.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be two numbers or two strings.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Add nil nil":
    const
      script = folder / "add_nil_nil.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be two numbers or two strings.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Add num nil":
    const
      script = folder / "add_num_nil.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be two numbers or two strings.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Add string nil":
    const
      script = folder / "add_string_nil.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be two numbers or two strings.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Add":
    const
      script = folder / "add.lox"
      expectedExitCode = 0
      expectedOutput = """579
string
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Comparison":
    const
      script = folder / "comparison.lox"
      expectedExitCode = 0
      expectedOutput = """true
false
false
true
true
false
false
false
true
false
true
true
false
false
false
false
true
true
true
true
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Divide nonnum num":
    const
      script = folder / "divide_nonnum_num.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Divide num nonnum":
    const
      script = folder / "divide_num_nonnum.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Divide":
    const
      script = folder / "divide.lox"
      expectedExitCode = 0
      expectedOutput = """4
1
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Equals":
    const
      script = folder / "equals.lox"
      expectedExitCode = 0
      expectedOutput = """true
true
false
true
false
true
false
false
false
false
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Greater nonnum num":
    const
      script = folder / "greater_nonnum_num.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Greater num nonnum":
    const
      script = folder / "greater_num_nonnum.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Greater or equal nonnum num":
    const
      script = folder / "greater_or_equal_nonnum_num.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Greater or equal num nonnum":
    const
      script = folder / "greater_or_equal_num_nonnum.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Less nonnum num":
    const
      script = folder / "less_nonnum_num.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Less num nonnum":
    const
      script = folder / "less_num_nonnum.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Less or equal nonnum num":
    const
      script = folder / "less_or_equal_nonnum_num.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Less or equal num nonnum":
    const
      script = folder / "less_or_equal_num_nonnum.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Multiply nonnum num":
    const
      script = folder / "multiply_nonnum_num.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Multiply num nonnum":
    const
      script = folder / "multiply_num_nonnum.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Multiply":
    const
      script = folder / "multiply.lox"
      expectedExitCode = 0
      expectedOutput = """15
3.702
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Negate nonnum":
    const
      script = folder / "negate_nonnum.lox"
      expectedExitCode = 70
      expectedOutput = """Operand must be a number.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Negate":
    const
      script = folder / "negate.lox"
      expectedExitCode = 0
      expectedOutput = """-3
3
-3
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Not equals":
    const
      script = folder / "not_equals.lox"
      expectedExitCode = 0
      expectedOutput = """false
false
true
false
true
false
true
true
true
true
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Subtract nonnum num":
    const
      script = folder / "subtract_nonnum_num.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Subtract num nonnum":
    const
      script = folder / "subtract_num_nonnum.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Subtract":
    const
      script = folder / "subtract.lox"
      expectedExitCode = 0
      expectedOutput = """1
0
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Not":
    const
      script = folder / "not.lox"
      expectedExitCode = 0
      expectedOutput = """false
true
true
false
false
true
false
false
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Equals class":
    const
      script = folder / "equals_class.lox"
      expectedExitCode = 0
      expectedOutput = """true
false
false
true
false
false
false
false
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Equals method":
    const
      script = folder / "equals_method.lox"
      expectedExitCode = 0
      expectedOutput = """true
false
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Not class":
    const
      script = folder / "not_class.lox"
      expectedExitCode = 0
      expectedOutput = """false
false
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)
