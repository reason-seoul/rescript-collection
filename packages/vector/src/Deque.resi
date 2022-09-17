type t<'a>

let empty: t<'a>

let pushFront: (t<'a>, 'a) => t<'a>
let pushBack: (t<'a>, 'a) => t<'a>

let popFront: t<'a> => t<'a>
let popBack: t<'a> => t<'a>

let peekFront: t<'a> => option<'a>
let peekBack: t<'a> => option<'a>

let toArray: t<'a> => array<'a>
