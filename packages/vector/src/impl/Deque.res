type t<'a> = FingerTree.tree<'a>

let empty = FingerTree.Empty

let pushFront = (tree, x) => FingerTree.pushl(tree, x)
let pushBack = (tree, x) => FingerTree.pushr(tree, x)

let popFront = tree =>
  switch FingerTree.viewl(tree) {
  | Nil => FingerTree.Empty
  | Cons(_, t') => t'
  }

let popBack = tree =>
  switch FingerTree.viewr(tree) {
  | Nil => FingerTree.Empty
  | Cons(_, t') => t'
  }

let peekFront = tree =>
  switch FingerTree.viewl(tree) {
  | Nil => None
  | Cons(a, _) => Some(a)
  }

let peekBack = tree =>
  switch FingerTree.viewr(tree) {
  | Nil => None
  | Cons(a, _) => Some(a)
  }
