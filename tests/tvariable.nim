{.used.}
import std/private/[ospaths2], std/unittest

import ./tconfig

const folder = "variable"

suite "Variable":
  test "In middle of block":
    const
      script = folder / "in_middle_of_block.lox"
      expectedExitCode = 0
      expectedOutput = """a
a b
a c
a b d
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "In nested block":
    const
      script = folder / "in_nested_block.lox"
      expectedExitCode = 0
      expectedOutput = """outer
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Redeclare global":
    const
      script = folder / "redeclare_global.lox"
      expectedExitCode = 0
      expectedOutput = """nil
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Redefine global":
    const
      script = folder / "redefine_global.lox"
      expectedExitCode = 0
      expectedOutput = """2
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Scope reuse in different blocks":
    const
      script = folder / "scope_reuse_in_different_blocks.lox"
      expectedExitCode = 0
      expectedOutput = """first
second
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Shadow and local":
    const
      script = folder / "shadow_and_local.lox"
      expectedExitCode = 0
      expectedOutput = """outer
inner
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Shadow global":
    const
      script = folder / "shadow_global.lox"
      expectedExitCode = 0
      expectedOutput = """shadow
global
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Shadow local":
    const
      script = folder / "shadow_local.lox"
      expectedExitCode = 0
      expectedOutput = """shadow
local
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Undefined global":
    const
      script = folder / "undefined_global.lox"
      expectedExitCode = 70
      expectedOutput = """Undefined variable 'notDefined'.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Undefined local":
    const
      script = folder / "undefined_local.lox"
      expectedExitCode = 70
      expectedOutput = """Undefined variable 'notDefined'.
[line 2]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Uninitialized":
    const
      script = folder / "uninitialized.lox"
      expectedExitCode = 0
      expectedOutput = """nil
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Use false as var":
    const
      script = folder / "use_false_as_var.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'false': Expect variable name.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Use global in initializer":
    const
      script = folder / "use_global_in_initializer.lox"
      expectedExitCode = 0
      expectedOutput = """value
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Use nil as var":
    const
      script = folder / "use_nil_as_var.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'nil': Expect variable name.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Use this as var":
    const
      script = folder / "use_this_as_var.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'this': Expect variable name.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Unreached undefined":
    const
      script = folder / "unreached_undefined.lox"
      expectedExitCode = 0
      expectedOutput = """ok
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)
