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

describe("Belt.Array vs. Js.Array2 vs. Js.Vector vs. Vector", () => {
  let smallSet = A.rangeBy(1000, 5000, ~step=1000)->Belt.List.fromArray;
  let largeSet = [10000, 20000, 30000];

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
      "Vector.push",
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
