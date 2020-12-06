let isEmpty = xs => Belt.List.length(xs) === 0;

let takeExn = (list, cnt) => {
  switch (Belt.List.take(list, cnt)) {
  | Some(l) => l
  | None => raise(Not_found)
  };
};

let dropExn = (list, cnt) => {
  switch (Belt.List.drop(list, cnt)) {
  | Some(l) => l
  | None => raise(Not_found)
  };
};

let rec orderedPairs = xs => {
  switch (xs) {
  | [] => []
  | [x, ...ys] => Belt.List.map(ys, y => (x, y)) @ orderedPairs(ys)
  };
};

let partitionBy = (xs: list('a), f: 'a => 'b): list(list('a)) => {
  open Belt;
  let rec iter = (ys, fx, acc, res) => {
    switch (ys) {
    | [] =>
      (
        switch (acc) {
        | [] => res
        | _ => res->List.add(acc->List.reverse)
        }
      )
      ->List.reverse
    | [y, ...ys] =>
      let fy = f(y);
      fx == fy
        ? iter(ys, fy, acc->List.add(y), res)
        : iter(ys, fy, [y], res->List.add(acc->List.reverse));
    };
  };

  switch (xs) {
  | [] => []
  | [x, ...xs] => iter(xs, f(x), [x], [])
  };
};
