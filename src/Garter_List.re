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
