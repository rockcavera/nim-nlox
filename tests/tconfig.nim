import std/[cmdline, exitprocs, osproc, random, strutils, strformat],
       std/private/[oscommon, osfiles, ospaths2]

randomize()

const
  nloxSource = "src" / "nlox.nim"
  loxScriptsFolder* = "tests" / "scripts"

let nloxExeName = "nlox" & $rand(100_000..999_999)

when defined(windows):
  let nloxExe* = nloxExeName & ".exe"
else:
  let nloxExe* = nloxExeName

var nloxExeCompiled = false

proc removeNloxExe() =
  if fileExists(nloxExe):
    discard tryRemoveFile(nloxExe)

proc compilenlox() =
  if (not fileExists(nloxExe)) or (not nloxExeCompiled):
    if not dirExists("src"):
      quit("`src` folder not found.", 72)

    if not fileExists(nloxSource):
      quit(fmt"`{nloxSource}` file not found.", 72)

    let
      options = join(commandLineParams() & @[fmt"-o:{nloxExeName}"], " ")
      cmdLine = fmt"nim c {options} {nloxSource}"

    echo "  ", cmdLine

    let (_, exitCode) = execCmdEx(cmdLine)

    if (exitCode != 0) or (not fileExists(nloxExe)):
      quit(fmt"Unable to compile `{nloxSource}` {nloxExe} {fileExists(nloxExe)}.", 70)

    nloxExeCompiled = true

    addExitProc(removeNloxExe)

proc nloxCompiled*(): bool =
  compilenlox()

  result = nloxExeCompiled

proc nloxTest*(script: string): tuple[output: string, exitCode: int] =
  compilenlox()

  let scriptFull = loxScriptsFolder / script

  result = execCmdEx(fmt"{nloxExe} {scriptFull}")
