{.used.}
import std/private/[ospaths2], std/unittest

import ./tconfig

const folder = "comments"

suite "Comments":
  test "Line at EOF":
    const
      script = folder / "line_at_eof.lox"
      expectedExitCode = 0
      expectedOutput = """ok
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Only line comment and line":
    const
      script = folder / "only_line_comment_and_line.lox"
      expectedExitCode = 0
      expectedOutput = """
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Only line comment":
    const
      script = folder / "only_line_comment.lox"
      expectedExitCode = 0
      expectedOutput = """
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Unicode":
    const
      script = folder / "unicode.lox"
      expectedExitCode = 0
      expectedOutput = """ok
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)
