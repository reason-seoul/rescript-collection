open Belt;

type node('a) =
  | Inner(array(node('a)))
  | Leaf(array('a));

type t('a) = {
  size: int,
  depth: int,
  root: node('a),
};

let numBranches = 2;

let make = () => {
  size: 0,
  depth: 1,
  root: Leaf(Array.makeUninitializedUnsafe(numBranches)),
};

/**
 * Path from root to i'th leaf
 */
let rec getPath = (i, d) => {
  Js.log2(i, d);
  if (d == 0) {
    [i];
  } else {
    let denom = Js.Math.pow_int(~base=numBranches, ~exp=d);
    Js.log("denom: " ++ Belt.Int.toString(denom));
    getPath(i mod denom, d - 1)->Belt.List.add(i / denom);
  };
};

let getUnsafe = ({depth, root}, i) => {
  let path = getPath(i, depth - 1);
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
    let path = getPath(i, depth - 1);

    let rec traverse = (path, node) => {
      let index = path->Belt.List.headExn;
      switch (node) {
      | Inner(n) =>
        let m = Array.copy(n);
        m
        ->Array.set(
            index,
            traverse(path->List.tailExn, n->Array.getUnsafe(index)),
          )
        ->ignore;
        Inner(m);

      | Leaf(n) =>
        let m = Array.copy(n);
        m->Array.set(index, x)->ignore;
        Leaf(m);
      };
    };

    {...vec, root: traverse(path, root)};
  };

// getPath(1, 2)->Js.log;

let push: (t('a), 'a) => t('a) =
  (vec, x) => {
    vec;
  };

let pop: t('a) => option(t('a)) =
  vec => {
    Some(vec);
  };
