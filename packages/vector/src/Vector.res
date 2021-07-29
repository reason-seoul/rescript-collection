// implementation of a persistent bit-partitioned vector trie.

module A = {
  // Belt.Array.slice does element-wise operation for no reason.
  // It's only better than Js.Array2.slice in its argument design.
  let slice = (ar, ~offset, ~len) => Js.Array2.slice(ar, ~start=offset, ~end_=offset + len)

  // Belt.Array.copy uses Belt.Array.slice internally.
  // The fastest way to copy one array to another is using Js.Array2.copy
  let copy = Js.Array2.copy

  let get = Js.Array2.unsafe_get
  let set = Js.Array2.unsafe_set
  let length = Js.Array2.length

  @val
  external make: int => array<'a> = "Array"

  // src and dst must not overlap
  let blit = (~src, ~srcOffset, ~dst, ~dstOffset, ~len) =>
    for i in 0 to len - 1 {
      Js.Array2.unsafe_set(dst, dstOffset + i, get(src, srcOffset + i))
    }

  @send
  external forEach: (array<'a>, 'a => unit) => unit = "forEach"
}

// to handle the impossible case without throwing an exception
let absurd = Obj.magic()

// Test various branching factors using this formula.
// @bs.inline doesn't work for this kind of assignment.
//  numBits := n
//  numBranches := lsl(1, numBits)
//  bitMask := numBranches - 1
let numBits = 5
let numBranches = 32
let bitMask = 0x1f

type rec tree<'a> =
  | Node(array<tree<'a>>)
  | Leaf(array<'a>)

module Tree = {
  let cloneNode = x =>
    switch x {
    | Node(ar) => Node(ar->A.copy)
    | Leaf(_) => @coverage(off) absurd
    }

  let setNode = (node, idx, v) =>
    switch node {
    | Node(ar) => A.set(ar, idx, v)
    | Leaf(_) => @coverage(off) absurd
    }

  let getNode = (node, idx) =>
    switch node {
    | Node(ar) => A.get(ar, idx)
    | Leaf(_) => @coverage(off) absurd
    }
}

type t<'a> = {
  size: int,
  shift: int,
  root: tree<'a>,
  tail: array<'a>,
}

let make = () => {
  size: 0,
  shift: numBits,
  root: Node([]),
  tail: [],
}

let length = v => v.size

let tailOffset = ({size}) =>
  if size < numBranches {
    0
  } else {
    (size - 1)->lsr(numBits)->lsl(numBits)
  }

/**
 * makes a lineage to `node` from new root
 */
let rec newPath = (~level, node) =>
  if level == 0 {
    node
  } else {
    newPath(~level=level - numBits, Node([node]))
  }

let rec pushTail = (~size, ~level, parent, tail) => {
  let ret = Tree.cloneNode(parent)
  let subIdx = (size - 1)->lsr(level)->land(bitMask)
  if level == numBits {
    // array will be grown by out of index access. optimize?
    Tree.setNode(ret, subIdx, tail)
    ret
  } else {
    switch parent {
    | Node(ar) =>
      let newChild =
        subIdx < ar->A.length
          ? pushTail(~size, ~level=level - numBits, A.get(ar, subIdx), tail)
          : newPath(~level=level - numBits, tail)
      Tree.setNode(ret, subIdx, newChild)
      ret
    | Leaf(_) => @coverage(off) absurd
    }
  }
}

let push = ({size, shift, root, tail} as vec, x) =>
  // case 1: when tail has room to append
  if tail->A.length < numBranches {
    // copy and append
    let newTail = tail->A.copy
    A.set(newTail, tail->A.length, x)

    {...vec, size: size + 1, tail: newTail}
  } else {
    // case 2 & 3
    // sz >= b^(depth+1) + b
    let isRootOverflow = lsr(size, numBits) > lsl(1, shift)

    if isRootOverflow {
      // case 3: when there's no room to append
      let newRoot = Node([root, newPath(~level=shift, Leaf(tail))])
      {
        size: size + 1,
        shift: vec.shift + numBits,
        root: newRoot,
        tail: [x],
      }
    } else {
      // case 2: all leaf nodes are full but we have room for a new inner node.
      let newRoot = pushTail(~size, ~level=shift, root, Leaf(tail))
      {...vec, size: size + 1, root: newRoot, tail: [x]}
    }
  }

let getArrayUnsafe = ({root, shift, tail} as vec, idx) => {
  if idx >= tailOffset(vec) {
    tail
  } else {
    let node = ref(root)
    let level = ref(shift)
    while level.contents > 0 {
      let subIdx = idx->lsr(level.contents)->land(bitMask)
      node := Tree.getNode(node.contents, subIdx)
      level := level.contents - numBits
    }

    switch node.contents {
    | Node(_) => @coverage(off) absurd
    | Leaf(ar) => ar
    }
  }
}

let rec popTail = (~size, ~level, parent) =>
  if level > 0 {
    let subIdx = (size - 2)->lsr(level)->land(bitMask)
    switch parent {
    | Node(ar) =>
      switch popTail(~size, ~level=level - numBits, A.get(ar, subIdx)) {
      | Some(child) =>
        // copy and replace
        let newAr = ar->A.copy
        A.set(newAr, subIdx, child)
        Some(Node(newAr))
      | None =>
        if subIdx == 0 {
          None
        } else {
          // copy and remove
          let newAr = ar->A.slice(~offset=0, ~len=A.length(ar) - 1)
          Some(Node(newAr))
        }
      }
    | Leaf(_) => @coverage(off) absurd
    }
  } else {
    None
  }

/**
 * pop will keep tail non-empty to make array access faster
 * return empty if vector is empty
 */
let pop = ({size, shift, root, tail} as vec) =>
  if size <= 1 {
    make()
  } else if tail->A.length > 1 {
    // case 1: tail has more than 1 elements
    let newTail = tail->A.slice(~offset=0, ~len=A.length(tail) - 1)
    {...vec, size: size - 1, tail: newTail}
  } else {
    // case 2 & 3: tail leaf has an only child
    let newTail = getArrayUnsafe(vec, size - 2)
    let newRoot = switch popTail(~size, ~level=shift, root) {
    | Some(nr) => nr
    | None => Node([]) // root must be consist of at least 1 Node
    }

    switch newRoot {
    | Node(ar) =>
      let isRootUnderflow = shift > numBits && ar->A.length == 1
      isRootUnderflow
        ? {shift: shift - numBits, size: size - 1, root: A.get(ar, 0), tail: newTail}
        : {...vec, size: size - 1, root: newRoot, tail: newTail}
    | Leaf(_) => @coverage(off) absurd
    }
  }

let getUnsafe = (vec, i) => A.get(getArrayUnsafe(vec, i), i->land(bitMask))

let get = ({size} as v, i) => i < 0 || i >= size ? None : Some(getUnsafe(v, i))

let getExn = ({size} as v, i) => {
  assert (i >= 0 && i < size)
  getUnsafe(v, i)
}

/**
 * Replace i'th index with x and copy the path down to x.
 * Made tp non-closure function for performance reason. (see #5)
 */
let rec updatedPath = (node, ~level, i, x) =>
  switch node {
  | Node(ar) =>
    let subIdx = i->lsr(level)->land(bitMask)
    let m = A.copy(ar)
    A.set(m, subIdx, updatedPath(A.get(ar, subIdx), ~level=level - numBits, i, x))
    Node(m)
  | Leaf(ar) =>
    let m = A.copy(ar)
    A.set(m, mod(i, numBranches), x)
    Leaf(m)
  }

let setUnsafe = ({shift, root, tail} as vec, i, x) => {
  let offset = tailOffset(vec)
  if i >= offset {
    let newTail = tail->A.copy
    A.set(newTail, i->land(bitMask), x)
    {...vec, tail: newTail}
  } else {
    {...vec, root: updatedPath(root, ~level=shift, i, x)}
  }
}

let set = ({size} as vec, i, x) => i < 0 || i >= size ? None : Some(setUnsafe(vec, i, x))

let setExn = ({size} as vec, i, x) => {
  assert (i >= 0 && i < size)
  setUnsafe(vec, i, x)
}

/**
 * split input array into chunks (of numBranches) then push into vector as leaves
 */
let fromArray = ar => {
  let len = A.length(ar)
  if len == 0 {
    make()
  } else {
    let tailSize = len->land(bitMask) == 0 ? numBranches : len->land(bitMask)
    let tailOffset = len - tailSize
    let tail = A.slice(ar, ~offset=tailOffset, ~len=tailSize)

    // unroll reduce
    let i = ref(0)
    let state = ref({...make(), size: tailSize, tail: tail})
    while i.contents < tailOffset {
      let offset = i.contents
      let {shift, size, root} as vec = state.contents

      let leaf = Leaf(A.slice(ar, ~offset, ~len=numBranches))
      let isRootOverflow = offset == lsl(1, shift + numBits)
      state := if isRootOverflow {
          let newRoot = Node([root, newPath(~level=shift, leaf)])
          {...vec, size: size + numBranches, shift: shift + numBits, root: newRoot}
        } else {
          // size must be greater than 0
          let newRoot = pushTail(~size=offset + 1, ~level=shift, root, leaf)
          {...vec, size: size + numBranches, root: newRoot}
        }

      i := offset + numBranches
    }
    state.contents
  }
}

let toArray = ({size, root, tail}) => {
  let data = A.make(size)
  let idx = ref(0)
  let rec fromTree = node =>
    switch node {
    | Node(ar) => A.forEach(ar, fromTree)
    | Leaf(ar) =>
      let len = ar->A.length
      A.blit(~src=ar, ~srcOffset=0, ~dst=data, ~dstOffset=idx.contents, ~len)
      idx := idx.contents + len
    }
  fromTree(root)
  // from Tail
  A.blit(~src=tail, ~srcOffset=0, ~dst=data, ~dstOffset=idx.contents, ~len=tail->A.length)
  data
}

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

let mapU = (vec, f) => reduceU(vec, make(), (. res, v) => push(res, f(. v)))

let map = (vec, f) => mapU(vec, (. v) => f(v))

let keepU = (vec, f) => reduceU(vec, make(), (. res, v) => f(. v) ? push(res, v) : res)

let keep = (vec, f) => keepU(vec, (. x) => f(x))

let keepMapU = (vec, f) =>
  reduceU(vec, make(), (. acc, v) => {
    switch f(. v) {
    | Some(v) => push(acc, v)
    | None => acc
    }
  })

let keepMap = (vec, f) => keepMapU(vec, (. v) => f(v))

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
