import std/private/[ospaths2], std/[osproc, strformat]

import ./tconfig

const
  folder = "benchmark"
  scriptsDir = loxScriptsFolder / folder

discard nloxCompiled()

proc bench(script: string) =
  echo fmt"[Bench] nlox {script}"

  let
    scriptPath = scriptsDir / script
    (output, exitCode) = execCmdEx(fmt"{nloxExe} {scriptPath}")

  if exitCode != 0:
    echo "Error\n"
  else:
    echo output

bench("binary_trees.lox")
bench("equality.lox")
bench("fib.lox")
bench("instantiation.lox")
bench("invocation.lox")
bench("method_call.lox")
bench("properties.lox")
bench("string_equality.lox")
bench("trees.lox")
bench("zoo.lox")
bench("zoo_batch.lox")
