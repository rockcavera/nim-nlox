{.used.}
import std/private/[ospaths2], std/unittest

import ./tconfig

const folder = "while"

suite "While":
  test "Syntax":
    const
      script = folder / "syntax.lox"
      expectedExitCode = 0
      expectedOutput = """1
2
3
0
1
2
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Var in body":
    const
      script = folder / "var_in_body.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'var': Expect expression.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Closure in body":
    const
      script = folder / "closure_in_body.lox"
      expectedExitCode = 0
      expectedOutput = """1
2
3
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Fun in body":
    const
      script = folder / "fun_in_body.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'fun': Expect expression.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Return closure":
    const
      script = folder / "return_closure.lox"
      expectedExitCode = 0
      expectedOutput = """i
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Return inside":
    const
      script = folder / "return_inside.lox"
      expectedExitCode = 0
      expectedOutput = """i
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)
