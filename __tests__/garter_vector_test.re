open Garter.Vector;
open Jest;
open Belt;

// 초기화 테스트
describe("Vector", () => {
  open Expect;
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

testAll("1");
