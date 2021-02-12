type t<'a>

export make: unit => t<'a>

export length: t<'a> => int

export push: (t<'a>, 'a) => t<'a>
export pop: t<'a> => t<'a>

export get: (t<'a>, int) => option<'a>
export getExn: (t<'a>, int) => 'a
export getUnsafe: (t<'a>, int) => 'a

export set: (t<'a>, int, 'a) => option<t<'a>>
export setExn: (t<'a>, int, 'a) => t<'a>
export setUnsafe: (t<'a>, int, 'a) => t<'a>

export reduceU: (t<'a>, 'b, (. 'b, 'a) => 'b) => 'b
export reduce: (t<'a>, 'b, ('b, 'a) => 'b) => 'b

export mapU: (t<'a>, (. 'a) => 'b) => t<'b>
export map: (t<'a>, 'a => 'b) => t<'b>

export keepU: (t<'a>, (. 'a) => bool) => t<'a>
export keep: (t<'a>, 'a => bool) => t<'a>

export keepMapU: (t<'a>, (. 'a) => option<'b>) => t<'b>
export keepMap: (t<'a>, 'a => option<'b>) => t<'b>

export forEachU: (t<'a>, (. 'a) => unit) => unit
export forEach: (t<'a>, 'a => unit) => unit

export someU: (t<'a>, (. 'a) => bool) => bool
export some: (t<'a>, 'a => bool) => bool

export everyU: (t<'a>, (. 'a) => bool) => bool
export every: (t<'a>, 'a => bool) => bool

export fromArray: array<'a> => t<'a>
export toArray: t<'a> => array<'a>
