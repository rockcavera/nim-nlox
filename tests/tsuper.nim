{.used.}
import std/private/[ospaths2], std/unittest

import ./tconfig

const folder = "super"

suite "Super":
  test "Bound method":
    const
      script = folder / "bound_method.lox"
      expectedExitCode = 0
      expectedOutput = """A.method(arg)
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Call other method":
    const
      script = folder / "call_other_method.lox"
      expectedExitCode = 0
      expectedOutput = """Derived.bar()
Base.foo()
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Call same method":
    const
      script = folder / "call_same_method.lox"
      expectedExitCode = 0
      expectedOutput = """Derived.foo()
Base.foo()
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Closure":
    const
      script = folder / "closure.lox"
      expectedExitCode = 0
      expectedOutput = """Base
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Constructor":
    const
      script = folder / "constructor.lox"
      expectedExitCode = 0
      expectedOutput = """Derived.init()
Base.init(a, b)
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Extra arguments":
    const
      script = folder / "extra_arguments.lox"
      expectedExitCode = 70
      expectedOutput = """Derived.foo()
Expected 2 arguments but got 4.
[line 10]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Indirectly inherited":
    const
      script = folder / "indirectly_inherited.lox"
      expectedExitCode = 0
      expectedOutput = """C.foo()
A.foo()
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Missing arguments":
    const
      script = folder / "missing_arguments.lox"
      expectedExitCode = 70
      expectedOutput = """Expected 2 arguments but got 1.
[line 9]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "No superclass bind":
    const
      script = folder / "no_superclass_bind.lox"
      expectedExitCode = 65
      expectedOutput = """[line 3] Error at 'super': Can't use 'super' in a class with no superclass.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "No superclass call":
    const
      script = folder / "no_superclass_call.lox"
      expectedExitCode = 65
      expectedOutput = """[line 3] Error at 'super': Can't use 'super' in a class with no superclass.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "No superclass method":
    const
      script = folder / "no_superclass_method.lox"
      expectedExitCode = 70
      expectedOutput = """Undefined property 'doesNotExist'.
[line 5]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Parenthesized":
    const
      script = folder / "parenthesized.lox"
      expectedExitCode = 65
      expectedOutput = """[line 8] Error at ')': Expect '.' after 'super'.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Reassign superclass":
    const
      script = folder / "reassign_superclass.lox"
      expectedExitCode = 0
      expectedOutput = """Base.method()
Base.method()
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Super at top level":
    const
      script = folder / "super_at_top_level.lox"
      expectedExitCode = 65
      expectedOutput = """[line 1] Error at 'super': Can't use 'super' outside of a class.
[line 2] Error at 'super': Can't use 'super' outside of a class.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Super in closure in inherited method":
    const
      script = folder / "super_in_closure_in_inherited_method.lox"
      expectedExitCode = 0
      expectedOutput = """A
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Super in inherited method":
    const
      script = folder / "super_in_inherited_method.lox"
      expectedExitCode = 0
      expectedOutput = """A
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Super in top level function":
    const
      script = folder / "super_in_top_level_function.lox"
      expectedExitCode = 65
      expectedOutput = """[line 1] Error at 'super': Can't use 'super' outside of a class.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Super without dot":
    const
      script = folder / "super_without_dot.lox"
      expectedExitCode = 65
      expectedOutput = """[line 6] Error at ';': Expect '.' after 'super'.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Super without name":
    const
      script = folder / "super_without_name.lox"
      expectedExitCode = 65
      expectedOutput = """[line 5] Error at ';': Expect superclass method name.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "This in superclass method":
    const
      script = folder / "this_in_superclass_method.lox"
      expectedExitCode = 0
      expectedOutput = """a
b
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)
