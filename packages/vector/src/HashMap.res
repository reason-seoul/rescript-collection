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
and node = SubTrie(trie) | KeyValue(key, value)

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

// mask(0b0110, 0)->Js.log
// maskBits->Js.log

// very fast lookup : O(log_32(N))
// ex:
//   bitmap = 0b0110
//   hash   = 0b0010
//   index  = 1
let rec find = ({bitmap, data}, ~shift=0, hash, key) => {
  let bit = bitpos(hash, shift)

  switch bitmap->land(bit) {
  | 0 => None
  | _ => {
      // hash값을 bitmap에서의 위치로 변환한 뒤 하위에 있는 1의 갯수를 구하면 index가 됨
      let idx = bitmap->land(bit - 1)->ctpop
      let child = data->Js.Array2.unsafe_get(idx)
      switch child {
      | SubTrie(trie) => find(trie, ~shift=shift + numBits, hash, key)
      | KeyValue(k, v) => k == key ? Some(v) : None
      }
    }
  }
}

// test hash
let hash = k => {
  switch k {
  | "k1" => 0b0001
  | "k2" => 0b0010
  | _ => 0
  }
}

find({bitmap: 0b0110, data: [KeyValue("k1", 10), KeyValue("k2", 20)]}, 0b0010, "k2")->Js.log
