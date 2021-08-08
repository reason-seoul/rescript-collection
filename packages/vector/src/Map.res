type key = Hamt.key

type t<'v> = {
  root: Hamt.t<'v>,
  count: int,
}

let make = () => {
  root: Hamt.make(),
  count: 0,
}

let get = ({root}, k) => {
  Hamt.find(root, ~shift=0, ~hash=Hash.hash(k), ~key=k)
}

let set = ({root, count} as m, k, v) => {
  let root' = Hamt.assoc(root, ~shift=0, ~hash=Hash.hash(k), ~key=k, ~value=v)
  if root' === root {
    m
  } else {
    {
      root: root',
      count: count - 1,
    }
  }
}

let remove = ({root, count} as m, k) => {
  switch Hamt.dissoc(root, ~shift=0, ~hash=Hash.hash(k), ~key=k) {
  | Some(root') =>
    if root' === root {
      m
    } else {
      {root: root', count: count - 1}
    }

  | None => make()
  }
}

let size = m => m.count
