open Belt.Array;

let isEmpty = xs => length(xs) === 0;

let lastUnsafe = ar => getUnsafe(ar, length(ar) - 1);

let last = ar => isEmpty(ar) ? None : Some(lastUnsafe(ar));

let updateUnsafe = (ar, i, f) => {
  let v = getUnsafe(ar, i);
  setUnsafe(ar, i, f(v));
};

/**
    {|
      module IntCmp =
        Belt.Id.MakeComparable({
          type t = int;
          let cmp = (a, b) => Pervasives.compare(a, b);
        });

      groupBy(
        [|1, 2, 3, 4, 5, 6, 7, 8, 9, 10|],
        ~keyFn=x => x mod 3,
        ~id=(module IntCmp),
      )
    |}
 */

let groupBy = (xs, ~keyFn, ~id) => {
  let empty = Belt.Map.make(~id);

  reduceU(xs, empty, (. res, x) => {
    Belt.Map.updateU(res, keyFn(x), (. v) =>
      switch (v) {
      | Some(l) => Some([x, ...l])
      | None => Some([x])
      }
    )
  })
  ->Belt.Map.map(Belt.List.toArray);
};

let frequencies = (ar, ~id) => {
  groupBy(ar, ~keyFn=x => x, ~id)
  ->Belt.Map.map(Belt.Array.length);
};

/** reduce와 비슷하나 중간 결과를 모두 포함한 array를 반환해줌 */
let scan = (xs, init, f) => {
  let state = makeUninitializedUnsafe(length(xs));
  let cur = ref(init);
  forEachWithIndex(
    xs,
    (idx, x) => {
      cur := f(cur^, x);
      setUnsafe(state, idx, cur^);
    },
  );
  state;
};

let max = xs => {
  let res = getUnsafe(xs, 0);
  reduce(xs, res, (x, res) => max(x, res));
};

/** Returns (max_value, index). Array may not be empty. */
let maxIndex = xs => {
  let init = (getUnsafe(xs, 0), 0);
  reduceWithIndex(
    xs,
    init,
    (acc, v, idx) => {
      let (curMax, curIdx) = acc;
      compare(v, curMax) > 0 ? (v, idx) : (curMax, curIdx);
    },
  )
  ->snd;
};
