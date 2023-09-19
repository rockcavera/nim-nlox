# Stdlib imports
import std/hashes

# Internal imports
import ./types

proc `==`*(a, b: String): bool =
  ## Returns `true` if `a` is equal to `b`.
  a.data == b.data

proc hash*(literal: String): Hash =
  ## Returns the precomputed `Hash` of the `String` object
  literal.hash

proc hash*(expr: Expr): Hash =
  ## Returns the precomputed `Hash` of the `Expr` object
  expr.hash
