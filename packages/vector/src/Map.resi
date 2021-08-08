// Bit-partitioned Hash Trie

// TODO: no polymorhphic yet
type key = Hamt.key

type t<'v>

let make: unit => t<'v>

let get: (t<'v>, key) => option<'v>

let set: (t<'v>, Hamt.key, 'v) => t<'v>

let remove: (t<'v>, key) => t<'v>

let size: t<'v> => int
