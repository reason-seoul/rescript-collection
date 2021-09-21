open Benchmark

type t = {
  name: string,
  setup: string,
  benchmarks: array<Benchmark.t>,
}

module A = Belt.Array
module V = Vector
module L = ImmutableJs.List

let ar1k = A.range(1, 1000)
let ar10k = A.range(1, 10000)

let v10k = Vector.fromArray(ar10k)
let l10k = ImmutableJs.List.fromArray(ar10k)
let m10k = Mori.into(Mori.vector(), ar10k)

module Create = {
  let n = 10000
  let setup = j`let ar10k = A.range(1, 10000)`
  let benchmarks = [
    {
      name: "Vector.fromArray",
      f: (. ()) => Vector.fromArray(ar10k)->Any,
      code: "Vector.fromArray(ar10k)",
    },
    {
      name: "ImmutableJs.List.fromArray",
      f: (. ()) => ImmutableJs.List.fromArray(ar10k)->Any,
      code: "ImmutableJs.List.fromArray(ar10k)",
    },
    {
      name: "Mori.into",
      f: (. ()) => Mori.into(Mori.vector(), ar10k)->Any,
      code: "Mori.into(Mori.vector(), ar10k)",
    },
  ]

  let suite = {name: "Create (from array)", setup: setup, benchmarks: benchmarks}
}

module Convert = {
  let setup = j`let ar10k = A.range(1, 10000)

let v = Vector.fromArray(ar10k)
let l = ImmutableJs.List.fromArray(ar10k)
let m = Mori.into(Mori.vector(), ar10k)`

  let benchmarks = [
    {
      name: j`Vector.toArray`,
      f: (. ()) => Any(Vector.toArray(v10k)),
      code: j`Vector.toArray(v)`,
    },
    {
      name: j`ImmutableJs.List.toArray`,
      f: (. ()) => Any(ImmutableJs.List.toArray(l10k)),
      code: j`ImmutableJs.List.toArray(l)`,
    },
    {
      name: j`Mori.intoArray`,
      f: (. ()) => Any(Mori.intoArray(m10k)),
      code: j`Mori.intoArray(m)`,
    },
  ]

  let suite = {name: j`Convert (to array)`, setup: setup, benchmarks: benchmarks}
}

module Push = {
  let setup = j`let ar1k = A.range(1, 1000)`

  // let mutableCase = n =>
  //   {
  //     name: "Js.Array2.push (mutable)",
  //     f:
  //       (.) => {
  //         let ar = [||];
  //         A.range(1, n)->A.forEach(v => ar->Js.Array2.push(v)->ignore)->Any;
  //       },
  //     code: "let ar = [||];\nA.range(1, n)->A.forEach(v => ar->Js.Array2.push(v)->ignore)",
  //   };

  let suite = {
    name: j`Push`,
    setup: setup,
    benchmarks: [
      {
        name: j`Vector.push`,
        f: (. ()) => A.reduce(ar1k, Vector.make(), (v, i) => Vector.push(v, i + 0))->Any,
        code: "// Let ReScript compiler doesn't eschew wrapper function.\nA.reduce(ar1k, Vector.make(), (v, i) => Vector.push(v, i + 0))",
      },
      {
        name: j`ImmutableJs.List.push`,
        f: (. ()) => {
          A.reduce(ar1k, ImmutableJs.List.make(), (l, i) => ImmutableJs.List.push(l, i))->Any
        },
        code: "A.reduce(ar1k, ImmutableJs.List.make(), (l, i) => ImmutableJs.List.push(l, i))",
      },
      {
        name: "mori.conj",
        f: (. ()) => A.reduce(ar1k, Mori.vector(), (v, i) => Mori.conj(v, i))->Any,
        code: "A.reduce(ar1k, Mori.vector(), (v, i) => Mori.conj(v, i))",
      },
    ],
  }
}

module Pop = {
  let v1k = Vector.fromArray(ar1k)
  let l1k = ImmutableJs.List.fromArray(ar1k)
  let m1k = Mori.into(Mori.vector(), ar1k)

  let setup = j`let ar1k = A.range(1, 1000)

let v1k = Vector.fromArray(ar1k)
let l1k = ImmutableJs.List.fromArray(ar1k)
let m1k = Mori.into(Mori.vector(), ar1k)
`

  let suite = {
    name: j`Pop`,
    setup: setup,
    benchmarks: [
      {
        name: j`Vector.push`,
        f: (. ()) => A.reduce(ar1k, v1k, (v, _) => Vector.pop(v))->Any,
        code: j`A.reduce(ar1k, v1k, (v, _) => Vector.pop(v))`,
      },
      {
        name: j`ImmutableJs.List.push`,
        f: (. ()) => {
          A.reduce(ar1k, l1k, (l, _) => ImmutableJs.List.pop(l))->Any
        },
        code: j`A.reduce(ar1k, l1k, (l, _) => ImmutableJs.List.pop(l))`,
      },
      {
        name: "mori.conj",
        f: (. ()) => A.reduce(ar1k, m1k, (m, _) => Mori.pop(m))->Any,
        code: j`A.reduce(ar1k, m1k, (m, _) => Mori.pop(m))`,
      },
    ],
  }
}

module Concat = {
  let n = 100
  let v0 = A.makeBy(n, _ => V.makeBy(n, i => i))
  let l0 = A.makeBy(n, _ => L.fromArray(A.makeBy(n, i => i)))
  let a0 = A.makeBy(n, _ => A.makeBy(n, i => i))

  let setup = j`let n = $n
let v0 = A.makeBy(n, V.makeBy(n, i => i))
let l0 = A.makeBy(n, _ => L.fromArray(A.makeBy(n, i => i)))`

  let benchmarks = [
    {
      name: "Vector.concatMany",
      f: (. ()) => V.concatMany(v0)->Any,
      code: "V.concatMany(v0)",
    },
    {
      name: "ImmutableJs.concat",
      f: (. ()) => L.concatMany(l0)->Any,
      code: "L.concatMany(l0)",
    },
    // {
    //   name: "Belt.Array.concatMany",
    //   f: (. ()) => A.concatMany(a0)->Any,
    //   code: "A.concatMany(a0)",
    // },
    // {
    //   name: "Js.Array2.concat",
    //   f: (. ()) => Js.Array2.concatMany([], a0)->Any,
    //   code: "Js.Array2.concatMany([], a0)",
    // },
  ]

  let suite = {
    name: "Concat",
    setup: setup,
    benchmarks: benchmarks,
  }
}

module Fixture = {
  let n = 10000
  let v0 = A.range(1, n)
  let v1 = Vector.fromArray(A.range(1, n))
  let v2 = ImmutableJs.List.fromArray(A.range(1, n))
  let v3 = Mori.into(Mori.vector(), A.range(1, n))

  let setup = j`let n = 10000;
let v0 = A.range(1, n);
let v1 = Vector.fromArray(A.range(1, n));
let v2 = ImmutableJs.List.fromArray(A.range(1, n));
let v3 = Mori.into(Mori.vector(), A.range(1, n));`
}

module AccessUpdate = {
  let indices = A.range(0, Fixture.n - 1)->A.shuffle

  let setup = Fixture.setup ++ j`\\nlet indices = A.range(0, n - 1)->A.shuffle;`
  let accessSuite = {
    name: j`Random Access`,
    setup: setup,
    benchmarks: [
      {
        name: j`Vector.getExn`,
        f: (. ()) => indices->A.forEach(i => Vector.getExn(Fixture.v1, i)->ignore)->Any,
        code: j`indices->A.forEach(i => Vector.get(v1, i)->ignore)`,
      },
      {
        name: j`ImmutableJs.List.get`,
        f: (. ()) => indices->A.forEach(i => ImmutableJs.List.get(Fixture.v2, i)->ignore)->Any,
        code: j`indices->A.forEach(i => ImmutableJs.List.get(v2, i)->ignore)`,
      },
      {
        name: j`Mori.nth`,
        f: (. ()) => indices->A.forEach(i => Mori.nth(Fixture.v3, i)->ignore)->Any,
        code: j`indices->A.forEach(i => Mori.nth(v3, i)->ignore)`,
      },
    ],
  }

  let updateSuite = {
    name: j`Random Update`,
    setup: setup,
    benchmarks: [
      {
        name: j`Vector.setExn`,
        f: (. ()) => indices->A.reduce(Fixture.v1, (v, i) => Vector.setExn(v, i, -1))->Any,
        code: j`indices->A.reduce(v1, (v, i) => Vector.setExn(v, i, -1))`,
      },
      {
        name: j`ImmutableJs.List.set`,
        f: (. ()) => indices->A.reduce(Fixture.v2, (v, i) => ImmutableJs.List.set(v, i, -1))->Any,
        code: j`indices\\n->A.reduce(v2, (v, i) => ImmutableJs.List.set(v, i, -1))`,
      },
      {
        name: j`Mori.assoc`,
        f: (. ()) => indices->A.reduce(Fixture.v3, (v, i) => Mori.assoc(v, i, -1))->Any,
        code: j`indices->A.reduce(v3, (v, i) => Mori.assoc(v, i, -1))`,
      },
    ],
  }
}

module Reduce = {
  let setup = Fixture.setup

  let suite = {
    name: j`Reduce`,
    setup: setup,
    benchmarks: [
      {
        name: j`Vector.reduce`,
        f: (. ()) => Fixture.v1->Vector.reduce(0, \"+")->Any,
        code: j`v1->Vector.reduce(0, (+))`,
      },
      {
        name: j`ImmutableJs.List.reduce`,
        f: (. ()) => Fixture.v2->ImmutableJs.List.reduce(\"+", 0)->Any,
        code: j`v2->ImmutableJs.List.reduce((+), 0)`,
      },
      {
        name: j`Mori.reduce`,
        f: (. ()) => Fixture.v3->Mori.reduce(\"+", 0, _)->Any,
        code: j`v3->Mori.reduce((+), 0, _)`,
      },
    ],
  }
  let suite2 = {
    name: j`Reduce (vs. mutable)`,
    setup: setup,
    benchmarks: [
      {
        name: j`Js.Array2.reduce (built-in)`,
        f: (. ()) => Fixture.v0->Js.Array2.reduce(\"+", 0)->Any,
        code: j`v0->Js.Array2.reduce((+), 0)`,
      },
      {
        name: j`Belt.Array.reduce`,
        f: (. ()) => Fixture.v0->Belt.Array.reduce(0, \"+")->Any,
        code: j`v0->Belt.Array.reduce(0, (+))`,
      },
      {
        name: j`Vector.reduce`,
        f: (. ()) => Fixture.v1->Vector.reduce(0, \"+")->Any,
        code: j`v1->Vector.reduce(0, (+))`,
      },
    ],
  }
}

module Routes = {
  type item = {
    suite: t,
    url: string,
  }

  /* Register the route to your benchmark by giving it a variant here. */
  type key =
    | Create
    | Convert
    | Push
    | Pop
    | Concat
    | RandomAccess
    | RandomUpdate
    | Reduce
    | ReduceMutable

  /* Make sure the URLs are the same in both functions! */

  let map = x =>
    switch x {
    | Create => {suite: Create.suite, url: "create"}
    | Convert => {suite: Convert.suite, url: "convert"}
    | Push => {suite: Push.suite, url: "push"}
    | Pop => {suite: Pop.suite, url: "pop"}
    | Concat => {suite: Concat.suite, url: "concat"}
    | RandomAccess => {suite: AccessUpdate.accessSuite, url: "random-access"}
    | RandomUpdate => {suite: AccessUpdate.updateSuite, url: "random-update"}
    | Reduce => {suite: Reduce.suite, url: "reduce"}
    | ReduceMutable => {suite: Reduce.suite2, url: "reduce-mutable"}
    }

  let fromUrl = x =>
    switch x {
    | "create" => Some(Create)
    | "convert" => Some(Convert)
    | "push" => Some(Push)
    | "pop" => Some(Pop)
    | "concat" => Some(Concat)
    | "random-access" => Some(RandomAccess)
    | "random-update" => Some(RandomUpdate)
    | "reduce" => Some(Reduce)
    | "reduce-mutable" => Some(ReduceMutable)
    | _ => None
    }

  /* The main menu uses this array to list pages. */
  let routes = [
    Create,
    Convert,
    Push,
    Pop,
    Concat,
    RandomAccess,
    RandomUpdate,
    Reduce,
    ReduceMutable,
  ]
}
