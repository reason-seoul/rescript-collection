include Bvt

let makeBy = (size, f) => makeByU(size, (. i) => f(i))

let length = v => v.size

let size = v => v.size

let get = ({size} as v, i) =>
  if i < 0 || i >= size {
    None
  } else {
    Some(getUnsafe(v, i))
  }

let getExn = ({size} as v, i) => {
  assert (i >= 0 && i < size)
  getUnsafe(v, i)
}

let getByU = (vec, pred) => {
  let i = ref(0)
  let r = ref(None)
  while r.contents == None && i.contents < vec.size {
    let ar = getLeafUnsafe(vec, i.contents)
    let len = ar->A.length
    for j in 0 to len - 1 {
      let v = A.get(ar, j)
      if pred(. v) {
        r := Some(v)
      }
    }
    i := i.contents + len
  }
  r.contents
}

let getBy = (vec, pred) => getByU(vec, (. v) => pred(v))

let getIndexByU = (vec, pred) => {
  let i = ref(0)
  let r = ref(None)
  while r.contents == None && i.contents < vec.size {
    let ar = getLeafUnsafe(vec, i.contents)
    let len = ar->A.length
    for j in 0 to len - 1 {
      let v = A.get(ar, j)
      if pred(. v) {
        r := Some(i.contents)
      }
      i := i.contents + 1
    }
  }
  r.contents
}

let getIndexBy = (vec, pred) => getIndexByU(vec, (. v) => pred(v))

let set = ({size} as vec, i, x) =>
  if i < 0 || i >= size {
    None
  } else {
    Some(setUnsafe(vec, i, x))
  }

let setExn = ({size} as vec, i, x) => {
  assert (i >= 0 && i < size)
  setUnsafe(vec, i, x)
}

/**
 * transient version of 1-by-1 reduce
 * see https://hypirion.com/musings/understanding-clojure-transients
 */
let reduceU = (vec, init, f) => {
  let i = ref(0)
  let acc = ref(init)
  while i.contents < vec.size {
    let ar = getLeafUnsafe(vec, i.contents)
    let len = ar->A.length
    for j in 0 to len - 1 {
      acc := f(. acc.contents, A.get(ar, j))
    }
    i := i.contents + len
  }
  acc.contents
}

let reduce = (vec, init, f) => reduceU(vec, init, (. a, b) => f(a, b))

let reduceWithIndexU = (vec, init, f) => {
  let i = ref(0)
  let acc = ref(init)
  while i.contents < vec.size {
    let ar = getLeafUnsafe(vec, i.contents)
    let len = ar->A.length
    for j in 0 to len - 1 {
      acc := f(. acc.contents, A.get(ar, j), i.contents)
      i := i.contents + 1
    }
  }
  acc.contents
}

let reduceWithIndex = (vec, init, f) => reduceWithIndexU(vec, init, (. a, b, i) => f(a, b, i))

let mapU = (vec, f) => reduceU(vec, make(), (. res, v) => push(res, f(. v)))

let map = (vec, f) => mapU(vec, (. v) => f(v))

let mapWithIndexU = (vec, f) => reduceWithIndexU(vec, make(), (. res, v, i) => push(res, f(. v, i)))

let mapWithIndex = (vec, f) => mapWithIndexU(vec, (. v, i) => f(v, i))

let keepU = (vec, f) =>
  reduceU(vec, make(), (. res, v) =>
    if f(. v) {
      push(res, v)
    } else {
      res
    }
  )

let keep = (vec, f) => keepU(vec, (. x) => f(x))

let keepMapU = (vec, f) =>
  reduceU(vec, make(), (. acc, v) => {
    switch f(. v) {
    | Some(v) => push(acc, v)
    | None => acc
    }
  })

let keepMap = (vec, f) => keepMapU(vec, (. v) => f(v))

let keepWithIndexU = (vec, f) =>
  reduceWithIndexU(vec, make(), (. res, v, i) =>
    if f(. v, i) {
      push(res, v)
    } else {
      res
    }
  )

let keepWithIndex = (vec, f) => keepWithIndexU(vec, (. v, i) => f(v, i))

let forEachU = (vec, f) => {
  let i = ref(0)
  while i.contents < vec.size {
    let ar = getLeafUnsafe(vec, i.contents)
    let len = ar->A.length
    for j in 0 to len - 1 {
      f(. A.get(ar, j))
    }
    i := i.contents + len
  }
}

let forEach = (vec, f) => forEachU(vec, (. x) => f(x))

let forEachWithIndexU = (vec, f) => {
  let i = ref(0)
  while i.contents < vec.size {
    let ar = getLeafUnsafe(vec, i.contents)
    let len = ar->A.length
    for j in 0 to len - 1 {
      f(. A.get(ar, j), i.contents)
      i := i.contents + 1
    }
  }
}

let forEachWithIndex = (vec, f) => forEachWithIndexU(vec, (. x, i) => f(x, i))

let rec someAux = (vec, i, f) =>
  if i == vec->length {
    false
  } else if f(. getUnsafe(vec, i)) {
    true
  } else {
    someAux(vec, i + 1, f)
  }

let rec everyAux = (vec, i, f, len) =>
  if i == len {
    true
  } else if f(. getUnsafe(vec, i)) {
    everyAux(vec, i + 1, f, len)
  } else {
    false
  }

let someU = (vec, f) => someAux(vec, 0, f)

let some = (vec, f) => someU(vec, (. x) => f(x))

let everyU = (vec, f) => everyAux(vec, 0, f, length(vec))

let every = (vec, f) => everyU(vec, (. x) => f(x))

let rec someAux2 = (v1, v2, i, f, len) =>
  if i == len {
    false
  } else if f(. getUnsafe(v1, i), getUnsafe(v2, i)) {
    true
  } else {
    someAux2(v1, v2, i + 1, f, len)
  }

let rec everyAux2 = (v1, v2, i, f, len) =>
  if i == len {
    true
  } else if f(. getUnsafe(v1, i), getUnsafe(v2, i)) {
    everyAux2(v1, v2, i + 1, f, len)
  } else {
    false
  }

let some2U = (v1, v2, f) => someAux2(v1, v2, 0, f, Pervasives.min(length(v1), length(v2)))

let some2 = (v1, v2, f) => some2U(v1, v2, (. a, b) => f(a, b))

let every2U = (v1, v2, f) => everyAux2(v1, v2, 0, f, Pervasives.min(length(v1), length(v2)))

let every2 = (v1, v2, f) => every2U(v1, v2, (. a, b) => f(a, b))

let rec cmpAux2 = (v1, v2, i, f, len) => {
  if i == len {
    0
  } else {
    let c = f(. getUnsafe(v1, i), getUnsafe(v2, i))
    if c == 0 {
      cmpAux2(v1, v2, i + 1, f, len)
    } else {
      c
    }
  }
}

let cmpU = (v1, v2, f) => {
  let len1 = length(v1)
  let len2 = length(v2)
  if len1 > len2 {
    1
  } else if len1 < len2 {
    -1
  } else {
    cmpAux2(v1, v2, 0, f, len1)
  }
}

let cmp = (v1, v2, f) => cmpU(v1, v2, (. a, b) => f(a, b))

let eqU = (v1, v2, f) => {
  let len1 = length(v1)
  let len2 = length(v2)
  if len1 == len2 {
    everyAux2(v1, v2, 0, f, len1)
  } else {
    false
  }
}

let eq = (v1, v2, f) => eqU(v1, v2, (. a, b) => f(a, b))

let zipByU = (v1, v2, f) => {
  let len = min(length(v1), length(v2))
  let i = ref(0)
  let r = ref(make())
  while i.contents < len {
    let ar1 = getLeafUnsafe(v1, i.contents)
    let ar2 = getLeafUnsafe(v2, i.contents)
    let l = ar1->A.length
    for j in 0 to l - 1 {
      r := r.contents->push(f(. A.get(ar1, j), A.get(ar2, j)))
    }
    i := i.contents + l
  }
  r.contents
}

let zipBy = (v1, v2, f) => zipByU(v1, v2, (. a, b) => f(a, b))

let zip = (v1, v2) => zipByU(v1, v2, (. a, b) => (a, b))

let unzip = vec =>
  reduceU(vec, (make(), make()), (. (r1, r2), (a, b)) => (r1->push(a), r2->push(b)))

let sortU = (vec, f) => vec->toArray->Js.Array2.sortInPlaceWith((a, b) => f(. a, b))->fromArray

let sort = (vec, f) => vec->toArray->Js.Array2.sortInPlaceWith(f)->fromArray

let reverse = vec => vec->toArray->Js.Array2.reverseInPlace->fromArray

let shuffle = vec => {
  let ar = vec->toArray
  ar->Belt.Array.shuffleInPlace
  ar->fromArray
}

let concat = (to_, from) => {
  reduceU(from, to_, (. v, x) => push(v, x))
  // reduceU(from, to_->Transient.make, Transient.push)->Transient.toPersistent
}

let concatMany = vs => {
  Js.Array2.reduce(vs, (acc, v) => reduceU(v, acc, (. v, x) => push(v, x)), make())
  // Js.Array2.reduce(
  //   fromAr,
  //   (acc, v) => reduceU(v, acc, Transient.pushU),
  //   to_->Transient.make,
  // )->Transient.toPersistent
}

// TODO: this can be optimized for batched push operations
let pushMany = (to_, from) => {
  Js.Array2.reduce(from, push, to_)
  // Js.Array2.reduce(from, Transient.push, to_->Transient.make)->Transient.toPersistent
}
