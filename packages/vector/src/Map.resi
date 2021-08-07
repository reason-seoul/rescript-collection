// Bit-partitioned Hash Trie

// TODO: no polymorhphic yet
type key = Hamt.key
type value = Hamt.value

type t

let make: unit => t

let get: (t, key) => option<value>

let set: (t, Hamt.key, Hamt.value) => t

let remove: (t, key) => t
