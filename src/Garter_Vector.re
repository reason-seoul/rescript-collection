open Belt;

let numBranches = 32;

// optimize away inner/leaf distinction
type node('a) =
  | Inner(array(node('a)))
  | Leaf(array('a));

module Node = {
  let isInner =
    fun
    | Inner(_) => true
    | Leaf(_) => false;

  let hasRoom = node => {
    switch (node) {
    | Inner(ar) => ar->Array.length < numBranches
    | Leaf(ar) => ar->Array.length < numBranches
    };
  };

  let hasSiblings = node => {
    switch (node) {
    | Inner(ar) => ar->Array.length > 1
    | Leaf(ar) => ar->Array.length > 1
    };
  };

  // let lastChild = node => {
  //   switch (node) {
  //   | Inner(n) => n->Garter_Array.lastUnsafe
  //   | Leaf(_) => assert(false)
  //   };
  // };

  let makeEmptyLeaf = () => {
    Leaf([||]);
  };

  let makeInner = x => Inner(Array.make(1, x));
  let makeInner2 = (x, y) => {
    let ar = Array.makeUninitializedUnsafe(2);
    ar->Array.setUnsafe(0, x);
    ar->Array.setUnsafe(1, y);
    Inner(ar);
  };

  let makeLeaf = x => Leaf(Array.make(1, x));

  let clone =
    fun
    | Inner(ar) => Inner(ar->Array.copy)
    | Leaf(ar) => Leaf(ar->Array.copy);

  let setInner = (node, idx, v) => {
    switch (node) {
    | Inner(ar) => ar->Array.setUnsafe(idx, v)
    | Leaf(_) => assert(false)
    };
  };

  let getInner = (node, idx) => {
    switch (node) {
    | Inner(ar) => ar->Array.getUnsafe(idx)
    | Leaf(_) => assert(false)
    };
  };
};

type t('a) = {
  size: int,
  depth: int,
  root: node('a),
};

let make = () => {size: 0, depth: 1, root: Node.makeEmptyLeaf()};

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

let getUnsafe = ({depth, root}, i) => {
  let path = getPathIdx(i, ~depth);
  let rec traverse = (path, node) => {
    let index = path->Belt.List.headExn;
    switch (node) {
    | Inner(n) => traverse(path->List.tailExn, n->Array.getUnsafe(index))
    | Leaf(n) => n->Array.getUnsafe(index)
    };
  };
  traverse(path, root);
};

let get = ({size} as v, i) =>
  if (i < 0 || i >= size) {
    None;
  } else {
    Some(getUnsafe(v, i));
  };

let setUnsafe: (t('a), int, 'a) => t('a) =
  ({depth, root} as vec, i, x) => {
    let path = getPathIdx(i, ~depth);

    let rec traverse = (path, node) => {
      let index = path->Belt.List.headExn;
      switch (node) {
      | Inner(n) =>
        let m = Array.copy(n);
        m->Array.setUnsafe(
          index,
          traverse(path->List.tailExn, n->Array.getUnsafe(index)),
        );
        Inner(m);

      | Leaf(n) =>
        let m = Array.copy(n);
        m->Array.setUnsafe(index, x);
        Leaf(m);
      };
    };

    {...vec, root: traverse(path, root)};
  };

let getTail = ({size, depth, root}) => {
  let rec traverse = (path, node) => {
    let subIdx = path->List.headExn;
    switch (node) {
    | Inner(n) => traverse(path->List.tailExn, n->Array.getUnsafe(subIdx))
    | Leaf(_) => node
    };
  };
  let path = getPathIdx(size - 1, ~depth);
  traverse(path, root);
};

/**
 * 3가지 경우를 고려해야 함.
 * 1. 가장 오른쪽 노드에 공간이 있을 때
 * 2. 루트 노드에는 공간이 있지만 가장 오른쪽 노드에는 공간이 없을 때
 * 3. 현재 루트 노드에 공간이 없을 때
 */

let logging = ref(false);
let log = x =>
  if (logging^) {
    Js.Console.info(x);
  };

let log2 = (x, y) =>
  if (logging^) {
    Js.Console.info2(x, y);
  };

let push: (t('a), 'a) => t('a) =
  ({size, depth, root} as vec, x) =>
    // case 1
    if (getTail(vec)->Node.hasRoom) {
      // log2("[push: case1]", x);
      let rec traverse = node => {
        switch (node) {
        | Inner(ar) =>
          let newAr = ar->Array.copy;
          newAr->Array.setUnsafe(
            ar->Array.length - 1,
            traverse(ar->Garter_Array.lastUnsafe),
          );
          Inner(newAr);

        | Leaf(ar) =>
          let newAr = ar->Array.copy;
          newAr->Array.setUnsafe(ar->Array.length, x);
          Leaf(newAr);
        };
      };
      let newRoot = traverse(root);
      {...vec, size: size + 1, root: newRoot};
    } else {
      // case 2 & 3
      let isRootOverflow = size == pow(~base=numBranches, ~exp=depth);
      let rec newPath = (depth, node) =>
        depth == 0 ? node : newPath(depth - 1, Node.makeInner(node));

      if (isRootOverflow) {
        // case 3: when there's no room to append
        // log2("[push: case3]", x);
        let newRoot =
          Node.makeInner2(root, newPath(depth - 1, Node.makeLeaf(x)));

        {size: size + 1, depth: depth + 1, root: newRoot};
      } else {
        // case 2: all leaf nodes are full but we have room for a new inner node.
        // log2("[push: case2]", x);
        let rec pushTail = (depth, parent, path) => {
          let ret = Node.clone(parent);
          let subIdx = List.headExn(path);
          if (depth == 2) {
            Node.setInner(ret, subIdx, Node.makeLeaf(x));
            ret;
          } else {
            switch (parent) {
            | Inner(ar) =>
              let newChild =
                if (subIdx < ar->Array.length) {
                  let child = ar->Array.getUnsafe(subIdx);
                  pushTail(depth - 1, child, List.tailExn(path));
                } else {
                  newPath(depth - 2, Node.makeLeaf(x));
                };

              Node.setInner(ret, subIdx, newChild);
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
  | Leaf(ar) => ar[Array.length(ar) - 1]
  | Inner(_) => assert(false)
  };
};

let pop: t('a) => t('a) =
  ({size, depth, root} as vec) =>
    if (getTail(vec)->Node.hasSiblings) {
      // case 1: tail leaf has more than 1 nodes
      log2("[pop case1]", peek(vec));
      let rec traverse = node => {
        switch (node) {
        | Inner(ar) =>
          let newAr = ar->Array.copy;
          newAr->Array.setUnsafe(
            ar->Array.length - 1,
            traverse(ar->Garter_Array.lastUnsafe),
          );
          Inner(newAr);

        | Leaf(ar) =>
          let newAr = ar->Array.slice(~offset=0, ~len=Array.length(ar) - 1);
          Leaf(newAr);
        };
      };
      let newRoot = traverse(root);
      {...vec, size: size - 1, root: newRoot};
    } else {
      // case 2 & 3: tail leaf has an only child
      log2("[pop case2&3]", peek(vec));
      let rec popTail = (parent, path) => {
        let subIdx = path->List.headExn;
        switch (parent) {
        | Inner(ar) =>
          switch (popTail(ar->Array.getUnsafe(subIdx), path->List.tailExn)) {
          | Some(child) =>
            // copy and replace
            let ret = Node.clone(parent);
            ret->Node.setInner(subIdx, child);
            Some(ret);
          | None when subIdx == 0 =>
            // remove
            None
          | _ =>
            // copy and remove
            let newAr =
              ar->Array.slice(~offset=0, ~len=Array.length(ar) - 1);
            Some(Inner(newAr));
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
        | Inner(ar) when !newRoot->Node.hasSiblings =>
          // case 3: root has only 1 inner node
          let firstChild = ar->Array.getUnsafe(0);
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

let fromArray = ar => {
  Belt.Array.reduce(ar, make(), (v, i) => push(v, i));
};

let toArray = ({root}) => {
  let data = [||];
  let rec traverse = node => {
    switch (node) {
    | Inner(ar) => ar->Array.forEach(traverse)
    | Leaf(ar) => data->Js.Array2.pushMany(ar)->ignore
    };
  };
  traverse(root);
  data;
};

let toString = toArray;

let debug = ({root}) => {
  let rec traverse = (node, depth) => {
    switch (node) {
    | Inner(ar) =>
      Js.log("I " ++ depth->string_of_int);
      Belt.Array.forEach(ar, n => traverse(n, depth + 1));
    | Leaf(ar) =>
      Js.log("L " ++ depth->string_of_int);
      Belt.Array.forEach(ar, n => Js.log(n));
    };
  };
  traverse(root, 1);
};
