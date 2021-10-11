module Int = HashSet_Int

type hasher<'v> = (. 'v) => int

type t<'v>

let make: (~hasher: hasher<'v>) => t<'v>

let get: (t<'v>, 'v) => option<'v>

let set: (t<'v>, 'v) => t<'v>

let remove: (t<'v>, 'v) => t<'v>

let size: t<'v> => int
