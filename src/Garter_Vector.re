module A = Belt.Array;

let numBranches = 32;

// optimize away inner/leaf distinction
type tree('a) =
  | Node(array(tree('a)))
  | Leaf(array('a));

module Tree = {
  let hasRoom = node => {
    switch (node) {
    | Node(ar) => ar->A.length < numBranches
    | Leaf(ar) => ar->A.length < numBranches
    };
  };

  let hasSiblings = node => {
    switch (node) {
    | Node(ar) => ar->A.length > 1
    | Leaf(ar) => ar->A.length > 1
    };
  };

  // let lastChild = node => {
  //   switch (node) {
  //   | Node(n) => n->A.lastUnsafe
  //   | Leaf(_) => assert(false)
  //   };
  // };

  let makeNode = x => Node(A.make(1, x));
  let makeNode2 = (x, y) => {
    let ar = A.makeUninitializedUnsafe(2);
    ar->A.setUnsafe(0, x);
    ar->A.setUnsafe(1, y);
    Node(ar);
  };

  let makeEmptyLeaf = () => Leaf([||]);
  let makeLeaf = x => Leaf(A.make(1, x));

  let clone =
    fun
    | Node(ar) => Node(ar->A.copy)
    | Leaf(ar) => Leaf(ar->A.copy);

  let setNode = (node, idx, v) => {
    switch (node) {
    | Node(ar) => ar->A.setUnsafe(idx, v)
    | Leaf(_) => assert(false)
    };
  };
  // let setLeaf = (node, idx, v) => {
  //   switch (node) {
  //   | Leaf(ar) => ar->A.setUnsafe(idx, v)
  //   | Node(_) => assert(false)
  //   };
  // };
  // let getNode = (node, idx) => {
  //   switch (node) {
  //   | Node(ar) => ar[idx]
  //   | Leaf(_) => assert(false)
  //   };
  // };
};

type t('a) = {
  size: int,
  depth: int,
  root: tree('a),
};

let make = () => {size: 0, depth: 1, root: Tree.makeEmptyLeaf()};

let length = v => v.size;

// TODO: optimize with LUT
let pow = (~base, ~exp) => {
  Js.Math.pow_float(~base=base->float_of_int, ~exp=exp->float_of_int)
  ->int_of_float;
};

/**
 * Path from root to i'th leaf
 */
let rec getPathIdx = (i, ~depth) =>
  if (depth == 1) {
    [i];
  } else {
    let denom = pow(~base=numBranches, ~exp=depth - 1);
    getPathIdx(i mod denom, ~depth=depth - 1)->Belt.List.add(i / denom);
  };

let getTail = ({size, depth, root}) => {
  let rec traverse = (path, node) => {
    let subIdx = path->Belt.List.headExn;
    switch (node) {
    | Node(ar) => traverse(path->Belt.List.tailExn, ar[subIdx])
    | Leaf(_) => node
    };
  };
  let path = getPathIdx(size - 1, ~depth);
  traverse(path, root);
};

let push: (t('a), 'a) => t('a) =
  ({size, depth, root} as vec, x) =>
    // case 1: when tail has room to append
    if (getTail(vec)->Tree.hasRoom) {
      // log2("[push: case1]", x);
      let rec traverse = node =>
        switch (node) {
        | Node(ar) =>
          // copy and replace last child
          let newAr = ar->A.copy;
          newAr->A.setUnsafe(
            ar->A.length - 1,
            traverse(ar->Garter_Array.lastUnsafe),
          );
          Node(newAr);
        | Leaf(ar) =>
          // copy and append
          let newAr = ar->A.copy;
          newAr->A.setUnsafe(ar->A.length, x);
          Leaf(newAr);
        };

      let newRoot = traverse(root);
      {...vec, size: size + 1, root: newRoot};
    } else {
      // case 2 & 3
      let isRootOverflow = size == pow(~base=numBranches, ~exp=depth);
      let rec newPath = (depth, node) =>
        depth == 0 ? node : newPath(depth - 1, Tree.makeNode(node));

      if (isRootOverflow) {
        // case 3: when there's no room to append
        // log2("[push: case3]", x);
        let newRoot =
          Tree.makeNode2(root, newPath(depth - 1, Tree.makeLeaf(x)));

        {size: size + 1, depth: depth + 1, root: newRoot};
      } else {
        // case 2: all leaf nodes are full but we have room for a new inner node.
        // log2("[push: case2]", x);
        let rec pushTail = (depth, parent, path) => {
          let ret = Tree.clone(parent);
          let subIdx = Belt.List.headExn(path);
          if (depth == 2) {
            Tree.setNode(ret, subIdx, Tree.makeLeaf(x));
            ret;
          } else {
            switch (parent) {
            | Node(ar) =>
              let newChild =
                if (subIdx < ar->A.length) {
                  let child = ar[subIdx];
                  pushTail(depth - 1, child, Belt.List.tailExn(path));
                } else {
                  newPath(depth - 2, Tree.makeLeaf(x));
                };

              Tree.setNode(ret, subIdx, newChild);
              ret;
            | Leaf(_) => assert(false)
            };
          };
        };

        let path = getPathIdx(size, ~depth);
        let newRoot = pushTail(depth, root, path);
        {...vec, size: size + 1, root: newRoot};
      };
    };

let peek = v => {
  switch (getTail(v)) {
  | Leaf(ar) => ar->A.get(A.length(ar) - 1)
  | Node(_) => assert(false)
  };
};

let pop: t('a) => t('a) =
  ({size, depth, root} as vec) =>
    if (getTail(vec)->Tree.hasSiblings) {
      // case 1: tail leaf has more than 1 nodes
      // log2("[pop case1]", peek(vec));
      let rec traverse = parent => {
        switch (parent) {
        | Node(ar) =>
          let newAr = ar->A.copy;
          newAr->A.setUnsafe(
            ar->A.length - 1,
            traverse(ar->Garter_Array.lastUnsafe),
          );
          Node(newAr);

        | Leaf(ar) =>
          let newAr = ar->A.slice(~offset=0, ~len=A.length(ar) - 1);
          Leaf(newAr);
        };
      };
      let newRoot = traverse(root);
      {...vec, size: size - 1, root: newRoot};
    } else {
      // case 2 & 3: tail leaf has an only child
      // log2("[pop case2&3]", peek(vec));
      let rec popTail = (parent, path) => {
        let subIdx = path->Belt.List.headExn;
        switch (parent) {
        | Node(ar) =>
          switch (popTail(ar[subIdx], path->Belt.List.tailExn)) {
          | Some(child) =>
            // copy and replace
            let newAr = ar->A.copy;
            newAr->A.setUnsafe(subIdx, child);
            Some(Node(newAr));
          | None when subIdx == 0 =>
            // remove
            None
          | _ =>
            // copy and remove
            let newAr = ar->A.slice(~offset=0, ~len=A.length(ar) - 1);
            Some(Node(newAr));
          }
        | Leaf(_) =>
          // can be merged with case 1)
          assert(subIdx == 0);
          None;
        };
      };

      let path = getPathIdx(size - 1, ~depth);
      switch (popTail(root, path)) {
      | Some(newRoot) =>
        switch (newRoot) {
        | Node(ar) when !newRoot->Tree.hasSiblings =>
          // case 3: root has only 1 inner node
          let firstChild = ar[0];
          // kill root
          {depth: depth - 1, size: size - 1, root: firstChild};
        | _ => {...vec, size: size - 1, root: newRoot}
        }
      | None =>
        // back to initial state
        assert(size == 1);
        make();
      };
    };

// accessors

let getExn = ({depth, root}, i) => {
  let path = getPathIdx(i, ~depth);
  let rec traverse = (path, node) => {
    let index = path->Belt.List.headExn;
    switch (node) {
    | Node(n) => traverse(path->Belt.List.tailExn, n[index])
    | Leaf(n) => n[index]
    };
  };
  traverse(path, root);
};

let get = ({size} as v, i) =>
  i < 0 || i >= size ? None : Some(getExn(v, i));

let setExn = ({depth, root} as vec, i, x) => {
  let rec traverse = (path, node) => {
    let index = path->Belt.List.headExn;
    switch (node) {
    | Node(ar) =>
      let m = A.copy(ar);
      m->A.setUnsafe(index, traverse(path->Belt.List.tailExn, ar[index]));
      Node(m);

    | Leaf(ar) =>
      let m = A.copy(ar);
      m->A.setUnsafe(index, x);
      Leaf(m);
    };
  };

  let path = getPathIdx(i, ~depth);
  {...vec, root: traverse(path, root)};
};

let set = ({size} as vec, i, x) =>
  i < 0 || i >= size ? None : Some(setExn(vec, i, x));

let fromArray = ar => {
  A.reduce(ar, make(), (v, i) => push(v, i));
};

let toArray = ({root}) => {
  let data = [||];
  let rec traverse = node => {
    switch (node) {
    | Node(ar) => ar->A.forEach(traverse)
    | Leaf(ar) => data->Js.Array2.pushMany(ar)->ignore
    };
  };
  traverse(root);
  data;
};

let doWithArray = (vec, f) => vec->toArray->f->fromArray;

let map = (vec, f) => vec->doWithArray(A.map(_, f));

let keep = (vec, f) => vec->doWithArray(A.keep(_, f));

let reduce = (vec, init, f) => vec->toArray->A.reduce(init, f);

let debug = ({root}) => {
  let rec traverse = (node, depth) => {
    switch (node) {
    | Node(ar) =>
      Js.log("I " ++ depth->string_of_int);
      A.forEach(ar, n => traverse(n, depth + 1));
    | Leaf(ar) =>
      Js.log("L " ++ depth->string_of_int);
      A.forEach(ar, n => Js.log(n));
    };
  };
  traverse(root, 1);
};
