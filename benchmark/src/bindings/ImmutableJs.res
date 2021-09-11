module List = {
  type t<'value>

  @module("immutable")
  external fromArray: array<'value> => t<'value> = "List"

  @send
  external filter: (t<'value>, 'value => bool) => t<'value> = "filter"
  @send
  external forEach: (t<'value>, ('value, int, t<'value>) => bool) => int = "forEach"
  @send external toArray: t<'value> => array<'value> = "toArray"
  @send @return(nullable)
  external first: t<'value> => option<'value> = "first"
  @send external count: t<'value> => int = "count"
  @send external push: (t<'value>, 'value) => t<'value> = "push"
  @send external isEmpty: t<'value> => bool = "isEmpty"
  @send
  external map: (t<'value>, ('value, int, t<'value>) => 'value2) => t<'value2> = "map"
  @send
  external reduce: (t<'value>, ('acc, 'value) => 'acc, 'acc) => 'acc = "reduce"

  @send external get: (t<'value>, int) => 'value = "get"

  @send external set: (t<'value>, int, 'value) => t<'value> = "set"
}
