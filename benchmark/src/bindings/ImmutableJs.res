module List = {
  type t<'value>

  @module("immutable") @new external make: unit => t<'value> = "List"

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
  @send external pop: t<'value> => t<'value> = "pop"
  @send external isEmpty: t<'value> => bool = "isEmpty"

  @send
  external concat: (t<'value>, t<'value>) => t<'value> = "concat"

  let concatMany = (l: array<t<'a>>) => {
    let res = ref(Belt.Array.getUnsafe(l, 0))
    for i in 1 to l->Belt.Array.length - 1 {
      res := concat(res.contents, Belt.Array.getUnsafe(l, i))
    }
    res.contents
  }

  @send
  external map: (t<'value>, ('value, int, t<'value>) => 'value2) => t<'value2> = "map"
  @send
  external reduce: (t<'value>, ('acc, 'value) => 'acc, 'acc) => 'acc = "reduce"

  @send external get: (t<'value>, int) => 'value = "get"

  @send external set: (t<'value>, int, 'value) => t<'value> = "set"
}

module Set = {
  type t<'value>

  @module("immutable") @new external make: unit => t<'value> = "Set"
  @module("immutable") @new external fromArray: array<'value> => t<'value> = "Set"

  @send external add: (t<'value>, 'value) => t<'value> = "add"

  @send external get: (t<'value>, 'value) => option<'value> = "get"
  @send external has: (t<'value>, 'value) => bool = "has"
}
