{.used.}
import std/private/[ospaths2], std/unittest

import ./tconfig

const folder = "this"

suite "This":
  test "Closure":
    const
      script = folder / "closure.lox"
      expectedExitCode = 0
      expectedOutput = """Foo
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Nested class":
    const
      script = folder / "nested_class.lox"
      expectedExitCode = 0
      expectedOutput = """Outer instance
Outer instance
Inner instance
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Nested closure":
    const
      script = folder / "nested_closure.lox"
      expectedExitCode = 0
      expectedOutput = """Foo
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "This at top level":
    const
      script = folder / "this_at_top_level.lox"
      expectedExitCode = 65
      expectedOutput = """[line 1] Error at 'this': Can't use 'this' outside of a class.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "This in method":
    const
      script = folder / "this_in_method.lox"
      expectedExitCode = 0
      expectedOutput = """baz
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "This in top level function":
    const
      script = folder / "this_in_top_level_function.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'this': Can't use 'this' outside of a class.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)
