# Package

version       = "0.1.0"
author        = "rockcavera"
description   = "nlox is a Nim implementation of the Lox programming language interpreter"
license       = "MIT"
srcDir        = "src"
bin           = @["nlox"]


# Dependencies

requires "nim >= 2.0.0"


task test, "Runs the test suite":
  exec "nim c -r tests/tall"
