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

module type BitmapIndexed = {
  type t<'k, 'v> = bitmapIndexedNode<'k, 'v>

  let make: (int, array<node<'k, 'v>>) => t<'k, 'v>
  let find: (t<'k, 'v>, ~shift: int, ~hash: int, ~key: 'k) => option<'v>
  let assoc: (
    t<'k, 'v>,
    ~shift: int,
    ~hasher: (. 'k) => int,
    ~hash: int,
    ~key: 'k,
    ~value: 'v,
  ) => t<'k, 'v>
  let dissoc: (t<'k, 'v>, ~shift: int, ~hash: int, ~key: 'k) => option<t<'k, 'v>>
}

module BitmapIndexed: BitmapIndexed
