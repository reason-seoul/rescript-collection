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
module V = Re_Vector;

module Push = {
  let smallN = 1000;
  let largeN = 100000;

  let vectorCase = n => {
    name: {j|Re_Vector.push|j},
    f:
      (.) => {
        A.range(1, n)->A.reduce(V.make(), (v, i) => V.push(v, i))->Any;
      },
    code: {j|A.range(1, $n)->A.reduce(V.make(), (v, i) => V.push(v, i))|j},
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
    code: {j|A.range(1, $n)\n->A.reduce(ImmutableJs.List.fromArray([||]), (l, i) => ImmutableJs.List.push(l, i))|j},
  };

  // let benchmarks = [|
  //   {

  //   {
  //     name: "Js.Array2.push (mutable)",
  //     f:
  //       (.) => {
  //         let ar = [||];
  //         A.range(1, n)->A.forEach(v => ar->Js.Array2.push(v)->ignore)->Any;
  //       },
  //     code: "let ar = [||];\nA.range(1, n)->A.forEach(v => ar->Js.Array2.push(v)->ignore)",
  //   },
  // |];

  let smallSuite = {
    name: {j|Append last (n=$smallN)|j},
    setup: {j|let smallN=$smallN;|j},
    benchmarks: [|
      vectorCase(smallN),
      immutableJsCase(smallN),
      {
        name: "Belt.Array.concat",
        f:
          (.) => {
            A.range(1, smallN)
            ->A.reduce(A.make(0, 0), (ar, v) => ar->A.concat([|v|]))
            ->Any;
          },
        code: {j|A.range(1, $smallN)->A.reduce(A.make(0, 0), (ar, v) => ar->A.concat([|v|]))|j},
      },
      {
        name: "Js.Array2.concat",
        f:
          (.) => {
            A.range(1, smallN)
            ->A.reduce(A.make(0, 0), (ar, v) => ar->Js.Array2.concat([|v|]))
            ->Any;
          },
        code: {j|A.range(1, $smallN)\n->A.reduce(A.make(0, 0), (ar, v) => ar->Js.Array2.concat([|v|]))|j},
      },
    |],
  };

  let largeSuite = {
    name: {j|Append last (n=$largeN)|j},
    setup: {j|let largeN=$largeN;|j},
    benchmarks: [|vectorCase(largeN), immutableJsCase(largeN)|],
  };
};

module Routes = {
  type item = {
    suite: t,
    url: string,
  };

  /* Register the route to your benchmark by giving it a variant here. */
  type key =
    | PushSmall
    | PushLarge;

  /* Make sure the URLs are the same in both functions! */

  let map =
    fun
    | PushSmall => {suite: Push.smallSuite, url: "append-last-small"}
    | PushLarge => {suite: Push.largeSuite, url: "append-last-large"};

  let fromUrl =
    fun
    | "append-last-small" => Some(PushSmall)
    | "append-last-large" => Some(PushLarge)
    | _ => None;

  /* The main menu uses this array to list pages. */
  let routes = [|PushSmall, PushLarge|];
};
