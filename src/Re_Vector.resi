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

let reduce: (t<'a>, 'b, ('b, 'a) => 'b) => 'b
let reduceU: (t<'a>, 'b, (. 'b, 'a) => 'b) => 'b

// not optimized: convert to/from array internally
let map: (t<'a>, 'a => 'b) => t<'b>
let keep: (t<'a>, 'a => bool) => t<'a>

let fromArray: array<'a> => t<'a>
let toArray: t<'a> => array<'a>

let debug: t<'a> => unit
