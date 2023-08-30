import std/private/[oscommon, ospaths2], std/[osproc, strformat]

const
  nloxExe = "src" / "nlox.exe"
  nloxSource = "src" / "nlox.nim"
  loxScriptsFolder* = "tests" / "scripts"

var nloxExeCompiled = false

proc compilenlox() =
  if (not fileExists(nloxExe)) or (not nloxExeCompiled):
    if not dirExists("src"):
      quit("`src` folder not found.", 72)

    if not fileExists(nloxSource):
      quit(fmt"`{nloxSource}` file not found.", 72)

    # echo fmt"Compiling `{nloxSource}`..."

    let (_, exitCode) = execCmdEx(fmt"nim c {nloxSource}")

    if (exitCode != 0) or (not fileExists(nloxExe)):
      quit(fmt"Unable to compile `{nloxSource}`.", 70)

    nloxExeCompiled = true

proc nloxCompiled*(): bool =
  compilenlox()

  result = nloxExeCompiled

proc nloxTest*(script: string): tuple[output: string, exitCode: int] =
  compilenlox()

  let scriptFull = loxScriptsFolder / script

  result = execCmdEx(fmt"{nloxExe}  {scriptFull}")
