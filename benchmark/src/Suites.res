@unboxed
type rec any = Any('a): any

type benchmark = {
  name: string,
  code: string,
  f: (. unit) => any,
}

type t = {
  name: string,
  setup: string,
  benchmarks: array<benchmark>,
}

module A = Belt.Array
module V = Vector

module Create = {
  let n = 1000
  let benchmarks = [
    {
      name: j`Vector.fromArray`,
      f: (. ()) => A.range(1, n)->Vector.fromArray->Any,
      code: j`A.range(1, n)->Vector.fromArray`,
    },
    {
      name: j`ImmutableJs.List.fromArray`,
      f: (. ()) => A.range(1, n)->ImmutableJs.List.fromArray->Any,
      code: j`A.range(1, n)->ImmutableJs.List.fromArray`,
    },
    {
      name: j`Mori.into`,
      f: (. ()) => Any(A.range(1, n) |> Mori.into(Mori.vector())),
      code: j`A.range(1, n) |> Mori.into(Mori.vector())`,
    },
  ]

  let suite = {name: j`Creation`, setup: "", benchmarks: benchmarks}
}

module Push = {
  let smallN = 1000
  let largeN = 100000

  let vectorCase = n => {
    name: j`Vector.push`,
    f: (. ()) => A.range(1, n)->A.reduce(V.make(), (v, i) => V.push(v, i))->Any,
    code: j`A.range(1, n)\\n->A.reduce(Vector.make(), (v, i) => Vector.push(v, i))`,
  }

  let immutableJsCase = n => {
    name: j`ImmutableJs.List.push`,
    f: (. ()) => {
      module L = ImmutableJs.List
      A.range(1, n)->A.reduce(L.fromArray([]), (l, i) => L.push(l, i))->Any
    },
    code: j`A.range(1, n)\\n->A.reduce(ImmutableJs.List.fromArray([||]), (l, i) => ImmutableJs.List.push(l, i))`,
  }

  let moriCase = n => {
    name: "mori.conj",
    f: (. ()) => A.range(1, n)->A.reduce(Mori.vector(), (v, i) => Mori.conj(v, i))->Any,
    code: j`A.range(1, n)\\n->A.reduce(Mori.vector(), (v, i) => Mori.conj(v, i))`,
  }

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

  let smallSuite = {
    name: j`Append last (n=$smallN)`,
    setup: j`let n = $smallN;`,
    benchmarks: [
      vectorCase(smallN),
      immutableJsCase(smallN),
      moriCase(smallN),
      {
        name: "Belt.Array.concat",
        f: (. ()) => A.range(1, smallN)->A.reduce(A.make(0, 0), (ar, v) => ar->A.concat([v]))->Any,
        code: j`A.range(1, n)\\n->A.reduce(A.make(0, 0), (ar, v) => ar->A.concat([|v|]))`,
      },
      {
        name: "Js.Array2.concat",
        f: (. ()) =>
          A.range(1, smallN)->A.reduce(A.make(0, 0), (ar, v) => ar->Js.Array2.concat([v]))->Any,
        code: j`A.range(1, n)\\n->A.reduce(A.make(0, 0), (ar, v) => ar->Js.Array2.concat([|v|]))`,
      },
    ],
  }

  let largeSuite = {
    name: j`Append last (n=$largeN)`,
    setup: j`let n = $largeN;`,
    benchmarks: [vectorCase(largeN), immutableJsCase(largeN), moriCase(largeN)],
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
    | PushSmall
    | PushLarge
    | RandomAccess
    | RandomUpdate
    | Reduce
    | ReduceMutable

  /* Make sure the URLs are the same in both functions! */

  let map = x =>
    switch x {
    | Create => {suite: Create.suite, url: "create"}
    | PushSmall => {suite: Push.smallSuite, url: "append-last-small"}
    | PushLarge => {suite: Push.largeSuite, url: "append-last-large"}
    | RandomAccess => {suite: AccessUpdate.accessSuite, url: "random-access"}
    | RandomUpdate => {suite: AccessUpdate.updateSuite, url: "random-update"}
    | Reduce => {suite: Reduce.suite, url: "reduce"}
    | ReduceMutable => {suite: Reduce.suite2, url: "reduce-mutable"}
    }

  let fromUrl = x =>
    switch x {
    | "create" => Some(Create)
    | "append-last-small" => Some(PushSmall)
    | "append-last-large" => Some(PushLarge)
    | "random-access" => Some(RandomAccess)
    | "random-update" => Some(RandomUpdate)
    | "reduce" => Some(Reduce)
    | "reduce-mutable" => Some(ReduceMutable)
    | _ => None
    }

  /* The main menu uses this array to list pages. */
  let routes = [Create, PushSmall, PushLarge, RandomAccess, RandomUpdate, Reduce, ReduceMutable]
}
