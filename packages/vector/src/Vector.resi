@genType
type t<'a>

@genType
let make: unit => t<'a>

@genType
let length: t<'a> => int

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
let mapU: (t<'a>, (. 'a) => 'b) => t<'b>
@genType
let map: (t<'a>, 'a => 'b) => t<'b>

@genType
let keepU: (t<'a>, (. 'a) => bool) => t<'a>
@genType
let keep: (t<'a>, 'a => bool) => t<'a>

@genType
let keepMapU: (t<'a>, (. 'a) => option<'b>) => t<'b>
@genType
let keepMap: (t<'a>, 'a => option<'b>) => t<'b>

@genType
let forEachU: (t<'a>, (. 'a) => unit) => unit
@genType
let forEach: (t<'a>, 'a => unit) => unit

@genType
let someU: (t<'a>, (. 'a) => bool) => bool
@genType
let some: (t<'a>, 'a => bool) => bool

@genType
let everyU: (t<'a>, (. 'a) => bool) => bool
@genType
let every: (t<'a>, 'a => bool) => bool

@genType
let fromArray: array<'a> => t<'a>
@genType
let toArray: t<'a> => array<'a>
