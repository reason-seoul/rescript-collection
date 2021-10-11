type t

@module("mori") external vector: unit => t = "vector"
@module("mori") external into: (t, array<'a>) => t = "into"
@module("mori") external conj: (t, 'a) => t = "conj"
@module("mori") external pop: t => t = "pop"

@module("mori") external nth: (t, int) => t = "nth"

@module("mori") external assoc: (t, 'key, 'value) => t = "assoc"

@module("mori") external map: ('a => 'b, t) => t = "map"
@module("mori") external set: array<'a> => t = "set"

@module("mori") @return(nullable) external get: (t, 'a) => option<'a> = "get"

@module("mori") external reduce: ('a => 'b, 'a, t) => 'a = "reduce"

@module("mori") external intoArray: t => array<'a> = "intoArray"
