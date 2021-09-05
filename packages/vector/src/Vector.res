include Bvt

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
    let ar = getArrayUnsafe(vec, i.contents)
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
    let ar = getArrayUnsafe(vec, i.contents)
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
    let ar = getArrayUnsafe(vec, i.contents)
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
    let ar = getArrayUnsafe(vec, i.contents)
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
    let ar = getArrayUnsafe(vec, i.contents)
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
    let ar = getArrayUnsafe(vec, i.contents)
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

let someU = (vec, f) => someAux(vec, 0, f)

let some = (vec, f) => someU(vec, (. x) => f(x))

let rec everyAux = (vec, i, f) =>
  if i == vec->length {
    true
  } else if f(. getUnsafe(vec, i)) {
    everyAux(vec, i + 1, f)
  } else {
    false
  }

let everyU = (vec, f) => everyAux(vec, 0, f)

let every = (vec, f) => everyU(vec, (. x) => f(x))
