{.used.}
import std/private/[ospaths2], std/unittest

import ./tconfig

const folder = "for"

suite "For":
  test "Scope":
    const
      script = folder / "scope.lox"
      expectedExitCode = 0
      expectedOutput = """0
-1
after
0
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Statement condition":
    const
      script = folder / "statement_condition.lox"
      expectedExitCode = 65
      expectedOutput = """[line 3] Error at '{': Expect expression.
[line 3] Error at ')': Expect ';' after expression.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Statement increment":
    const
      script = folder / "statement_increment.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at '{': Expect expression.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Statement initializer":
    const
      script = folder / "statement_initializer.lox"
      expectedExitCode = 65
      expectedOutput = """[line 3] Error at '{': Expect expression.
[line 3] Error at ')': Expect ';' after expression.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Var in body":
    const
      script = folder / "var_in_body.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'var': Expect expression.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)
