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

module AppendLast = {
  let name = "Append last";
  let n = 30000;
  let setup = {j|let n = $n|j};

  let benchmarks = [|
    {
      name: "Belt.Array.concat",
      f:
        (.) => {
          A.range(1, n)
          ->A.reduce(A.make(0, 0), (ar, v) => ar->A.concat([|v|]))
          ->Any;
        },
      code: "A.range(1, n)->A.reduce(A.make(0, 0), (ar, v) => ar->A.concat([|v|]))",
    },
    {
      name: "Js.Array2.concat",
      f:
        (.) => {
          A.range(1, n)
          ->A.reduce(A.make(0, 0), (ar, v) => ar->Js.Array2.concat([|v|]))
          ->Any;
        },
      code: "A.range(1, n)\n->A.reduce(A.make(0, 0), (ar, v) => ar->Js.Array2.concat([|v|]))",
    },
    {
      name: "Re_Vector.push",
      f:
        (.) => {
          A.range(1, n)->A.reduce(V.make(), (v, i) => V.push(v, i))->Any;
        },
      code: "A.range(1, n)->A.reduce(V.make(), (v, i) => V.push(v, i))",
    },
    {
      name: "Js.Array2.push (mutable)",
      f:
        (.) => {
          let ar = [||];
          A.range(1, n)->A.forEach(v => ar->Js.Array2.push(v)->ignore)->Any;
        },
      code: "let ar = [||];\nA.range(1, n)->A.forEach(v => ar->Js.Array2.push(v)->ignore)",
    },
  |];
  let suite = {name, setup, benchmarks};
};

module Routes = {
  type item = {
    suite: t,
    url: string,
  };

  /* Register the route to your benchmark by giving it a variant here. */
  type key =
    | AppendLast;

  /* Make sure the URLs are the same in both functions! */

  let map =
    fun
    | AppendLast => {suite: AppendLast.suite, url: "append-last"};

  let fromUrl =
    fun
    | "append-last" => Some(AppendLast)
    | _ => None;

  /* The main menu uses this array to list pages. */
  let routes = [|
    AppendLast,
  |];
};
