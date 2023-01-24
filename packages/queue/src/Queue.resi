type t<'a>

let empty: t<'a>
let isEmpty: t<'a> => bool

let snoc: (t<'a>, 'a) => t<'a>
let head: t<'a> => 'a // unsafe
let tail: t<'a> => t<'a> // unsafe
