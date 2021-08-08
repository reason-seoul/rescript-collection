type value = Hamt.key

type t

let make: unit => t

let get: (t, value) => option<value>

let set: (t, value) => t

let remove: (t, value) => t

let size: t => int
