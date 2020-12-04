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
