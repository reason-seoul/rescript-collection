module String = HashMap_String

type hasher<'k> = (. 'k) => int

type t<'k, 'v> = {
  root: Hamt.node<'k, 'v>,
  count: int,
  hasher: hasher<'k>,
}

let make = (~hasher) => {
  root: Hamt.empty(),
  count: 0,
  hasher: hasher,
}

let get = ({root, hasher}, k) => {
  Hamt.find(root, ~shift=0, ~hash=hasher(. k), ~key=k)
}

let set = ({root, count, hasher} as m, k, v) => {
  switch Hamt.assoc(root, ~shift=0, ~hasher, ~hash=hasher(. k), ~key=k, ~value=v) {
  | Some(root') => {
      ...m,
      root: root',
      count: count + 1,
    }
  | None => m
  }
}

let remove = ({root, count, hasher} as m, k) => {
  switch Hamt.dissoc(root, ~shift=0, ~hash=hasher(. k), ~key=k) {
  | Some(root') => {
      ...m,
      root: root',
      count: count - 1,
    }
  | None => m
  }
}

let size = m => m.count
