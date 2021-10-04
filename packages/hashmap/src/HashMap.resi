// Bit-partitioned Hash Trie
module String = HashMap_String

type hasher<'k> = (. 'k) => int

type t<'k, 'v>

let make: (~hasher: hasher<'k>) => t<'k, 'v>

let get: (t<'k, 'v>, 'k) => option<'v>

let set: (t<'k, 'v>, 'k, 'v) => t<'k, 'v>

let remove: (t<'k, 'v>, 'k) => t<'k, 'v>

let size: t<'k, 'v> => int
