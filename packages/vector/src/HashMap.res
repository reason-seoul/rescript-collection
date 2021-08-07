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
  // count: int, // TODO: make it countable
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
let rec trieFind = ({bitmap, data}, ~shift, ~hash, ~key) => {
  let bit = bitpos(hash, shift)

  switch bitmap->land(bit) {
  | 0 => None
  | _ => {
      // hash값을 bitmap에서의 위치로 변환한 뒤 하위에 있는 1의 갯수를 구하면 index가 됨
      let idx = indexAtBitmapTrie(bitmap, bit)
      let child = data->Js.Array2.unsafe_get(idx)
      switch child {
      | SubTrie(trie) => trieFind(trie, ~shift=shift + numBits, ~hash, ~key)
      | MapEntry(k, v) => k == key ? Some(v) : None
      }
    }
  }
}

module A = JsArray

// test hash
let hashFn = k => {
  switch k {
  | "Sir Robin" => 0b00001101
  | "Sir Lancelot" => 0b10010010
  | "Sir Bedevere" => 0b11111010
  | _ => 0
  }
}

let rec trieAssoc = ({bitmap, data} as self, ~shift, ~hash, ~key, ~value) => {
  let bit = bitpos(hash, shift)
  let idx = indexAtBitmapTrie(bitmap, bit)

  // has child at idx?
  switch bitmap->land(bit) {
  | 0 => {
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
    }
  | _ => {
      // copy new path then recursively call trieAssoc
      let child = data->A.get(idx)
      switch child {
      | SubTrie(trie) => {
          let newChild = SubTrie(trieAssoc(trie, ~shift=shift + numBits, ~hash, ~key, ~value))

          // TODO: check if newChild is identical to child so we can skip cloning
          //       the data array and return the original argument instead.
          {
            bitmap: bitmap,
            data: A.cloneAndSet(data, idx, newChild),
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
          let leaf = makeNode(~shift, hashFn(k), k, v, hash, key, value)
          {
            bitmap: bitmap,
            data: A.cloneAndSet(data, idx, SubTrie(leaf)),
          }
        }
      }
    }
  }
}
/**
 * TODO: could it be non-rec? (i.e. no trieAssoc)
 */
and makeNode = (~shift, h1, k1, v1, h2, k2, v2) => {
  // TODO: this requires perfect hashing fn ;)
  assert (h1 != h2)

  make()
  ->trieAssoc(~shift=shift + numBits, ~hash=h1, ~key=k1, ~value=v1)
  ->trieAssoc(~shift=shift + numBits, ~hash=h2, ~key=k2, ~value=v2)
}

let rec trieDissoc = ({bitmap, data} as m, ~shift, ~hash, ~key) => {
  let bit = bitpos(hash, shift)

  switch bitmap->land(bit) {
  | 0 => // not exists
    m
  | _ =>
    let idx = indexAtBitmapTrie(bitmap, bit)
    let child = data->A.get(idx)
    switch child {
    | SubTrie(trie) =>
      let newChild = trieDissoc(trie, ~shift=shift + numBits, ~hash, ~key)
      // TODO: (optimization) newChild 가 trie 랑 같으면 => m 반환

      // TODO: trie compaction
      {
        bitmap: bitmap,
        data: A.cloneAndSet(data, idx, SubTrie(newChild)),
      }

    | MapEntry(k, _) =>
      if k == key {
        // TODO: trie compaction
        {
          bitmap: bitmap->lxor(bit),
          data: data->A.cloneWithout(idx),
        }
      } else {
        // wrong key, sorry!
        m
      }
    }
  }
}

let get = (m, k) => {
  trieFind(m, ~shift=0, ~hash=hashFn(k), ~key=k)
}

let set = (m, k, v) => {
  trieAssoc(m, ~shift=0, ~hash=hashFn(k), ~key=k, ~value=v)
}

let remove = (m, k) => {
  trieDissoc(m, ~shift=0, ~hash=hashFn(k), ~key=k)
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
