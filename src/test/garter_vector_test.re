open Garter.Vector;
// 초기화 테스트

assert(make()->length == 0);

// make()->debug;
// make()->push(1)->debug;
// make()->push(1)->push(2)->debug;
// make()->push(1)->push(2)->push(3)->debug;
// make()->push(1)->push(2)->push(3)->push(4)->debug;
// make()->push(1)->push(2)->push(3)->push(4)->push(5)->debug;
// make()->push(1)->push(2)->push(3)->push(4)->push(5)->push(6)->debug;

// case 2)
// make()->push(1)->push(2)->push(3)->push(4)->push(5)->push(6)->push(7)->debug;
let n = 13;
assert(fromArray(Belt.Array.range(1,n))->length == n);

// n개 추가 - m개 제거
// N > M
// => size
// list에 한거랑
