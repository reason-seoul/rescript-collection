module A = Belt.Array
module V = Vector

let v0 = V.fromArray(A.makeBy(100, i => i*i))
let v = V.makeByU(100, (. i) => i*i)

V.forEachWithIndex(v, (i, ii) => {
  Js.log2(i, ii)
})

// let v2 = A.makeBy(100, i => i * i)->V.fromArray

assert(v == v0)

// Bvt.log(v)
