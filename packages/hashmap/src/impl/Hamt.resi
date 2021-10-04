type rec node<'k, 'v> =
  | BitmapIndexed(bitmapIndexedNode<'k, 'v>)
  | MapEntry(mapEntry<'k, 'v>)
  | HashCollision(hashCollisionNode<'k, 'v>)
and bitmapIndexedNode<'k, 'v> = {
  bitmap: int,
  data: array<node<'k, 'v>>,
}
and mapEntry<'k, 'v> = ('k, 'v)
and hashCollisionNode<'k, 'v> = {
  hash: int,
  entries: array<mapEntry<'k, 'v>>,
}

let empty: unit => node<'k, 'v>
let find: (node<'k, 'v>, ~shift: int, ~hash: int, ~key: 'k) => option<'v>
let assoc: (
  node<'k, 'v>,
  ~shift: int,
  ~hasher: (. 'k) => int,
  ~hash: int,
  ~key: 'k,
  ~value: 'v,
) => option<node<'k, 'v>>
let dissoc: (node<'k, 'v>, ~shift: int, ~hash: int, ~key: 'k) => option<node<'k, 'v>>
