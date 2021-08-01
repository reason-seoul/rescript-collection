// Bit-partitioned Hash Trie

// TODO: no polymorhphic yet
type key = string
type value = int

type t

let make: unit => t

let get: (t, key) => option<value>

let set: (t, key, value) => t
