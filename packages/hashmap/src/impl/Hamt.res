/**
 * Bit-partitioned Hash Trie
 *
 * 대부분의 구현과 마찬가지로 비트맵의 크기는 32로 정했습니다.
 * 기본 아이디어는 BitmapIndex 노드만 사용하는 것이지만, 최적화를 위해
 * 배열 기반의 ArrayMap 와 고정 크기의 해시인 HashArrayMap을 함께 사용합니다.
 *
 * 변환 조건:
 *  - 시작은 ArrayMap으로 합니다.
 *  - ArrayMap은 8개보다 많아지면 BitmapIndex로 변환합니다.
 *  - BitmapIndex는 16보다 많아지면 HashArrayMap으로 변환합니다.
 *  - HashArrayMap은 8개보다 작아지면 BitmapIndex로 변환합니다.
 */

module A = JsArray

let numBits = 5
let maskBits = 0x01F // 31bits
// let numBits = 2
// let maskBits = 0b011 // 1bits

// bitmap 은 32비트를 가정
// bit가 1이면 은 해당 인덱스의 자식 노드가 있는지 여부를 나타냄

type rec node<'k, 'v> =
  | BitmapIndexed(bitmapIndexedNode<'k, 'v>)
  | MapEntry(mapEntry<'k, 'v>)
  | HashCollision(hashCollisionNode<'k, 'v>)
and bitmapIndexedNode<'k, 'v> = {
  bitmap: int,
  data: array<node<'k, 'v>>,
}
and mapEntry<'k, 'v> = ('k, 'v)
and hashCollisionNode<'k, 'v> = {
  hash: int,
  entries: array<mapEntry<'k, 'v>>,
}

module HashCollision = {
  type t<'k, 'v> = hashCollisionNode<'k, 'v>

  let make = (hash, entries) => {
    {hash: hash, entries: entries}
  }

  let findIndex = ({entries}: t<'k, 'v>, ~key: 'k): int => {
    A.findIndex(entries, ((k, _)) => k == key)
  }

  let find = ({entries}: t<'k, 'v>, ~key: 'k): option<'v> => {
    switch A.find(entries, ((k, _)) => k == key) {
    | None => None
    | Some(_, v) => Some(v)
    }
  }

  let assoc = ({entries} as self: t<'k, 'v>, ~key: 'k, ~value: 'v): t<'k, 'v> => {
    // assert (self.hash == hash)
    let idx = findIndex(self, ~key)
    if idx == -1 {
      {
        ...self,
        entries: A.cloneAndAdd(entries, (key, value)),
      }
    } else {
      self
    }
  }

  /**
   * 값이 2개 -> 1개가 된다면 MapEntry로도 볼 수 있지만, 로직의 간소화를 위해 HashCollisionNode로 일반화하였음
   */
  let dissoc = ({entries} as self: t<'k, 'v>, ~key: 'k): option<t<'k, 'v>> => {
    let idx = findIndex(self, ~key)
    if idx == -1 {
      Some(self)
    } else if A.length(entries) == 1 {
      None
    } else {
      Some({...self, entries: A.cloneWithout(entries, idx)})
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
// BitmapIndexedNode
////////////////////////////////////////////////////////////////////////////////

let makeBitmapIndexed = (bitmap, data) => {
  bitmap: bitmap,
  data: data,
}

// Hacker's Delight, COUNTING BITS
let ctpop = v => {
  let v = v - v->lsr(1)->land(0x55555555)
  let v = v->land(0x33333333) + v->lsr(2)->land(0x33333333)
  let v = (v + v->lsr(4))->land(0xF0F0F0F)
  let v = v + v->lsr(8)
  let v = v + v->lsr(16)
  v->land(0x7f)
}

let mask = (~hash, ~shift) => {
  land(hash->lsr(shift), maskBits)
}

let bitpos = (~hash, ~shift) => {
  lsl(1, mask(~hash, ~shift))
}

/**
 * bit에 해당하는 node가 data의 몇 번째 index인지 구함
 *
 * bitmap - trie의 layout bitmap
 * bit - bitpos를 통해 찾아진 값 (type으로 강제할 수 있을까?)
 */
let indexOfBit = (bitmap, bit) => {
  bitmap->land(bit - 1)->ctpop
}

// very fast lookup : O(log_32(N))
// ex:
//   bitmap = 0b0110
//   hash   = 0b0010
//   index  = 1
let rec findBitmapIndexed = ({bitmap, data}, ~shift, ~hash, ~key): option<'v> => {
  let bit = bitpos(~hash, ~shift)

  switch bitmap->land(bit) {
  | 0 => None
  | _ =>
    // hash값을 bitmap에서의 위치로 변환한 뒤 하위에 있는 1의 갯수를 구하면 index가 됨
    let idx = indexOfBit(bitmap, bit)
    let child = data->Js.Array2.unsafe_get(idx)
    switch child {
    | BitmapIndexed(trie) => findBitmapIndexed(trie, ~shift=shift + numBits, ~hash, ~key)
    | MapEntry(k, v) => k == key ? Some(v) : None
    | HashCollision(node) => HashCollision.find(node, ~key)
    }
  }
}

let rec assocBitmapIndexed = ({bitmap, data} as self, ~shift, ~hasher, ~hash, ~key, ~value) => {
  let bit = bitpos(~hash, ~shift)
  let idx = indexOfBit(bitmap, bit)

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
    | BitmapIndexed(trie) =>
      let newChild = assocBitmapIndexed(trie, ~shift=shift + numBits, ~hasher, ~hash, ~key, ~value)
      if newChild === trie {
        // already exists
        self
      } else {
        {
          bitmap: bitmap,
          data: A.cloneAndSet(data, idx, BitmapIndexed(newChild)),
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
        let leaf = makeNode(~shift=shift + numBits, ~hasher, hasher(. k), k, v, hash, key, value)
        {
          bitmap: bitmap,
          data: A.cloneAndSet(data, idx, leaf),
        }
      }

    | HashCollision(node) =>
      if node.hash == hash {
        let newChild = HashCollision.assoc(node, ~key, ~value)
        if newChild === node {
          // already exists
          self
        } else {
          // assert (A.length(newChild.entries) == A.length(node.entries) + 1)
          {
            bitmap: bitmap,
            data: A.cloneAndSet(data, idx, HashCollision(newChild)),
          }
        }
      } else {
        let newChild =
          makeBitmapIndexed(
            bitpos(~hash=node.hash, ~shift=shift + numBits),
            [HashCollision(node)],
          )->assocBitmapIndexed(~shift=shift + numBits, ~hasher, ~hash, ~key, ~value)
        {
          bitmap: bitmap,
          data: A.cloneAndSet(data, idx, BitmapIndexed(newChild)),
        }
      }
    }
  }
}
and makeNode = (~shift, ~hasher, h1, k1, v1, h2, k2, v2): node<'k, 'v> => {
  if h1 == h2 {
    HashCollision(HashCollision.make(h1, [(k1, v1), (k2, v2)]))
  } else {
    BitmapIndexed(
      makeBitmapIndexed(0, [])
      ->assocBitmapIndexed(~shift, ~hasher, ~hash=h1, ~key=k1, ~value=v1)
      ->assocBitmapIndexed(~shift, ~hasher, ~hash=h2, ~key=k2, ~value=v2),
    )
  }
}

/**
 * 논문에서는 노드가 2개 이하인 경우 trie 축소를 하지만,
 * dissoc 구현에서는 노드가 1개 인 경우에만 축소를 수행하여 메모리보다 성능을 우선하였음.
 *
 * 삭제할 key가 없을 경우에도 Some(self)를 반환
 * Node가 삭제되어야 할 경우 None 반환
 */
let rec dissocBitmapIndexed = ({bitmap, data} as self, ~shift, ~hash, ~key) => {
  let bit = bitpos(~hash, ~shift)

  switch bitmap->land(bit) {
  | 0 =>
    // key doesn't exist
    Some(self)
  | _ =>
    let idx = indexOfBit(bitmap, bit)
    let child = data->A.get(idx)
    switch child {
    | BitmapIndexed(trie) =>
      switch dissocBitmapIndexed(trie, ~shift=shift + numBits, ~hash, ~key) {
      | Some(newChild) =>
        if newChild === trie {
          // key doesn't exist
          Some(self)
        } else {
          Some({
            bitmap: bitmap,
            data: A.cloneAndSet(data, idx, BitmapIndexed(newChild)),
          })
        }
      | None => unset(self, bit, idx)
      }
    | MapEntry(k, _) =>
      if k == key {
        unset(self, bit, idx)
      } else {
        // key doesn't exist
        Some(self)
      }

    | HashCollision(node) =>
      switch HashCollision.dissoc(node, ~key) {
      | Some(newChild) =>
        if newChild === node {
          // key doesn't exist
          Some(self)
        } else {
          // assert (A.length(newChild.entries) == A.length(node.entries) - 1)
          Some({
            bitmap: bitmap,
            data: A.cloneAndSet(data, idx, HashCollision(newChild)),
          })
        }
      | None => unset(self, bit, idx)
      }
    }
  }
}
/**
 * 항상 idx에 해당하는 값이 있다고 가정
 */
and unset = ({bitmap, data}, bit, idx) => {
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

let empty = () => BitmapIndexed(makeBitmapIndexed(0, []))

let find = (node, ~shift, ~hash, ~key) => {
  switch node {
  | BitmapIndexed(node) => findBitmapIndexed(node, ~shift, ~hash, ~key)
  | _ => assert false
  }
}

/**
 * TODO: this breaks === equality
 */
let assoc = (node, ~shift, ~hasher, ~hash, ~key, ~value) => {
  switch node {
  | BitmapIndexed(node) =>
    let newNode = assocBitmapIndexed(node, ~shift, ~hasher, ~hash, ~key, ~value)
    if newNode === node {
      None
    } else {
      Some(BitmapIndexed(newNode))
    }
  | _ => assert false
  }
}

/**
 * TODO: this breaks === equality
 */
let dissoc = (node, ~shift, ~hash, ~key) => {
  switch node {
  | BitmapIndexed(node) =>
    switch dissocBitmapIndexed(node, ~shift, ~hash, ~key) {
    | Some(newNode) =>
      if newNode === node {
        None
      } else {
        Some(BitmapIndexed(newNode))
      }
    | None => Some(empty())
    }
  | _ => assert false
  }
}
