open Jest;
open Expect;

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

// describe("Vector.push", () => {
//   testAll(
//     "fromArray",
//     Array.range(1, 32)->List.fromArray,
//     n => {
//       let v = fromArray(Array.range(1, n));
//       expect(v->length) |> toBe(n);
//     },
//   );

//   testAll(
//     "fromArray (large)",
//     Array.rangeBy(100, 10000, ~step=100)->List.fromArray,
//     n => {
//       let v = fromArray(Array.range(1, n));
//       expect(v->length) |> toBe(n);
//     },
//   );
// });

// describe("Vector.pop", () => {
//   let pushpop = (n, m) => {
//     let v = fromArray(Array.range(1, n));
//     Array.range(1, m)->Array.reduce(v, (v, _) => v->pop);
//   };

//   testAll(
//     "pushpop (push > pop)",
//     Garter.List.orderedPairs(Array.range(1, 100)->List.fromArray),
//     ((m, n)) =>
//     expect(pushpop(n, m)->length) |> toBe(n - m)
//   );
// });
