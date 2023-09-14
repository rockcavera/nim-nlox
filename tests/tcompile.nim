{.used.}
import std/unittest

disableParamFiltering()

import ./tconfig

suite "Compile":
  test "nlox interpreter":
    check true == nloxCompiled()
