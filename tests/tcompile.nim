{.used.}
import std/unittest

import ./tconfig

suite "nlox interpreter":
  test "Compilation of nlox interpreter":
    check true == nloxCompiled()

  test "Empty file":
    const
      script = "empty_file.lox"
      expectedExitCode = 0
      expectedOutput = """
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Precedence":
    const
      script = "precedence.lox"
      expectedExitCode = 0
      expectedOutput = """14
8
4
0
true
true
true
true
0
0
0
0
4
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)
