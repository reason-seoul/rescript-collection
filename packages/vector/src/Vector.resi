@genType
type t<'a>

@genType
let make: unit => t<'a>
@genType
let makeByU: (int, (. int) => 'a) => t<'a>
@genType
let makeBy: (int, int => 'a) => t<'a>

@genType
let length: t<'a> => int
@genType
let size: t<'a> => int

@genType
let push: (t<'a>, 'a) => t<'a>

@genType
let pop: t<'a> => t<'a>

@genType
let get: (t<'a>, int) => option<'a>
@genType
let getExn: (t<'a>, int) => 'a
@genType
let getUnsafe: (t<'a>, int) => 'a

@genType
let getByU: (t<'a>, (. 'a) => bool) => option<'a>
@genType
let getBy: (t<'a>, 'a => bool) => option<'a>

@genType
let getIndexByU: (t<'a>, (. 'a) => bool) => option<int>
@genType
let getIndexBy: (t<'a>, 'a => bool) => option<int>

@genType
let set: (t<'a>, int, 'a) => option<t<'a>>
@genType
let setExn: (t<'a>, int, 'a) => t<'a>
@genType
let setUnsafe: (t<'a>, int, 'a) => t<'a>

@genType
let reduceU: (t<'a>, 'b, (. 'b, 'a) => 'b) => 'b
@genType
let reduce: (t<'a>, 'b, ('b, 'a) => 'b) => 'b

@genType
let reduceWithIndexU: (t<'a>, 'b, (. 'b, 'a, int) => 'b) => 'b
@genType
let reduceWithIndex: (t<'a>, 'b, ('b, 'a, int) => 'b) => 'b

@genType
let mapU: (t<'a>, (. 'a) => 'b) => t<'b>
@genType
let map: (t<'a>, 'a => 'b) => t<'b>

@getType
let mapWithIndexU: (t<'a>, (. 'a, int) => 'b) => t<'b>

@genType
let mapWithIndex: (t<'a>, ('a, int) => 'b) => t<'b>

@genType
let keepU: (t<'a>, (. 'a) => bool) => t<'a>
@genType
let keep: (t<'a>, 'a => bool) => t<'a>

@genType
let keepMapU: (t<'a>, (. 'a) => option<'b>) => t<'b>
@genType
let keepMap: (t<'a>, 'a => option<'b>) => t<'b>

@genType
let keepWithIndexU: (t<'a>, (. 'a, int) => bool) => t<'a>
@genType
let keepWithIndex: (t<'a>, ('a, int) => bool) => t<'a>

@genType
let forEachU: (t<'a>, (. 'a) => unit) => unit
@genType
let forEach: (t<'a>, 'a => unit) => unit

@genType
let forEachWithIndexU: (t<'a>, (. 'a, int) => unit) => unit
@genType
let forEachWithIndex: (t<'a>, ('a, int) => unit) => unit

@genType
let someU: (t<'a>, (. 'a) => bool) => bool
@genType
let some: (t<'a>, 'a => bool) => bool

@genType
let some2U: (t<'a>, t<'a>, (. 'a, 'a) => bool) => bool
@genType
let some2: (t<'a>, t<'a>, ('a, 'a) => bool) => bool

@genType
let everyU: (t<'a>, (. 'a) => bool) => bool
@genType
let every: (t<'a>, 'a => bool) => bool

@genType
let every2U: (t<'a>, t<'a>, (. 'a, 'a) => bool) => bool
@genType
let every2: (t<'a>, t<'a>, ('a, 'a) => bool) => bool

@genType
let cmpU: (t<'a>, t<'a>, (. 'a, 'a) => int) => int
@genType
let cmp: (t<'a>, t<'a>, ('a, 'a) => int) => int

@genType
let eqU: (t<'a>, t<'a>, (. 'a, 'a) => bool) => bool
@genType
let eq: (t<'a>, t<'a>, ('a, 'a) => bool) => bool

@genType
let zip: (t<'a>, t<'b>) => t<('a, 'b)>
@genType
let zipByU: (t<'a>, t<'b>, (. 'a, 'b) => 'c) => t<'c>
@genType
let zipBy: (t<'a>, t<'b>, ('a, 'b) => 'c) => t<'c>

@genType
let unzip: t<('a, 'b)> => (t<'a>, t<'b>)

@genType
let fromArray: array<'a> => t<'a>
@genType
let toArray: t<'a> => array<'a>
