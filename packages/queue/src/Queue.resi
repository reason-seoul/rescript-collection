type t<'a>

let empty: t<'a>

@genType
let make: unit => t<'a>

@genType
let isEmpty: t<'a> => bool

@genType
let snoc: (t<'a>, 'a) => t<'a>

@genType
let head: t<'a> => 'a // unsafe

@genType
let tail: t<'a> => t<'a> // unsafe
