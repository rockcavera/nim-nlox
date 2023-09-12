{.used.}
import std/private/[ospaths2], std/unittest

import ./tconfig

const folder = "method"

suite "Method":
  test "Arity":
    const
      script = folder / "arity.lox"
      expectedExitCode = 0
      expectedOutput = """no args
1
3
6
10
15
21
28
36
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Arity":
    const
      script = folder / "empty_block.lox"
      expectedExitCode = 0
      expectedOutput = """nil
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Extra arguments":
    const
      script = folder / "extra_arguments.lox"
      expectedExitCode = 70
      expectedOutput = """Expected 2 arguments but got 4.
[line 8]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Missing arguments":
    const
      script = folder / "missing_arguments.lox"
      expectedExitCode = 70
      expectedOutput = """Expected 2 arguments but got 1.
[line 5]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Not found":
    const
      script = folder / "not_found.lox"
      expectedExitCode = 70
      expectedOutput = """Undefined property 'unknown'.
[line 3]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Print bound method":
    const
      script = folder / "print_bound_method.lox"
      expectedExitCode = 0
      expectedOutput = """<fn method>
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Refer to name":
    const
      script = folder / "refer_to_name.lox"
      expectedExitCode = 70
      expectedOutput = """Undefined variable 'method'.
[line 3]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Too many arguments":
    const
      script = folder / "too_many_arguments.lox"
      expectedExitCode = 65
      expectedOutput = """[line 259] Error at 'a': Can't have more than 255 arguments.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Too many parameters":
    const
      script = folder / "too_many_parameters.lox"
      expectedExitCode = 65
      expectedOutput = """[line 258] Error at 'a': Can't have more than 255 parameters.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)
