// implementation of a persistent bit-partitioned vector trie.

module A = Belt.Array

// Belt.Array.slice does element-wise operation for no reason.
// It's only better than Js.Array2.slice in its argument design.
let aslice = (ar, ~offset, ~len) => Js.Array2.slice(ar, ~start=offset, ~end_=offset + len)

// Belt.Array.copy uses Belt.Array.slice internally.
// The fastest way to copy one array to another is using Js.Array2.copy
let acopy = Js.Array2.copy

let numBits = 5
let numBranches = lsl(1, numBits)
let bitMask = numBranches - 1

type rec tree<'a> =
  | Node(array<tree<'a>>)
  | Leaf(array<'a>)

module Tree = {
  let clone = x =>
    switch x {
    | Node(ar) => Node(ar->acopy)
    | Leaf(ar) => Leaf(ar->acopy)
    }

  let setNode = (node, idx, v) =>
    switch node {
    | Node(ar) => ar->A.setUnsafe(idx, v)
    | Leaf(_) => assert false
    }

  let getNode = (node, idx) => {
    switch node {
    | Node(ar) => ar->A.getUnsafe(idx)
    | Leaf(_) => assert false
    }
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
let rec newPath = (~level, node: tree<'a>): tree<'a> =>
  if level == 0 {
    node
  } else {
    newPath(~level=level - numBits, Node([node]))
  }

let rec pushTail = (~size, ~level, parent, tail) => {
  let ret = Tree.clone(parent)
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
          ? pushTail(~size, ~level=level - numBits, ar[subIdx], tail)
          : newPath(~level=level - numBits, tail)
      Tree.setNode(ret, subIdx, newChild)
      ret
    | Leaf(_) => assert false
    }
  }
}

let push = ({size, shift, root, tail} as vec, x) =>
  // case 1: when tail has room to append
  if tail->A.length < numBranches {
    // copy and append
    let newTail = tail->acopy
    newTail->A.setUnsafe(tail->A.length, x)

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
    let rec traverse = (node, ~level) =>
      if level == 0 {
        node
      } else {
        let subIdx = idx->lsr(level)->land(bitMask)
        traverse(Tree.getNode(node, subIdx), ~level=level - numBits)
      }

    switch traverse(root, ~level=shift) {
    | Node(_) => assert false
    | Leaf(ar) => ar
    }
  }
}

let rec popTail = (~size, ~level, parent) =>
  if level > numBits {
    let subIdx = (size - 2)->lsr(level)->land(bitMask)
    switch parent {
    | Node(ar) =>
      switch popTail(~size, ~level=level - numBits, ar[subIdx]) {
      | Some(child) =>
        // copy and replace
        let newAr = ar->acopy
        newAr->A.setUnsafe(subIdx, child)
        Some(Node(newAr))
      | None =>
        if subIdx == 0 {
          None
        } else {
          // copy and remove
          let newAr = ar->aslice(~offset=0, ~len=A.length(ar) - 1)
          Some(Node(newAr))
        }
      }
    | Leaf(_) => assert false
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
    let newTail = tail->aslice(~offset=0, ~len=A.length(tail) - 1)
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
        ? {shift: shift - numBits, size: size - 1, root: ar[0], tail: newTail}
        : {...vec, size: size - 1, root: newRoot, tail: newTail}
    | Leaf(_) => assert false
    }
  }

let getExn = (vec, i) => getArrayUnsafe(vec, i)[i->land(bitMask)]

let get = ({size} as v, i) => i < 0 || i >= size ? None : Some(getExn(v, i))

let setExn = ({shift, root, tail} as vec, i, x) => {
  let offset = tailOffset(vec)
  if i >= offset {
    let newTail = tail->acopy
    newTail->A.setUnsafe(i->land(bitMask), x)
    {...vec, tail: newTail}
  } else {
    let rec traverse = (node, ~level) => {
      switch node {
      | Node(ar) =>
        let subIdx = i->lsr(level)->land(bitMask)
        let m = acopy(ar)
        m->A.setUnsafe(subIdx, traverse(ar[subIdx], ~level=level - numBits))
        Node(m)

      | Leaf(ar) =>
        let m = acopy(ar)
        m->A.setUnsafe(mod(i, numBranches), x)
        Leaf(m)
      }
    }

    {...vec, root: traverse(root, ~level=shift)}
  }
}

let set = ({size} as vec, i, x) => i < 0 || i >= size ? None : Some(setExn(vec, i, x))

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
    let tail = aslice(ar, ~offset=tailOffset, ~len=tailSize)

    A.rangeBy(0, tailOffset - 1, ~step=numBranches)->A.reduce(
      {...make(), size: tailSize, tail: tail},
      ({shift, size, root} as vec, offset) => {
        let leaf = Leaf(aslice(ar, ~offset, ~len=numBranches))
        let isRootOverflow = offset == lsl(1, shift + numBits)
        if isRootOverflow {
          let newRoot = Node([root, newPath(~level=shift, leaf)])
          {...vec, size: size + numBranches, shift: shift + numBits, root: newRoot}
        } else {
          // size must be greater than 0
          let newRoot = pushTail(~size=offset + 1, ~level=shift, root, leaf)
          {...vec, size: size + numBranches, root: newRoot}
        }
      },
    )
  }
}

let toArray = ({size, root, tail}) => {
  let data = Belt.Array.makeUninitializedUnsafe(size)
  let idx = ref(0)
  let rec fromTree = node =>
    switch node {
    | Node(ar) => ar->A.forEach(fromTree)
    | Leaf(ar) =>
      let len = ar->A.length
      A.blitUnsafe(~src=ar, ~srcOffset=0, ~dst=data, ~dstOffset=idx.contents, ~len)
      idx := idx.contents + len
    }
  fromTree(root)
  // from Tail
  A.blitUnsafe(~src=tail, ~srcOffset=0, ~dst=data, ~dstOffset=idx.contents, ~len=tail->A.length)
  data
}

let doWithArray = (vec, f) => vec->toArray->f->fromArray

let map = (vec, f) => vec->doWithArray(A.map(_, f))

let keep = (vec, f) => vec->doWithArray(A.keep(_, f))

let reduce = (vec, init, f) => vec->toArray->A.reduce(init, f)

let debug = ({root}) => {
  let rec traverse = (node, depth) =>
    switch node {
    | Node(ar) =>
      Js.log("I " ++ depth->string_of_int)
      A.forEach(ar, n => traverse(n, depth + 1))
    | Leaf(ar) =>
      Js.log("L " ++ depth->string_of_int)
      A.forEach(ar, n => Js.log(n))
    }
  traverse(root, 1)
}
