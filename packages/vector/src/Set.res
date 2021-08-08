type value = Hamt.key

type t = {hashMap: Map.t<option<value>>}

let make = () => {
  {
    hashMap: Map.make(),
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
