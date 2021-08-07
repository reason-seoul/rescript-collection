type key = Hamt.key
type value = Hamt.value

type t = {
  root: Hamt.trie,
  // count: int, // TODO: make it countable
}

let make = () => {
  root: Hamt.make(),
}

let get = ({root}, k) => {
  Hamt.find(root, ~shift=0, ~hash=Hash.hash(k), ~key=k)
}

let set = ({root}, k, v) => {
  {
    root: Hamt.assoc(root, ~shift=0, ~hash=Hash.hash(k), ~key=k, ~value=v),
  }
}

let remove = ({root}, k) => {
  {
    root: Hamt.dissoc(root, ~shift=0, ~hash=Hash.hash(k), ~key=k),
  }
}
