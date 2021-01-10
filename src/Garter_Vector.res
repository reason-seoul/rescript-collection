module A = Belt.Array

let numBranches = 2

// optimize away inner/leaf distinction
type rec tree<'a> =
  | Node(array<tree<'a>>)
  | Leaf(array<'a>)

module Tree = {
  let makeNode = x => Node(A.make(1, x))
  let makeNode2 = (x, y) => {
    let ar = A.makeUninitializedUnsafe(2)
    ar->A.setUnsafe(0, x)
    ar->A.setUnsafe(1, y)
    Node(ar)
  }

  let clone = x =>
    switch x {
    | Node(ar) => Node(ar->A.copy)
    | Leaf(ar) => Leaf(ar->A.copy)
    }

  let setNode = (node, idx, v) =>
    switch node {
    | Node(ar) => ar->A.setUnsafe(idx, v)
    | Leaf(_) => assert false
    }
}

type t<'a> = {
  size: int,
  depth: int,
  root: tree<'a>,
  tail: array<'a>,
}

let make = () => {size: 0, depth: 1, root: Node([]), tail: []}

let length = v => v.size

// TODO: optimize with LUT
let pow = (~base, ~exp) =>
  Js.Math.pow_float(~base=base->float_of_int, ~exp=exp->float_of_int)->int_of_float

/**
 Path from root to i'th leaf
 */
let rec getPathIdx = (i, ~depth) =>
  if depth == 0 {
    list{}
  } else {
    let denom = pow(~base=numBranches, ~exp=depth)
    getPathIdx(mod(i, denom), ~depth=depth - 1)->Belt.List.add(i / denom)
  }

let push = ({size, depth, root, tail} as vec, x) =>
  // case 1: when tail has room to append
  if tail->A.length < numBranches {
    // Js.log2("[push: case1]", x)

    // copy and append
    let newTail = tail->A.copy
    newTail->A.setUnsafe(tail->A.length, x)

    {...vec, size: size + 1, tail: newTail}
  } else {
    // case 2 & 3
    // b^(depth+1) + b
    let isRootOverflow = size == pow(~base=numBranches, ~exp=depth + 1) + numBranches
    let rec newPath = (depth, node) => depth == 0 ? node : newPath(depth - 1, Tree.makeNode(node))

    if isRootOverflow {
      // case 3: when there's no room to append
      // Js.log2("[push: case3]", x)
      let newRoot = Tree.makeNode2(root, newPath(depth, Leaf(tail)))
      {size: size + 1, depth: depth + 1, root: newRoot, tail: [x]}
    } else {
      // case 2: all leaf nodes are full but we have room for a new inner node.
      // Js.log2("[push: case2]", x)
      let rec pushTail = (depth, parent, path) => {
        let ret = Tree.clone(parent)
        let subIdx = Belt.List.headExn(path)
        if depth == 1 {
          // array will be grown by out of index access. optimize?
          Tree.setNode(ret, subIdx, Leaf(tail))
          ret
        } else {
          switch parent {
          | Node(ar) =>
            let newChild =
              subIdx < ar->A.length
                ? pushTail(depth - 1, ar[subIdx], Belt.List.tailExn(path))
                : newPath(depth - 1, Leaf(tail))
            Tree.setNode(ret, subIdx, newChild)
            ret
          | Leaf(_) => assert false
          }
        }
      }

      let tailOffset = size - tail->A.length
      let path = getPathIdx(tailOffset, ~depth)
      // Js.log4("push tail", tail, "new tail", [x])
      // Js.log2("path", path->Belt.List.toArray)
      let newRoot = pushTail(depth, root, path)
      {...vec, size: size + 1, root: newRoot, tail: [x]}
    }
  }

let peek = ({tail}) => tail->A.get(A.length(tail) - 1)

let getArrayUnsafe = ({size, depth, root, tail}, idx) => {
  let tailOffset = size - tail->A.length
  if idx >= tailOffset {
    tail
  } else {
    let rec traverse = (parent, path) =>
      switch path {
      | list{} => parent
      | list{subIdx, ...path} =>
        switch parent {
        | Node(ar) => traverse(ar[subIdx], path)
        | Leaf(_) => assert false
        }
      }
    let path = getPathIdx(idx, ~depth)
    switch traverse(root, path) {
    | Node(_) => assert false
    | Leaf(ar) => ar
    }
  }
}

/**
 * pop will keep tail non-empty to make array access faster
 */
let pop = ({size, depth, root, tail} as vec) =>
  if size == 1 {
    make()
  } else if tail->A.length > 1 {
    // case 1: tail has more than 1 elements
    // Js.log2("[pop case1]", peek(vec))
    let newTail = tail->A.slice(~offset=0, ~len=A.length(tail) - 1)
    {...vec, size: size - 1, tail: newTail}
  } else {
    // case 2 & 3: tail leaf has an only child
    // Js.log2("[pop case2&3]", peek(vec))
    let rec popTail = (depth, parent, path) => {
      switch path {
      | list{} => None
      | list{subIdx, ...path} =>
        switch parent {
        | Node(ar) =>
          switch popTail(depth - 1, ar[subIdx], path) {
          | Some(child) =>
            // copy and replace
            let newAr = ar->A.copy
            newAr->A.setUnsafe(subIdx, child)
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
        | Leaf(_) => assert false
        }
      }
    }

    let path = getPathIdx(size - 2, ~depth)
    let newTail = getArrayUnsafe(vec, size - 2)
    // Js.log2("new tail", newTail)
    let newRoot = switch popTail(depth, root, path) {
    | Some(nr) => nr
    | None => Node([]) // root must be consist of at least 1 Node
    }

    switch newRoot {
    | Node(ar) =>
      let isRootUnderflow = depth > 1 && ar->A.length == 1
      isRootUnderflow
        ? {depth: depth - 1, size: size - 1, root: ar[0], tail: newTail}
        : {...vec, size: size - 1, root: newRoot, tail: newTail}
    | Leaf(_) => assert false
    }
  }

// accessors

let getExn = ({depth, root}, i) => {
  let path = getPathIdx(i, ~depth)
  let rec traverse = (path, node) => {
    let index = path->Belt.List.headExn
    switch node {
    | Node(n) => traverse(path->Belt.List.tailExn, n[index])
    | Leaf(n) => n[index]
    }
  }
  traverse(path, root)
}

let get = ({size} as v, i) => i < 0 || i >= size ? None : Some(getExn(v, i))

let setExn = ({depth, root} as vec, i, x) => {
  let rec traverse = (path, node) => {
    let index = path->Belt.List.headExn
    switch node {
    | Node(ar) =>
      let m = A.copy(ar)
      m->A.setUnsafe(index, traverse(path->Belt.List.tailExn, ar[index]))
      Node(m)

    | Leaf(ar) =>
      let m = A.copy(ar)
      m->A.setUnsafe(index, x)
      Leaf(m)
    }
  }

  let path = getPathIdx(i, ~depth)
  {...vec, root: traverse(path, root)}
}

let set = ({size} as vec, i, x) => i < 0 || i >= size ? None : Some(setExn(vec, i, x))

let fromArray = ar => A.reduce(ar, make(), (v, i) => push(v, i))

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
