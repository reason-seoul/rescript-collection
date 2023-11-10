// Finger trees
// https://www.staff.city.ac.uk/~ross/papers/FingerTree.pdf

type digit<'a> = One('a) | Two('a, 'a) | Three('a, 'a, 'a) | Four('a, 'a, 'a, 'a)

type node<'a> = Node3('a, 'a, 'a)

type rec tree<'a> =
  | Empty
  | Single('a)
  | Deep(digit<'a>, tree<node<'a>>, digit<'a>)

let rec pushl: 'a. (tree<'a>, 'a) => tree<'a> = (tree, x) =>
  switch tree {
  | Empty => Single(x)
  | Single(a) => Deep(One(x), Empty, One(a))
  | Deep(pr, m, sf) =>
    switch pr {
    | One(a) => Deep(Two(x, a), m, sf)
    | Two(a, b) => Deep(Three(x, a, b), m, sf)
    | Three(a, b, c) => Deep(Four(x, a, b, c), m, sf)
    | Four(a, b, c, d) => Deep(Two(x, a), pushl(m, Node3(b, c, d)), sf)
    }
  }

let rec pushr: 'a. (tree<'a>, 'a) => tree<'a> = (tree, x) =>
  switch tree {
  | Empty => Single(x)
  | Single(a) => Deep(One(a), Empty, One(x))
  | Deep(pr, m, sf) =>
    switch sf {
    | One(a) => Deep(pr, m, Two(a, x))
    | Two(a, b) => Deep(pr, m, Three(a, b, x))
    | Three(a, b, c) => Deep(pr, m, Four(a, b, c, x))
    | Four(a, b, c, d) => Deep(pr, pushr(m, Node3(a, b, c)), Two(d, x))
    }
  }

let head = digit =>
  switch digit {
  | One(a)
  | Two(a, _)
  | Three(a, _, _)
  | Four(a, _, _, _) => a
  }

let tail = digit =>
  switch digit {
  | One(_) => list{}
  | Two(_, b) => list{b}
  | Three(_, b, c) => list{b, c}
  | Four(_, b, c, d) => list{b, c, d}
  }

let last = digit =>
  switch digit {
  | One(a)
  | Two(_, a)
  | Three(_, _, a)
  | Four(_, _, _, a) => a
  }

let init = digit =>
  switch digit {
  | One(_) => list{}
  | Two(a, _) => list{a}
  | Three(a, b, _) => list{a, b}
  | Four(a, b, c, _) => list{a, b, c}
  }

let toDigit = l =>
  switch l {
  | list{a} => One(a)
  | list{a, b} => Two(a, b)
  | list{a, b, c} => Three(a, b, c)
  | list{a, b, c, d} => Four(a, b, c, d)
  | _ => assert false
  }

let toDigitNode = n =>
  switch n {
  | Node3(a, b, c) => Three(a, b, c)
  }

let toTree = d =>
  switch d {
  | One(a) => Single(a)
  | Two(a, b) => Deep(One(a), Empty, One(b))
  | Three(a, b, c) => Deep(Two(a, b), Empty, One(c))
  | Four(a, b, c, d) => Deep(Two(a, b), Empty, Two(c, d))
  }

type view<'a, 'rest> = Nil | Cons('a, 'rest)

let rec viewl: 'a. tree<'a> => view<'a, tree<'a>> = tree =>
  switch tree {
  | Empty => Nil
  | Single(a) => Cons(a, Empty)
  | Deep(One(a), m, sf) =>
    let v = switch viewl(m) {
    | Nil => toTree(sf)
    | Cons(a, m') => Deep(toDigitNode(a), m', sf)
    }
    Cons(a, v)
  | Deep(pr, m, sf) => Cons(head(pr), Deep(toDigit(tail(pr)), m, sf))
  }

let rec viewr: 'a. tree<'a> => view<'a, tree<'a>> = tree =>
  switch tree {
  | Empty => Nil
  | Single(a) => Cons(a, Empty)
  | Deep(pr, m, One(a)) =>
    let v = switch viewr(m) {
    | Nil => toTree(pr)
    | Cons(a, m') => Deep(pr, m', toDigitNode(a))
    }
    Cons(a, v)
  | Deep(pr, m, sf) => Cons(last(sf), Deep(pr, m, toDigit(init(sf))))
  }

let fromNode = (Node3(a, b, c)) => [a, b, c]
let fromDigit = d =>
  switch d {
  | One(a) => [a]
  | Two(a, b) => [a, b]
  | Three(a, b, c) => [a, b, c]
  | Four(a, b, c, d) => [a, b, c, d]
  }
