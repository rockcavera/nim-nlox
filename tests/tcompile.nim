{.used.}
import std/unittest

import ./tconfig

suite "nlox interpreter":
  test "Compilation of nlox interpreter":
    check true == nloxCompiled()
