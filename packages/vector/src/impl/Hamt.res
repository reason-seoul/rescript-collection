// Bit-partitioned Hash Trie

// let numBits = 5;
// let maskBits = 0x01F // 31bits
let numBits = 2
let maskBits = 0b011 // 1bits

type key = string
type value = int

// bitmap 은 32비트를 가정
// bit가 1이면 은 해당 인덱스의 자식 노드가 있는지 여부를 나타냄
type rec trie = {
  bitmap: int,
  data: array<node>,
}
and node = SubTrie(trie) | MapEntry(key, value)

type t = trie

let make = () => {
  bitmap: 0,
  data: [],
}

// Hacker's Delight, COUNTING BITS
let ctpop = v => {
  let v = v - v->lsr(1)->land(0x55555555)
  let v = v->land(0x33333333) + v->lsr(2)->land(0x33333333)
  let v = (v + v->lsr(4))->land(0xF0F0F0F)
  (v * 0x1010101)->lsr(24)
}

// Belt.Array.range(1, 32)->Belt.Array.forEach(v => Js.log(ctpop(v)))

let mask = (hash, shift) => {
  land(hash->lsr(shift), maskBits)
}

let bitpos = (hash, shift) => {
  lsl(1, mask(hash, shift))
}

/**
 * bit에 해당하는 node가 data의 몇 번째 index인지 구함
 *
 * bitmap - trie의 layout bitmap
 * bit - bitpos를 통해 찾아진 값 (type으로 강제할 수 있을까?)
 */
let indexAtBitmapTrie = (bitmap, bit) => {
  bitmap->land(bit - 1)->ctpop
}

// debug only
@warning("-32")
let toBinString = %raw(`
function (n) { 
  return "0b" + n.toString(2).padStart(8, '0');
}
`)

// mask(0b0110, 0)->Js.log
// maskBits->Js.log

// very fast lookup : O(log_32(N))
// ex:
//   bitmap = 0b0110
//   hash   = 0b0010
//   index  = 1
let rec find = ({bitmap, data}, ~shift, ~hash, ~key) => {
  let bit = bitpos(hash, shift)

  switch bitmap->land(bit) {
  | 0 => None
  | _ =>
    // hash값을 bitmap에서의 위치로 변환한 뒤 하위에 있는 1의 갯수를 구하면 index가 됨
    let idx = indexAtBitmapTrie(bitmap, bit)
    let child = data->Js.Array2.unsafe_get(idx)
    switch child {
    | SubTrie(trie) => find(trie, ~shift=shift + numBits, ~hash, ~key)
    | MapEntry(k, v) => k == key ? Some(v) : None
    }
  }
}

module A = JsArray

let rec assoc = ({bitmap, data} as self, ~shift, ~hash, ~key, ~value) => {
  let bit = bitpos(hash, shift)
  let idx = indexAtBitmapTrie(bitmap, bit)

  // has child at idx?
  switch bitmap->land(bit) {
  | 0 =>
    // insert here!

    let n = ctpop(bitmap)
    let ar = A.make(n + 1)

    // 1. copy data[0, idx)
    A.blit(~src=data, ~srcOffset=0, ~dst=ar, ~dstOffset=0, ~len=idx)
    // 2. set idx
    A.set(ar, idx, MapEntry(key, value))
    // 3. copy data[idx, n)
    A.blit(~src=data, ~srcOffset=idx, ~dst=ar, ~dstOffset=idx + 1, ~len=n - idx)

    {
      bitmap: bitmap->lor(bit),
      data: ar,
    }
  | _ =>
    // copy new path then recursively call assoc
    let child = data->A.get(idx)
    switch child {
    | SubTrie(trie) =>
      let newChild = assoc(trie, ~shift=shift + numBits, ~hash, ~key, ~value)
      if newChild === trie {
        // already exists
        self
      } else {
        {
          bitmap: bitmap,
          data: A.cloneAndSet(data, idx, SubTrie(newChild)),
        }
      }
    | MapEntry(k, v) =>
      if k == key {
        if v == value {
          // already exists
          self
        } else {
          // only value updated
          {
            bitmap: bitmap,
            data: A.cloneAndSet(data, idx, MapEntry(k, v)),
          }
        }
      } else {
        // extend a leaf, change child into subtrie
        let leaf = makeNode(~shift, Hash.hash(k), k, v, hash, key, value)
        {
          bitmap: bitmap,
          data: A.cloneAndSet(data, idx, SubTrie(leaf)),
        }
      }
    }
  }
}
/**
 * TODO: could it be non-rec? (i.e. no assoc)
 */
and makeNode = (~shift, h1, k1, v1, h2, k2, v2) => {
  // TODO: this requires perfect hashing fn ;)
  assert (h1 != h2)

  make()
  ->assoc(~shift=shift + numBits, ~hash=h1, ~key=k1, ~value=v1)
  ->assoc(~shift=shift + numBits, ~hash=h2, ~key=k2, ~value=v2)
}

/**
 * 논문에서는 노드가 2개 이하인 경우 trie 축소를 하지만,
 * dissoc 구현에서는 노드가 1개 인 경우에만 축소를 수행하여 메모리보다 성능을 우선하였음.
 */
let rec dissoc = ({bitmap, data} as self, ~shift, ~hash, ~key) => {
  let bit = bitpos(hash, shift)

  switch bitmap->land(bit) {
  | 0 =>
    // key doesn't exist
    Some(self)
  | _ =>
    let idx = indexAtBitmapTrie(bitmap, bit)
    let child = data->A.get(idx)
    switch child {
    | SubTrie(trie) =>
      switch dissoc(trie, ~shift=shift + numBits, ~hash, ~key) {
      | Some(newChild) =>
        if newChild === trie {
          // key doesn't exist
          Some(self)
        } else {
          Some({
            bitmap: bitmap,
            data: A.cloneAndSet(data, idx, SubTrie(newChild)),
          })
        }
      | None =>
        if bitmap == bit {
          // compaction, recursively
          None
        } else {
          Some({
            bitmap: bitmap->lxor(bit),
            data: data->A.cloneWithout(idx),
          })
        }
      }

    | MapEntry(k, _) =>
      if k == key {
        if bitmap == bit {
          // trie compaction
          None
        } else {
          Some({
            bitmap: bitmap->lxor(bit),
            data: data->A.cloneWithout(idx),
          })
        }
      } else {
        // key doesn't exist
        Some(self)
      }
    }
  }
}

let get = (m, k) => {
  find(m, ~shift=0, ~hash=Hash.hash(k), ~key=k)
}

let set = (m, k, v) => {
  assoc(m, ~shift=0, ~hash=Hash.hash(k), ~key=k, ~value=v)
}

let remove = (m, k) => {
  dissoc(m, ~shift=0, ~hash=Hash.hash(k), ~key=k)
}

///// scratchpad

let trie = {
  bitmap: 0b0110,
  data: [MapEntry("Sir Robin", 10), MapEntry("Sir Bedevere", 20)],
}

// get(trie, "Sir Robin")->Js.log
// get(trie, "Sir Bedevere")->Js.log

// trie->set("Sir Lancelot", 30)->Js.log

let t2 = trie->set("Sir Lancelot", 30)

let trie = {
  bitmap: 0b0110,
  data: [
    MapEntry("Sir Robin", 10),
    SubTrie({
      bitmap: 0b0101,
      data: [MapEntry("Sir Lancelot", 30), MapEntry("Sir Bedevere", 20)],
    }),
  ],
}

assert (t2 == trie)

// get(trie, "Sir Robin")->Js.log
// get(trie, "Sir Bedevere")->Js.log
// get(trie, "Sir Lancelot")->Js.log
