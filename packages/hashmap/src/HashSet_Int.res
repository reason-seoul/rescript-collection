type t = {hashMap: HashMap.t<int, option<int>>}

let empty = {
  hashMap: HashMap.make(~hasher=(. x) => Hash.hashInt(x)),
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

let fromArray = ar => {
  let s = ref(empty)
  JsArray.forEach(ar, x => {
    s := s.contents->set(x)
  })
  s.contents
}
