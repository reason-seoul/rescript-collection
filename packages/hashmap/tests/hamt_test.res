open Hamt

let testHasher = k => {
  switch k {
  | "Sir Robin" => 0b00001101
  | "Sir Lancelot" => 0b10010010
  | "Sir Bedevere" => 0b11111010
  | "Sir Percival" => 0b10010010
  | _ => 0
  }
}

// debug only
@warning("-32")
let toBinString = %raw(`
function (n) {
  return "0b" + n.toString(2).padStart(8, '0');
}
`)
let bitPositions = bits => {
  let rec f = (bits, ~idx) => {
    if bits == 0 {
      list{}
    } else if bits->land(1) == 1 {
      list{idx, ...f(bits->lsr(1), ~idx=idx + 1)}
    } else {
      f(bits->lsr(1), ~idx=idx + 1)
    }
  }
  f(bits, ~idx=0)->Belt.List.toArray
}
let log = root => {
  let rec p = (root, ~depth) => {
    let log = s => {
      Js.log("\t"->Js.String2.repeat(depth) ++ s)
    }
    log(`Bitmap: ` ++ root.bitmap->toBinString)
    Belt.Array.zip(bitPositions(root.bitmap), root.data)->Belt.Array.forEach(((idx, v)) => {
      switch v {
      | BitmapIndexed(t) =>
        log(j`[$idx] SubTrie:`)
        p(t, ~depth=depth + 1)
      | MapEntry(k, v) => log(j`[$idx] MapEntry: $k => $v`)
      | HashCollision({entries}) => log(j`[$idx] HashCollision: $entries`)
      }
    })
  }
  p(root, ~depth=0)
}
let m = {
  bitmap: 0b0110,
  data: [MapEntry("Sir Robin", 10), MapEntry("Sir Bedevere", 20)],
}

let get = (m, k) => {
  BitmapIndexed.find(m, ~shift=0, ~hash=testHasher(k), ~key=k)
}

let set = (m, k, v) => {
  BitmapIndexed.assoc(m, ~shift=0, ~hasher=testHasher, ~hash=testHasher(k), ~key=k, ~value=v)
}

let remove = (m, k) => {
  BitmapIndexed.dissoc(m, ~shift=0, ~hash=testHasher(k), ~key=k)->Belt.Option.getWithDefault(m)
}

assert (get(m, "Sir Robin") == Some(10))
assert (get(m, "Sir Bedevere") == Some(20))
assert (get(m, "Sir Lancelot") == None)

let t2 = m->set("Sir Lancelot", 30)

let m2 = {
  bitmap: 0b0110,
  data: [
    MapEntry("Sir Robin", 10),
    BitmapIndexed({
      bitmap: 0b0101,
      data: [MapEntry("Sir Lancelot", 30), MapEntry("Sir Bedevere", 20)],
    }),
  ],
}

assert (t2 == m2)
assert (get(m2, "Sir Robin") == Some(10))
assert (get(m2, "Sir Bedevere") == Some(20))
assert (get(m2, "Sir Lancelot") == Some(30))

// m2->remove("Sir Robin")->log
// m2->remove("Sir Lancelot")->remove(_, "Sir Bedevere")->log

let m3 = {
  bitmap: 0b0110,
  data: [
    MapEntry("Sir Robin", 10),
    BitmapIndexed({
      bitmap: 0b0101,
      data: [
        HashCollision({
          hash: 0b10010010,
          entries: [("Sir Lancelot", 30), ("Sir Percival", 40)],
        }),
        MapEntry("Sir Bedevere", 20),
      ],
    }),
  ],
}

// m2->set("Sir Percival", 40)->log

assert (m2->set("Sir Percival", 40) == m3)
assert (m3->remove("Sir Lancelot")->get("Sir Percival") == Some(40))

// TODO: structural equality 보장할 수 있는가?
// assert (m3->remove("Sir Bedevere")->remove("Sir Percival") == m2)
