{.used.}
import std/private/[ospaths2], std/unittest

import ./tconfig

const folder = "constructor"

suite "Constructor":
  test "Arguments":
    const
      script = folder / "arguments.lox"
      expectedExitCode = 0
      expectedOutput = """init
1
2
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Call init early return":
    const
      script = folder / "call_init_early_return.lox"
      expectedExitCode = 0
      expectedOutput = """init
init
Foo instance
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Call init explicitly":
    const
      script = folder / "call_init_explicitly.lox"
      expectedExitCode = 0
      expectedOutput = """Foo.init(one)
Foo.init(two)
Foo instance
init
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Default arguments":
    const
      script = folder / "default_arguments.lox"
      expectedExitCode = 70
      expectedOutput = """Expected 0 arguments but got 3.
[line 3]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Default":
    const
      script = folder / "default.lox"
      expectedExitCode = 0
      expectedOutput = """Foo instance
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Early return":
    const
      script = folder / "early_return.lox"
      expectedExitCode = 0
      expectedOutput = """init
Foo instance
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

  test "Init not method":
    const
      script = folder / "init_not_method.lox"
      expectedExitCode = 0
      expectedOutput = """not initializer
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

  test "Return in nested function":
    const
      script = folder / "return_in_nested_function.lox"
      expectedExitCode = 0
      expectedOutput = """bar
Foo instance
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Return value":
    const
      script = folder / "return_value.lox"
      expectedExitCode = 65
      expectedOutput = """[line 3] Error at 'return': Can't return a value from an initializer.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)
