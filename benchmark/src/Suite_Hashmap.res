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
      name: j`HashSet.set`,
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

module Routes = {
  type item = {
    suite: t,
    url: string,
  }

  type key = Create | Insert

  /* Make sure the URLs are the same in both functions! */

  let map = x =>
    switch x {
    | Create => {suite: Create.suite, url: "create"}
    | Insert => {suite: Insert.suite, url: "insert"}
    }

  let fromUrl = x =>
    switch x {
    | "create" => Some(Create)
    | "insert" => Some(Insert)
    | _ => None
    }

  /* The main menu uses this array to list pages. */
  let routes = [Create, Insert]
}
