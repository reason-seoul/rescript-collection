open Benchmark

type t = {
  name: string,
  setup: string,
  benchmarks: array<Benchmark.t>,
}

module A = Belt.Array

let a1k = A.makeByAndShuffle(1000, i => i)
let h1k = a1k->HashSet.Int.fromArray
let b1k = a1k->Belt.Set.Int.fromArray
let i1k = a1k->ImmutableJs.Set.fromArray
let m1k = a1k |> Mori.into(Mori.set([]))

module Create = {
  let setup = j`let a1k = A.makeByAndShuffle(1000, i => i)`
  let benchmarks = [
    {
      name: j`HashSet.Int.fromArray`,
      f: (. ()) => a1k->HashSet.Int.fromArray->Any,
      code: "HashSet.Int.fromArray(a1k)",
    },
    {
      name: j`Belt.Set.Int.fromArray`,
      f: (. ()) => a1k->Belt.Set.Int.fromArray->Any,
      code: "Belt.Set.Int.fromArray(a1k)",
    },
    {
      name: "ImmutableJs.Set.fromArray",
      f: (. ()) => a1k->ImmutableJs.Set.fromArray->Any,
      code: "ImmutableJs.Set.fromArray(a1k)",
    },
    {
      name: j`Mori.into`,
      f: (. ()) => Mori.into(Mori.set([]), a1k)->Any,
      code: j`Mori.into(Mori.set([]), a1k)`,
    },
  ]

  let suite = {name: j`Create`, setup: setup, benchmarks: benchmarks}
}

module Insert = {
  let setup = j`let a1k = A.makeByAndShuffle(1000, i => i)`

  let benchmarks = [
    {
      name: j`HashSet.Int.set`,
      f: (. ()) => {
        a1k->A.reduce(HashSet.Int.empty, HashSet.Int.set)->Any
      },
      code: j`a1k->A.reduce(HashSet.Int.empty, HashSet.Int.set)`,
    },
    {
      name: `Belt.Set.Int.add`,
      f: (. ()) => {
        a1k->A.reduce(Belt.Set.Int.empty, Belt.Set.Int.add)->Any
      },
      code: `a1k->A.reduce(Belt.Set.Int.empty, Belt.Set.Int.add)`,
    },
    {
      name: "ImmutableJs.Set.add",
      f: (. ()) => {
        a1k->A.reduce(ImmutableJs.Set.make(), ImmutableJs.Set.add)->Any
      },
      code: `a1k->A.reduce(ImmutableJs.Set.make(), ImmutableJs.Set.add)`,
    },
    {
      name: "Mori.conj",
      f: (. ()) => {
        a1k->A.reduce(Mori.set([]), Mori.conj)->Any
      },
      code: `a1k->A.reduce(Mori.set([]), Mori.conj)`,
    },
  ]

  let suite = {name: `Insert`, setup: setup, benchmarks: benchmarks}
}

module Access = {
  let setup = j`let a1k = A.makeByAndShuffle(1000, i => i)
let h1k = a1k->HashSet.Int.fromArray
let b1k = a1k->Belt.Set.Int.fromArray
let i1k = a1k->ImmutableJs.Set.fromArray
let m1k = a1k |> Mori.into(Mori.set([]))`

  let benchmarks = [
    {
      name: j`HashSet.Int.get`,
      f: (. ()) => {
        a1k
        ->A.forEach(v => {
          assert (HashSet.Int.get(h1k, v)->Belt.Option.isSome)
          assert (HashSet.Int.get(h1k, v * -1 - 1)->Belt.Option.isNone)
        })
        ->Any
      },
      code: j`a1k
->A.forEach(v => {
  assert (HashSet.Int.get(h1k, v)->Belt.Option.isSome)
  assert (HashSet.Int.get(h1k, v * -1 - 1)->Belt.Option.isNone)
})`,
    },
    {
      name: `Belt.Set.Int.get`,
      f: (. ()) => {
        a1k
        ->A.forEach(v => {
          assert (Belt.Set.Int.get(b1k, v)->Belt.Option.isSome)
          assert (Belt.Set.Int.get(b1k, v * -1 - 1)->Belt.Option.isNone)
        })
        ->Any
      },
      code: `a1k
->A.forEach(v => {
  assert (Belt.Set.Int.get(b1k, v)->Belt.Option.isSome)
  assert (Belt.Set.Int.get(b1k, v * -1 - 1)->Belt.Option.isNone)
})`,
    },
    {
      name: "ImmutableJs.Set.get",
      f: (. ()) => {
        a1k
        ->A.forEach(v => {
          assert (ImmutableJs.Set.get(i1k, v)->Belt.Option.isSome)
          assert (ImmutableJs.Set.get(i1k, v * -1 - 1)->Belt.Option.isNone)
        })
        ->Any
      },
      code: `a1k
->A.forEach(v => {
  assert (ImmutableJs.Set.get(i1k, v)->Belt.Option.isSome)
  assert (ImmutableJs.Set.get(i1k, v * -1 - 1)->Belt.Option.isNone)
})`,
    },
    {
      name: "Mori.get",
      f: (. ()) => {
        a1k
        ->A.forEach(v => {
          assert (Mori.get(m1k, v)->Belt.Option.isSome)
          assert (Mori.get(m1k, v * -1 - 1)->Belt.Option.isNone)
        })
        ->Any
      },
      code: `a1k
->A.forEach(v => {
  assert (Mori.get(m1k, v)->Belt.Option.isSome)
  assert (Mori.get(m1k, v * -1 - 1)->Belt.Option.isNone)
})`,
    },
  ]

  let suite = {name: `Access`, setup: setup, benchmarks: benchmarks}
}

module Routes = {
  type item = {
    suite: t,
    url: string,
  }

  type key = Create | Insert | Access

  /* Make sure the URLs are the same in both functions! */

  let map = x =>
    switch x {
    | Create => {suite: Create.suite, url: "create"}
    | Insert => {suite: Insert.suite, url: "insert"}
    | Access => {suite: Access.suite, url: "access"}
    }

  let fromUrl = x =>
    switch x {
    | "create" => Some(Create)
    | "insert" => Some(Insert)
    | "access" => Some(Access)
    | _ => None
    }

  /* The main menu uses this array to list pages. */
  let routes = [Create, Insert, Access]
}
