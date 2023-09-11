import std/strformat

import ./types

proc newLoxInstance*(klass: LoxClass): LoxInstance =
  result = new(LoxInstance)
  result.klass = klass

proc toString*(instance: LoxInstance): string =
  result = fmt"{instance.klass.name} instance"
