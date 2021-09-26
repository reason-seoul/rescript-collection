type t

let empty: t

let get: (t, int) => option<int>

let set: (t, int) => t

let remove: (t, int) => t

let size: t => int

let fromArray: array<int> => t
