type t<'v> = {
  root: Hamt.node<string, 'v>,
  count: int,
}

let get = ({root}, k) => {
  Hamt.find(root, ~shift=0, ~hash=Hash.hashString(. k), ~key=k)
}

let set = ({root, count} as m, k, v) => {
  switch Hamt.assoc(
    root,
    ~shift=0,
    ~hasher=Hash.hashString,
    ~hash=Hash.hashString(. k),
    ~key=k,
    ~value=v,
  ) {
  | Some(root') => {
      root: root',
      count: count + 1,
    }
  | None => m
  }
}

let remove = ({root, count} as m, k) => {
  switch Hamt.dissoc(root, ~shift=0, ~hash=Hash.hashString(. k), ~key=k) {
  | Some(root') => {
      root: root',
      count: count - 1,
    }
  | None => m
  }
}

let size = m => m.count

let fromArray = ar => {
  let empty = {root: Hamt.empty(), count: 0}
  Belt.Array.reduceU(ar, empty, (. m, (k, v)) => set(m, k, v))
}
