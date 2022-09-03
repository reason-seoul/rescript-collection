// implementation of a persistent bit-partitioned vector trie.

module A = JsArray

// to handle the impossible case without throwing an exception
let absurd = Obj.magic()

// Test various branching factors using this formula.
// @bs.inline doesn't work for this kind of assignment.
//  numBits := n
//  numBranches := lsl(1, numBits)
//  bitMask := numBranches - 1
// let numBits = 2
// let numBranches = lsl(1, numBits)
// let bitMask = numBranches - 1
@inline
let numBits = 5
@inline
let numBranches = 32
@inline
let bitMask = 0x1f

type rec tree<'a> =
  | Node(array<tree<'a>>)
  | Leaf(array<'a>)

module Tree = {
  let cloneAndSetNode = (node, idx, v) =>
    switch node {
    | Node(ar) => Node(ar->A.cloneAndSet(idx, v))
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
  let subIdx = (size - 1)->lsr(level)->land(bitMask)
  if level == numBits {
    Tree.cloneAndSetNode(parent, subIdx, tail)
  } else {
    switch parent {
    | Node(ar) =>
      let newChild =
        subIdx < ar->A.length
          ? pushTail(~size, ~level=level - numBits, A.get(ar, subIdx), tail)
          : newPath(~level=level - numBits, tail)
      Tree.cloneAndSetNode(parent, subIdx, newChild)
    | Leaf(_) => @coverage(off) absurd
    }
  }
}

let push = ({size, shift, root, tail} as vec, x) =>
  // case 1: when tail has room to append
  if tail->A.length < numBranches {
    // copy and append
    let newTail = tail->A.cloneAndAdd(x)

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

/**
 * idx must be within bound
 */
let getLeafUnsafe = ({root, shift, tail} as vec, idx) => {
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
        let newAr = ar->A.cloneAndSet(subIdx, child)
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
    let newTail = getLeafUnsafe(vec, size - 2)
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

let getUnsafe = (vec, i) => A.get(getLeafUnsafe(vec, i), i->land(bitMask))

/**
 * Replace i'th index with x and copy the path down to x.
 * Made tp non-closure function for performance reason. (see #5)
 */
let rec updatedPath = (node, ~level, i, x) =>
  switch node {
  | Node(ar) =>
    let subIdx = i->lsr(level)->land(bitMask)
    let m = A.cloneAndSet(ar, subIdx, updatedPath(A.get(ar, subIdx), ~level=level - numBits, i, x))
    Node(m)
  | Leaf(ar) =>
    let m = A.cloneAndSet(ar, mod(i, numBranches), x)
    Leaf(m)
  }

let setUnsafe = ({shift, root, tail} as vec, i, x) => {
  let offset = tailOffset(vec)
  if i >= offset {
    let newTail = A.cloneAndSet(tail, i->land(bitMask), x)
    {...vec, tail: newTail}
  } else {
    {...vec, root: updatedPath(root, ~level=shift, i, x)}
  }
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
    let state = ref({...make(), size: tailSize, tail})
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

let makeByU = (len, f) => {
  if len == 0 {
    make()
  } else {
    let tailSize = len->land(bitMask) == 0 ? numBranches : len->land(bitMask)
    let tailOffset = len - tailSize
    let tail = A.make(tailSize)

    // unroll reduce
    let i = ref(0)
    let state = ref({...make(), size: tailSize, tail})
    while i.contents < tailOffset {
      let offset = i.contents
      let {shift, size, root} as vec = state.contents

      let ar = A.make(numBranches)
      for j in 0 to numBranches - 1 {
        A.set(ar, j, f(. offset + j))
      }
      let leaf = Leaf(ar)
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

    for j in 0 to tailSize - 1 {
      A.set(tail, j, f(. tailOffset + j))
    }

    state.contents
  }
}

// module Transient = {
//   type tr<'a> = {
//     mutable size: int,
//     mutable shift: int,
//     mutable root: tree<'a>,
//     mutable tail: array<'a>,
//   }

//   let make = (v: t<'a>): tr<'a> => {
//     size: v.size,
//     shift: v.shift,
//     root: v.root,
//     tail: v.tail,
//   }

//   let toPersistent = (v): t<'a> => {
//     size: v.size,
//     shift: v.shift,
//     root: v.root,
//     tail: v.tail,
//   }

//   let push = (_v, _x) => {
//     failwith("not implemented yet")
//   }
// }
