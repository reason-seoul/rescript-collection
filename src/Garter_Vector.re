open Belt;

let numBranches = 2;

type node('a) =
  | Inner(array(node('a)))
  | Leaf(array('a));

let numChildren = n => {
  switch (n) {
  | Inner(ar) => ar->Array.length
  | Leaf(ar) => ar->Array.length
  };
};

module Node = {
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

  let makeEmptyInner = () => {
    Inner([||]);
  };

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
let rec getPath = (i, ~depth) =>
  if (depth == 0) {
    [i];
  } else {
    let denom = pow(~base=numBranches, ~exp=depth);
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

let getLastLeaf = ({root}) => {
  let rec traverse = node => {
    switch (node) {
    | Inner(n) => traverse(n->Array.getUnsafe(n->Array.length - 1))
    | Leaf(_) => node
    };
  };
  traverse(root);
};

let isRootOverflow = ({size, depth}) =>
  size == pow(~base=numBranches, ~exp=depth);

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
      // Js.Console.info("push: case1");
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
    } else if (!isRootOverflow(vec)) {
      // case 2: all leaf nodes are full but we have room for a new inner node.
      // Js.Console.info("push: case2");
      let rec traverse = (node, height) => {
        //  - 1. inner가 꽉 찼으면 제일 오른쪽 타고 감
        //  - 2. 안찼으면 노드 만들고 거기를 타고 감 (depth-1 도달했으면 leaf 만들고, 도달 안했으면 inner 만들고)
        switch (node) {
        | Inner(ar) =>
          if (height == 1) {
            Node.makeLeaf(x);
          } else if (!node->Node.hasRoom) {
            let last = ar->Garter_Array.lastUnsafe;
            let newAr = ar->Array.copy;
            newAr->Array.setUnsafe(
              ar->Array.length - 1,
              traverse(last, height - 1),
            );
            Inner(newAr);
          } else {
            let newAr = Array.makeUninitializedUnsafe(ar->Array.length + 1);
            Belt.Array.blit(
              ~src=ar,
              ~srcOffset=0,
              ~dst=newAr,
              ~dstOffset=0,
              ~len=ar->Array.length,
            );
            newAr->Array.setUnsafe(
              ar->Array.length,
              traverse(Node.makeEmptyInner(), height - 1),
            );
            Inner(newAr);
          }
        | Leaf(_) => assert(false)
        };
      };
      let newRoot = traverse(root, depth);
      {...vec, size: size + 1, root: newRoot};
    } else {
      // case 3: when there's no room to append
      // Js.Console.info("push: case3");
      let rec newPath = (depth, node) =>
        depth == 0 ? node : newPath(depth - 1, Node.makeInner(node));

      let newRoot =
        Node.makeInner2(root, newPath(depth - 1, Node.makeLeaf(x)));

      {size: size + 1, depth: depth + 1, root: newRoot};
    };

/**
 * 1) leaf has more than 1 nodes
 * 2) leaf has only in node
 * 3) after 2), root has only 1 inner node
 */
let pop: t('a) => t('a) =
  ({size, depth, root} as vec) => {
    let leaf = getLastLeaf(vec);
    if (leaf->Node.hasSiblings) {
      // case 1)
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
      let path = getPath(size - 1, ~depth);
      let rec traverse = (path, curNode) => {
        let subIdx = path->List.headExn;
        switch (curNode) {
        | Inner(ar) =>
          let child =
            traverse(path->List.tailExn, ar->Array.getUnsafe(subIdx));
          switch (child) {
          | Some(n) =>
            // copy and replace
            let newAr = ar->Array.copy;
            newAr->Array.setUnsafe(subIdx, Node.makeInner(n));
            Some(Inner(newAr));
          | None =>
            if (subIdx == 0) {
              None;
            } else {
              // copy and remove
              let newAr =
                ar->Array.slice(~offset=0, ~len=Array.length(ar) - 1);
              Some(Inner(newAr));
            }
          };
        | Leaf(_) =>
          // can be merged with case 1)
          assert(subIdx == 0);
          None;
        };
      };
      switch (traverse(path, root)) {
      | Some(newRoot) =>
        switch (newRoot) {
        | Inner(ar) when !newRoot->Node.hasSiblings =>
          let firstChild = ar->Array.getUnsafe(0);
          // case 3) kill root
          {depth: depth - 1, size: size - 1, root: firstChild};
        | _ => {...vec, size: size - 1, root: newRoot}
        }
      | None =>
        assert(size == 1);
        assert(depth == 2);
        make();
      };
    };
  };

let fromArray = ar => {
  Belt.Array.reduce(ar, make(), (v, i) => push(v, i));
};
