type hasher<'v> = 'v => int

type t<'v> = {hashMap: Map.t<'v, option<'v>>}

let make = (~hasher) => {
  {
    hashMap: Map.make(~hasher),
  }
}

let get = (s, v) => {
  switch s.hashMap->Map.get(v) {
  | Some(_) => Some(v)
  | None => None
  }
}

let set = (s, v) => {
  {
    hashMap: s.hashMap->Map.set(v, None),
  }
}

let remove = (s, v) => {
  {
    hashMap: s.hashMap->Map.remove(v),
  }
}

let size = s => Map.size(s.hashMap)
