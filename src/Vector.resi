type t<'a>

let make: unit => t<'a>

let length: t<'a> => int

let push: (t<'a>, 'a) => t<'a>
let pop: t<'a> => t<'a>

let get: (t<'a>, int) => option<'a>
let getExn: (t<'a>, int) => 'a
let getUnsafe: (t<'a>, int) => 'a

let set: (t<'a>, int, 'a) => option<t<'a>>
let setExn: (t<'a>, int, 'a) => t<'a>
let setUnsafe: (t<'a>, int, 'a) => t<'a>

let reduceU: (t<'a>, 'b, (. 'b, 'a) => 'b) => 'b
let reduce: (t<'a>, 'b, ('b, 'a) => 'b) => 'b

let mapU: (t<'a>, (. 'a) => 'b) => t<'b>
let map: (t<'a>, 'a => 'b) => t<'b>

let keepU: (t<'a>, (. 'a) => bool) => t<'a>
let keep: (t<'a>, 'a => bool) => t<'a>

let keepMapU: (t<'a>, (. 'a) => option<'b>) => t<'b>
let keepMap: (t<'a>, 'a => option<'b>) => t<'b>

let forEachU: (t<'a>, (. 'a) => unit) => unit
let forEach: (t<'a>, 'a => unit) => unit

let someU: (t<'a>, (. 'a) => bool) => bool
let some: (t<'a>, 'a => bool) => bool

let everyU: (t<'a>, (. 'a) => bool) => bool
let every: (t<'a>, 'a => bool) => bool

let fromArray: array<'a> => t<'a>
let toArray: t<'a> => array<'a>
