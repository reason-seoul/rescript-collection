type t<'v>

let get: (t<'v>, string) => option<'v>

let set: (t<'v>, string, 'v) => t<'v>

let remove: (t<'v>, string) => t<'v>

let size: t<'v> => int

let fromArray: array<(string, 'v)> => t<'v>
