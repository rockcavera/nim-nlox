{.used.}
import std/private/[ospaths2], std/unittest

import ./tconfig

const folder = "assignment"

suite "Assignment":
  test "Associativity":
    const
      script = folder / "associativity.lox"
      expectedExitCode = 0
      expectedOutput = """c
c
c
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Global":
    const
      script = folder / "global.lox"
      expectedExitCode = 0
      expectedOutput = """before
after
arg
arg
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Grouping":
    const
      script = folder / "grouping.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at '=': Invalid assignment target.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Infix Operator":
    const
      script = folder / "infix_operator.lox"
      expectedExitCode = 65
      expectedOutput = """[line 3] Error at '=': Invalid assignment target.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Local":
    const
      script = folder / "local.lox"
      expectedExitCode = 0
      expectedOutput = """before
after
arg
arg
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Prefix Operator":
    const
      script = folder / "prefix_operator.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at '=': Invalid assignment target.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Syntax":
    const
      script = folder / "syntax.lox"
      expectedExitCode = 0
      expectedOutput = """var
var
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Undefined":
    const
      script = folder / "undefined.lox"
      expectedExitCode = 70
      expectedOutput = """Undefined variable 'unknown'.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)
