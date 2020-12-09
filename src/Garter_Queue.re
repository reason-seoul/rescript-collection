/**
 * Batch Queue (Chris Okasaki's)
 */

type t('a) = (list('a), list('a));

let empty = ([], []);
let isEmpty = ((f, _)) => Garter.List.isEmpty(f);

let checkf =
  fun
  | ([], r) => (Belt.List.reverse(r), [])
  | q => q;

let snoc = ((f, r), x) => checkf((f, [x, ...r]));
let head =
  fun
  | ([], _) => raise(Not_found)
  | ([x, ..._], _) => x;

let tail =
  fun
  | ([], _) => raise(Not_found)
  | ([_, ...f], r) => checkf((f, r));
