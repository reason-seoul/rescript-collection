open Belt;

let numBranches = 2;

type node('a) =
  | Inner(array(node('a)))
  | Leaf(array('a));

module Node = {
  let hasRoom = node => {
    switch (node) {
    | Inner(ar) => ar->Array.length < numBranches
    | Leaf(ar) => ar->Array.length < numBranches
    };
  };

  let lastChild = node => {
    switch (node) {
    | Inner(n) => n->Garter_Array.lastUnsafe
    | Leaf(_) => assert(false)
    };
  };

  let makeEmptyInner = () => {
    Inner(Array.makeUninitializedUnsafe(numBranches));
  };

  let makeEmptyLeaf = () => {
    Leaf(Array.makeUninitializedUnsafe(numBranches));
  };

  let makeInner = x => {
    let ar = Array.makeUninitializedUnsafe(numBranches);
    ar->Array.setUnsafe(0, x);
    Inner(ar);
  };
  let makeLeaf = x => {
    let ar = Array.makeUninitializedUnsafe(numBranches);
    ar->Array.setUnsafe(0, x);
    Leaf(ar);
  };
};

type t('a) = {
  size: int,
  depth: int,
  root: node('a),
};

let make = () => {size: 0, depth: 1, root: Node.makeEmptyLeaf()};

/**
 * Path from root to i'th leaf
 */
let rec getPath = (i, ~depth) =>
  if (depth == 0) {
    [i];
  } else {
    let denom = Js.Math.pow_int(~base=numBranches, ~exp=depth);
    Js.log("denom: " ++ Belt.Int.toString(denom));
    getPath(i mod denom, ~depth=depth - 1)->Belt.List.add(i / denom);
  };

let getUnsafe = ({depth, root}, i) => {
  let path = getPath(i, ~depth=depth - 1);
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
    let path = getPath(i, ~depth=depth - 1);

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

// getPath(1, 2)->Js.log;

let getLastLeaf = ({root}) => {
  let rec traverse = node => {
    switch (node) {
    | Inner(n) => traverse(n->Array.getUnsafe(n->Array.length - 1))
    | Leaf(_) => node
    };
  };
  traverse(root);
};

let isMaxed = ({size, depth}) =>
  size === Js.Math.pow_int(~base=numBranches, ~exp=depth);

/**
 * 3가지 경우를 고려해야 함.
 * 1. 가장 오른쪽 노드에 공간이 있을 때
 * 2. 루트 노드에는 공간이 있지만 가장 오른쪽 노드에는 공간이 없을 때
 * 3. 현재 루트 노드에 공간이 없을 때
 */
let push: (t('a), 'a) => t('a) =
  ({size, depth, root} as vec, x) =>
    // case 1
    if (getLastLeaf(vec)->Node.hasRoom) {
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
      // case 2: all leaf nodes are full but we have room for a new inner node.
      //  - 1. inner가 꽉 찼으면 제일 오른쪽 타고 감
      //  - 2. 안찼으면 노드 만들고 거기를 타고 감 (depth-1 도달했으면 leaf 만들고, 도달 안했으면 inner 만들고)
      let rec traverse = (node, height) => {
        // if (!node->hasRoom) {
        //   node->lastChild
        // } else {
        // }
        switch (node) {
        | Inner(ar) =>
          if (!node->Node.hasRoom) {
            let last = ar->Garter_Array.lastUnsafe;
            let newAr = ar->Array.copy;
            newAr->Array.setUnsafe(
              ar->Array.length - 1,
              traverse(last, height - 1),
            );
            Inner(newAr);
          } else if (height === 1) {
            let newAr = ar->Array.copy;
            newAr->Array.setUnsafe(ar->Array.length, Node.makeLeaf(x));
            Inner(newAr);
          } else {
            let newAr = ar->Array.copy;
            newAr->Array.setUnsafe(
              ar->Array.length,
              traverse(Node.makeEmptyInner(), height - 1),
            );
            Inner(newAr);
          }
        | Leaf(_) => assert(false)
        };
      };

      if (!isMaxed(vec)) {
        let newRoot = traverse(root, depth - 1);
        {...vec, size: size + 1, root: newRoot};
      } else {
        // case 3: when there's no room to append
        let newRoot = traverse(Node.makeInner(root), depth);
        {size: size + 1, depth: depth + 1, root: newRoot};
      };
    };

let pop: t('a) => option(t('a)) =
  vec => {
    Some(vec);
  };
