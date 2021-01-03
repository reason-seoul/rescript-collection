open Jest;
open ExpectJs;

module A = Belt.Array;
module V = Garter.Vector;

// 초기화 테스트
describe("Vector.init", () => {
  test("empty", () =>
    expect(V.make()->V.length) |> toBe(0)
  )
});

describe("Belt.Array vs. Js.Array2 vs. Js.Vector vs. Garter.Vector", () => {
  let smallSet = A.rangeBy(1000, 5000, ~step=1000)->Belt.List.fromArray;
  let largeSet = [10000, 30000, 50000];

  let targets = [
    (
      "Belt.Array.concat",
      n => {
        let ar =
          A.range(1, n)
          ->A.reduce(A.make(0, 0), (ar, v) => ar->A.concat([|v|]));
        expect(ar->A.length) |> toBe(n);
      },
    ),
    (
      "Js.Array2.concat",
      n => {
        let ar =
          A.range(1, n)
          ->A.reduce(A.make(0, 0), (ar, v) => ar->Js.Array2.concat([|v|]));
        expect(ar->A.length) |> toBe(n);
      },
    ),
    (
      "Js.Vector.append",
      n => {
        let ar =
          A.range(1, n)
          ->A.reduce(A.make(0, 0), (ar, v) => {ar |> Js.Vector.append(v)});
        expect(ar->A.length) |> toBe(n);
      },
    ),
    (
      "Garter.Vector.push",
      n => {
        let v = V.fromArray(A.range(1, n));
        expect(v->V.length) |> toBe(n);
      },
    ),
  ];

  targets->Belt.List.forEach(((name, f)) => {
    testAll(name ++ " (small)", smallSet, f);
    testAll(name ++ " (large)", largeSet, f);
  });
});

describe("Vector.push", () => {
  testAll(
    "fromArray",
    A.range(1, 32)->Belt.List.fromArray,
    n => {
      let v = V.fromArray(A.range(1, n));
      expect(v->V.length) |> toBe(n);
    },
  );

  testAll(
    "fromArray (large)",
    A.rangeBy(100, 10000, ~step=100)->Belt.List.fromArray,
    n => {
      let v = V.fromArray(A.range(1, n));
      expect(v->V.length) |> toBe(n);
    },
  );
});

let pushpop = (n, m) => {
  let v = V.fromArray(A.range(1, n));
  A.range(1, m)->A.reduce(v, (v, _) => v->V.pop);
};

describe("Vector.pop", () => {
  testAll(
    "pushpop (push > pop)",
    [(100, 50), (100, 100), (10000, 5000)],
    ((n, m)) =>
    expect(pushpop(n, m)->V.length) |> toBe(n - m)
  )
});

describe("Vector.get", () => {
  let v = pushpop(20000, 10000);
  test("random access (10,000 times)", () => {
    let every =
      A.range(1, 10000)
      ->A.every(_ => {
          let idx = Js.Math.random_int(0, 10000);
          v->V.getExn(idx) == idx + 1;
        });
    expect(every) |> toBeTruthy;
  });

  testAll("out of bounds", [(-1), 10000], idx => {
    expect(() =>
      v->V.getExn(idx)
    ) |> toThrow
  });
});

describe("Vector.set", () => {
  let size = 100000;
  let v = V.fromArray(A.range(1, size));
  test({j|random update ($size times)|j}, () => {
    let v' =
      A.range(1, size)
      ->A.shuffle
      ->A.reduce(v, (v, idx) => v->V.setExn(idx - 1, idx * (-1)));
    let every = v'->V.toArray->A.every(x => x < 0);

    expect(every) |> toBeTruthy;
  });

  let ar = A.range(1, size);
  test({j|mutable random update ($size times)|j}, () => {
    A.range(1, size)
    ->A.shuffle
    ->A.forEach(idx => ar->A.setUnsafe(idx - 1, idx * (-1)));
    let every = ar->A.every(x => x < 0);

    expect(every) |> toBeTruthy;
  });
});
