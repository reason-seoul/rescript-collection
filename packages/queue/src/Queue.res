/**
 * Batch Queue (Chris Okasaki's)
 */
type t<'a> = (list<'a>, list<'a>)

let empty = (list{}, list{})
let isEmpty = ((f, _)) => Belt.List.size(f) == 0

let checkf = fr =>
  switch fr {
  | (list{}, r) => (Belt.List.reverse(r), list{})
  | q => q
  }

let snoc = ((f, r), x) => checkf((f, list{x, ...r}))
let head = q =>
  switch q {
  | (list{}, _) => raise(Not_found)
  | (list{x, ..._}, _) => x
  }

let tail = q =>
  switch q {
  | (list{}, _) => raise(Not_found)
  | (list{_, ...f}, r) => checkf((f, r))
  }
