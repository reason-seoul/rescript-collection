[@unboxed]
type any =
  | Any('a): any;

type benchmark = {
  name: string,
  code: string,
  f: (. unit) => any,
};

type t = {
  name: string,
  setup: string,
  benchmarks: array(benchmark),
};

module A = Belt.Array;
module V = Vector;

module Create = {
  let n = 1000;
  let benchmarks = [|
    {
      name: {j|Vector.fromArray|j},
      f:
        (.) => {
          A.range(1, n)->Vector.fromArray->Any;
        },
      code: {j|A.range(1, n)->Vector.fromArray|j},
    },
    {
      name: {j|ImmutableJs.List.fromArray|j},
      f:
        (.) => {
          A.range(1, n)->ImmutableJs.List.fromArray->Any;
        },
      code: {j|A.range(1, n)->ImmutableJs.List.fromArray|j},
    },
    {
      name: {j|Mori.into|j},
      f:
        (.) => {
          Any(A.range(1, n) |> Mori.into(Mori.vector()));
        },
      code: {j|A.range(1, n) |> Mori.into(Mori.vector())|j},
    },
  |];

  let suite = {name: {j|Creation|j}, setup: "", benchmarks};
};

module Push = {
  let smallN = 1000;
  let largeN = 100000;

  let vectorCase = n => {
    name: {j|Vector.push|j},
    f:
      (.) => {
        A.range(1, n)->A.reduce(V.make(), (v, i) => V.push(v, i))->Any;
      },
    code: {j|A.range(1, n)\n->A.reduce(Vector.make(), (v, i) => Vector.push(v, i))|j},
  };

  let immutableJsCase = n => {
    name: {j|ImmutableJs.List.push|j},
    f:
      (.) => {
        module L = ImmutableJs.List;
        A.range(1, n)
        ->A.reduce(L.fromArray([||]), (l, i) => L.push(l, i))
        ->Any;
      },
    code: {j|A.range(1, n)\n->A.reduce(ImmutableJs.List.fromArray([||]), (l, i) => ImmutableJs.List.push(l, i))|j},
  };

  let moriCase = n => {
    name: "mori.conj",
    f:
      (.) => {
        A.range(1, n)
        ->A.reduce(Mori.vector(), (v, i) => Mori.conj(v, i))
        ->Any;
      },
    code: {j|A.range(1, n)\n->A.reduce(Mori.vector(), (v, i) => Mori.conj(v, i))|j},
  };

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
    name: {j|Append last (n=$smallN)|j},
    setup: {j|let n = $smallN;|j},
    benchmarks: [|
      vectorCase(smallN),
      immutableJsCase(smallN),
      moriCase(smallN),
      {
        name: "Belt.Array.concat",
        f:
          (.) => {
            A.range(1, smallN)
            ->A.reduce(A.make(0, 0), (ar, v) => ar->A.concat([|v|]))
            ->Any;
          },
        code: {j|A.range(1, n)\n->A.reduce(A.make(0, 0), (ar, v) => ar->A.concat([|v|]))|j},
      },
      {
        name: "Js.Array2.concat",
        f:
          (.) => {
            A.range(1, smallN)
            ->A.reduce(A.make(0, 0), (ar, v) => ar->Js.Array2.concat([|v|]))
            ->Any;
          },
        code: {j|A.range(1, n)\n->A.reduce(A.make(0, 0), (ar, v) => ar->Js.Array2.concat([|v|]))|j},
      },
    |],
  };

  let largeSuite = {
    name: {j|Append last (n=$largeN)|j},
    setup: {j|let n = $largeN;|j},
    benchmarks: [|
      vectorCase(largeN),
      immutableJsCase(largeN),
      moriCase(largeN),
    |],
  };
};

module Fixture = {
  let n = 10000;
  let v0 = A.range(1, n);
  let v1 = Vector.fromArray(A.range(1, n));
  let v2 = ImmutableJs.List.fromArray(A.range(1, n));
  let v3 = Mori.into(Mori.vector(), A.range(1, n));

  let setup = {j|let n = 10000;
let v0 = A.range(1, n);
let v1 = Vector.fromArray(A.range(1, n));
let v2 = ImmutableJs.List.fromArray(A.range(1, n));
let v3 = Mori.into(Mori.vector(), A.range(1, n));|j};
};

module AccessUpdate = {
  let indices = A.range(0, Fixture.n - 1)->A.shuffle;

  let setup =
    Fixture.setup ++ {j|\nlet indices = A.range(0, n - 1)->A.shuffle;|j};
  let accessSuite = {
    name: {j|Random Access|j},
    setup,
    benchmarks: [|
      {
        name: {j|Vector.getExn|j},
        f:
          (.) => {
            indices
            ->A.forEach(i => Vector.getExn(Fixture.v1, i)->ignore)
            ->Any;
          },
        code: {j|indices->A.forEach(i => Vector.get(v1, i)->ignore)|j},
      },
      {
        name: {j|ImmutableJs.List.get|j},
        f:
          (.) => {
            indices
            ->A.forEach(i => ImmutableJs.List.get(Fixture.v2, i)->ignore)
            ->Any;
          },
        code: {j|indices->A.forEach(i => ImmutableJs.List.get(v2, i)->ignore)|j},
      },
      {
        name: {j|Mori.nth|j},
        f:
          (.) => {
            indices->A.forEach(i => Mori.nth(Fixture.v3, i)->ignore)->Any;
          },
        code: {j|indices->A.forEach(i => Mori.nth(v3, i)->ignore)|j},
      },
    |],
  };

  let updateSuite = {
    name: {j|Random Update|j},
    setup,
    benchmarks: [|
      {
        name: {j|Vector.setExn|j},
        f:
          (.) => {
            indices
            ->A.reduce(Fixture.v1, (v, i) => Vector.setExn(v, i, -1))
            ->Any;
          },
        code: {j|indices->A.reduce(v1, (v, i) => Vector.setExn(v, i, -1))|j},
      },
      {
        name: {j|ImmutableJs.List.set|j},
        f:
          (.) => {
            indices
            ->A.reduce(Fixture.v2, (v, i) => ImmutableJs.List.set(v, i, -1))
            ->Any;
          },
        code: {j|indices\n->A.reduce(v2, (v, i) => ImmutableJs.List.set(v, i, -1))|j},
      },
      {
        name: {j|Mori.assoc|j},
        f:
          (.) => {
            indices
            ->A.reduce(Fixture.v3, (v, i) => Mori.assoc(v, i, -1))
            ->Any;
          },
        code: {j|indices->A.reduce(v3, (v, i) => Mori.assoc(v, i, -1))|j},
      },
    |],
  };
};

module Reduce = {
  let setup = Fixture.setup;

  let suite = {
    name: {j|Reduce|j},
    setup,
    benchmarks: [|
      {
        name: {j|Vector.reduce|j},
        f:
          (.) => {
            Fixture.v1->Vector.reduce(0, (+))->Any;
          },
        code: {j|v1->Vector.reduce(0, (+))|j},
      },
      {
        name: {j|ImmutableJs.List.reduce|j},
        f:
          (.) => {
            Fixture.v2->ImmutableJs.List.reduce((+), 0)->Any;
          },
        code: {j|v2->ImmutableJs.List.reduce((+), 0)|j},
      },
      {
        name: {j|Mori.reduce|j},
        f:
          (.) => {
            Fixture.v3->Mori.reduce((+), 0, _)->Any;
          },
        code: {j|v3->Mori.reduce((+), 0, _)|j},
      },
    |],
  };
  let suite2 = {
    name: {j|Reduce (vs. mutable)|j},
    setup,
    benchmarks: [|
      {
        name: {j|Js.Array2.reduce (built-in)|j},
        f:
          (.) => {
            Fixture.v0->Js.Array2.reduce((+), 0)->Any;
          },
        code: {j|v0->Js.Array2.reduce((+), 0)|j},
      },
      {
        name: {j|Belt.Array.reduce|j},
        f:
          (.) => {
            Fixture.v0->Belt.Array.reduce(0, (+))->Any;
          },
        code: {j|v0->Belt.Array.reduce(0, (+))|j},
      },
      {
        name: {j|Vector.reduce|j},
        f:
          (.) => {
            Fixture.v1->Vector.reduce(0, (+))->Any;
          },
        code: {j|v1->Vector.reduce(0, (+))|j},
      },
    |],
  };
};

module Routes = {
  type item = {
    suite: t,
    url: string,
  };

  /* Register the route to your benchmark by giving it a variant here. */
  type key =
    | Create
    | PushSmall
    | PushLarge
    | RandomAccess
    | RandomUpdate
    | Reduce
    | ReduceMutable;

  /* Make sure the URLs are the same in both functions! */

  let map =
    fun
    | Create => {suite: Create.suite, url: "create"}
    | PushSmall => {suite: Push.smallSuite, url: "append-last-small"}
    | PushLarge => {suite: Push.largeSuite, url: "append-last-large"}
    | RandomAccess => {suite: AccessUpdate.accessSuite, url: "random-access"}
    | RandomUpdate => {suite: AccessUpdate.updateSuite, url: "random-update"}
    | Reduce => {suite: Reduce.suite, url: "reduce"}
    | ReduceMutable => {suite: Reduce.suite2, url: "reduce-mutable"};

  let fromUrl =
    fun
    | "create" => Some(Create)
    | "append-last-small" => Some(PushSmall)
    | "append-last-large" => Some(PushLarge)
    | "random-access" => Some(RandomAccess)
    | "random-update" => Some(RandomUpdate)
    | "reduce" => Some(Reduce)
    | "reduce-mutable" => Some(ReduceMutable)
    | _ => None;

  /* The main menu uses this array to list pages. */
  let routes = [|
    Create,
    PushSmall,
    PushLarge,
    RandomAccess,
    RandomUpdate,
    Reduce,
    ReduceMutable,
  |];
};
