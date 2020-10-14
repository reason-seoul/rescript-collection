let isEmpty = xs => Belt.Array.length(xs) === 0;

let lastUnsafe = ar => Belt.Array.getUnsafe(ar, Belt.Array.length(ar) - 1);

let last = ar => isEmpty(ar) ? None : Some(lastUnsafe(ar));

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

  Belt.Array.reduceU(
    xs,
    empty,
    (. res, x) => {
      let k = keyFn(. x);
      Belt.Map.updateU(res, k, (. v) =>
        switch (v) {
        | Some(l) => Some([x, ...l])
        | None => Some([x])
        }
      );
    },
  )
  ->Belt.Map.map(Belt.List.toArray);
};
