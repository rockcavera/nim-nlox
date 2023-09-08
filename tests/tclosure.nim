{.used.}
import std/private/[ospaths2], std/unittest

import ./tconfig

const folder = "closure"

suite "Closure":
  test "Assign to closure":
    const
      script = folder / "assign_to_closure.lox"
      expectedExitCode = 0
      expectedOutput = """local
after f
after f
after g
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Close over function parameter":
    const
      script = folder / "close_over_function_parameter.lox"
      expectedExitCode = 0
      expectedOutput = """param
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Close over later variable":
    const
      script = folder / "close_over_later_variable.lox"
      expectedExitCode = 0
      expectedOutput = """b
a
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Closed closure in function":
    const
      script = folder / "closed_closure_in_function.lox"
      expectedExitCode = 0
      expectedOutput = """local
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Nested closure":
    const
      script = folder / "nested_closure.lox"
      expectedExitCode = 0
      expectedOutput = """a
b
c
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Open closure in function":
    const
      script = folder / "open_closure_in_function.lox"
      expectedExitCode = 0
      expectedOutput = """local
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Reference closure multiple times":
    const
      script = folder / "reference_closure_multiple_times.lox"
      expectedExitCode = 0
      expectedOutput = """a
a
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Reuse closure slot":
    const
      script = folder / "reuse_closure_slot.lox"
      expectedExitCode = 0
      expectedOutput = """a
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Shadow closure with local":
    const
      script = folder / "shadow_closure_with_local.lox"
      expectedExitCode = 0
      expectedOutput = """closure
shadow
closure
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Unused closure":
    const
      script = folder / "unused_closure.lox"
      expectedExitCode = 0
      expectedOutput = """ok
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Unused later closure":
    const
      script = folder / "unused_later_closure.lox"
      expectedExitCode = 0
      expectedOutput = """a
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Assign to shadowed later":
    const
      script = folder / "assign_to_shadowed_later.lox"
      expectedExitCode = 0
      expectedOutput = """inner
assigned
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)
