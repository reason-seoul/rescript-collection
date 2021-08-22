type hasher<'v> = 'v => int

type t<'v> = {hashMap: HashMap.t<'v, option<'v>>}

let make = (~hasher) => {
  {
    hashMap: HashMap.make(~hasher),
  }
}

let get = (s, v) => {
  switch s.hashMap->HashMap.get(v) {
  | Some(_) => Some(v)
  | None => None
  }
}

let set = (s, v) => {
  {
    hashMap: s.hashMap->HashMap.set(v, None),
  }
}

let remove = (s, v) => {
  {
    hashMap: s.hashMap->HashMap.remove(v),
  }
}

let size = s => HashMap.size(s.hashMap)
