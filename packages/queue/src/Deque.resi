/**
Persistent Deque

See FingerTree.res for implementation.
For pushing, popping, peeking, time complexity is O(1) amortized.
*/
type t<'a>

let empty: t<'a>

@genType
let make: unit => t<'a>

@genType
let pushFront: (t<'a>, 'a) => t<'a>

@genType
let pushBack: (t<'a>, 'a) => t<'a>

@genType
let popFront: t<'a> => t<'a>

@genType
let popBack: t<'a> => t<'a>

@genType
let peekFront: t<'a> => option<'a>

@genType
let peekBack: t<'a> => option<'a>

@genType
let toArray: t<'a> => array<'a>
