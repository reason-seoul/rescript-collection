open Garter.Vector;
open Belt;
open Jest;
open Expect;

// 초기화 테스트
describe("Vector", () => {
  test("empty", () =>
    expect(make()->length) |> toBe(0)
  );

  testAll(
    "fromArray",
    Array.range(1, 32)->List.fromArray,
    n => {
      let v = fromArray(Array.range(1, n));
      expect(v->length) |> toBe(n);
    },
  );

  testAll(
    "fromArray (large)",
    Array.rangeBy(100, 10000, ~step=100)->List.fromArray,
    n => {
      let v = fromArray(Array.range(1, n));
      expect(v->length) |> toBe(n);
    },
  );
});

describe("Vector.pop", () => {
  let pushpop = (n, m) => {
    let v = fromArray(Array.range(1, n));
    Array.range(1, m)->Array.reduce(v, (v, _) => v->pop);
  };

  testAll(
    "pushpop (push > pop)",
    Garter.List.orderedPairs(Array.range(1, 50)->List.fromArray),
    ((m, n)) =>
    expect(pushpop(n, m)->length) |> toBe(n - m)
  );
});

// make()->debug;
// make()->push(1)->debug;
// make()->push(1)->push(2)->debug;
// make()->push(1)->push(2)->push(3)->debug;
// make()->push(1)->push(2)->push(3)->push(4)->debug;
// make()->push(1)->push(2)->push(3)->push(4)->push(5)->debug;
// make()->push(1)->push(2)->push(3)->push(4)->push(5)->push(6)->debug;

// case 2)
// make()->push(1)->push(2)->push(3)->push(4)->push(5)->push(6)->push(7)->debug;
// let n = 14;
// assert(fromArray(Belt.Array.range(1,n))->length == n);

//v->push(15);
// ->Js.log

// n개 추가 - m개 제거
// N > M
// => size
// list에 한거랑
