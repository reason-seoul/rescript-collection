open Benchmark

type t = {
  name: string,
  setup: string,
  benchmarks: array<Benchmark.t>,
}

module A = Belt.Array
module S = HashSet

// module Create = {
//   let n = 1000
//   let benchmarks = [
//     {
//       name: j`HashSet.fromArray`,
//       f: (. ()) => {
//         let s = HashSet.make(~hasher=x => x)
//         A.range(1, n)->A.reduce(s, (s, x) => HashSet.set(s, x))->Any
//       },
//       code: j`let s = HashSet.make(~hasher=x => x)
//         A.range(1, n)->A.reduce(s, (s, x) => HashSet.set(s, x))`,
//     },
//     {
//       name: "ImmutableJs.Set.fromArray",
//       f: (. ()) => A.range(1, n)->ImmutableJs.Set.fromArray->Any,
//       code: "A.range(1, n)->ImmutableJs.Set.fromArray->Any",
//     },
//     // {
//     //   name: j`Mori.into`,
//     //   f: (. ()) => Any(A.range(1, n) |> Mori.into(Mori.vector())),
//     //   code: j`A.range(1, n) |> Mori.into(Mori.vector())`,
//     // },
//   ]

//   let suite = {name: j`Creation`, setup: "", benchmarks: benchmarks}
// }

module Insert = {
  let n = 100
  let ar = A.range(1, n)
  let setup = j`let n = $n
A.range(1, n)`

  let benchmarks = [
    {
      name: j`HashSet.set`,
      f: (. ()) => {
        let s = HashSet.make(~hasher=(. x) => x)
        A.shuffleInPlace(ar)
        A.reduce(ar, s, (s, x) => HashSet.set(s, x))->Any
      },
      code: j`let s = HashSet.make(~hasher=x => x)
A.shuffleInPlace(ar)
A.reduce(ar, s, (s, x) => HashSet.set(s, x))`,
    },
    {
      name: `Belt.Set.Int.add`,
      f: (. ()) => {
        let s = Belt.Set.Int.empty
        A.shuffleInPlace(ar)
        A.reduce(ar, s, (s, x) => Belt.Set.Int.add(s, x))->Any
      },
      code: `let s = Belt.Set.Int.empty
A.shuffleInPlace(ar)
A.reduce(ar, s, (s, x) => Belt.Set.Int.add(s, x))`,
    },
    {
      name: "ImmutableJs.Set.add",
      f: (. ()) => {
        let s = ImmutableJs.Set.make()
        A.shuffleInPlace(ar)
        A.reduce(ar, s, (s, x) => ImmutableJs.Set.add(s, x))->Any
      },
      code: `let s = ImmutableJs.Set.make()
A.shuffleInPlace(ar)
A.reduce(ar, s, (s, x) => ImmutableJs.Set.add(s, x))`,
    },
    //     {
    //       name: j`Mori.conj`,
    //       f: (. ()) => {
    //         let s = Mori.set([])
    //         A.range(1, n)->A.reduce(s, (s, x) => Mori.conj(s, x))->Any
    //       },
    //       code: j`A.range(1, n) |> Mori.into(Mori.vector())`,
    //     },
  ]

  let suite = {name: `Insert`, setup: setup, benchmarks: benchmarks}
}

module Routes = {
  type item = {
    suite: t,
    url: string,
  }

  type key = Create

  /* Make sure the URLs are the same in both functions! */

  let map = x =>
    switch x {
    | Create => {suite: Insert.suite, url: "create"}
    }

  let fromUrl = x =>
    switch x {
    | "create" => Some(Create)
    | _ => None
    }

  /* The main menu uses this array to list pages. */
  let routes = [Create]
}
