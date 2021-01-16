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

module Strings = {
  [@bs.module "nanoid"] external randomString: unit => string = "nanoid";
  let strings = Belt.List.makeBy(100, _ => randomString());
  let stringsArr = Belt.List.toArray(strings);

  let setup = {j|[@bs.module "nanoid"] external randomString: unit => string = "nanoid";
let strings = Belt.List.makeBy(100, _ => randomString());
let stringsArr = Belt.List.toArray(strings);|j};

  let benchmarks = [|
    {
      name: "Pervasives.(++)",
      f:
        (.) => {
          let rec loop = (acc, l) =>
            switch (l) {
            | [] => acc
            | [a, ...l] => loop(a ++ acc, l)
            };
          loop("", strings)->Any;
        },
      code: {j|let rec loop = (acc, l) =>
  switch (l) {
  | [] => acc
  | [a, ...l] => loop(a ++ acc, l)
  };
loop("", strings);|j},
    },
    {
      name: "String.concat",
      f: (.) => Any(strings |> String.concat("")),
      code: {j|strings |> String.concat("");|j},
    },
    {
      name: "Js.Array.joinWith",
      f: (.) => Any(stringsArr |> Js.Array.joinWith("")),
      code: {j|stringsArr |> Js.Array.joinWith("");|j},
    },
    {
      name: "Js.String.concatMany",
      f: (.) => Any(stringsArr->Js.String.concatMany("")),
      code: {j|stringsArr->Js.String.concatMany("");|j},
    }
  |];

  let name = "Concatenate 100 strings";

  let suite = {setup, name, benchmarks};
};

module ListArray = {
  let name = "List vs Array: Map 100 items";

  let ints = Belt.List.makeBy(100, i => i);
  let intsArr = Belt.List.toArray(ints);

  let setup = {j|let ints = Belt.List.makeBy(100, i => i);
let intsArr = Belt.List.toArray(ints);|j};

  let benchmarks = [|
    {
      name: "List.map",
      f: (.) => Any(ints |> List.map(x => x + 1)),
      code: "ints |> List.map(x => x + 1)",
    },
    {
      name: "Belt.List.map",
      f: (.) => ints->Belt.List.map(x => x + 1)->Any,
      code: "ints->Belt.List.map(x => x + 1)",
    },
    {
      name: "Belt.List.mapU",
      f: (.) => ints->Belt.List.mapU((. x) => x + 1)->Any,
      code: "ints->Belt.List.mapU((. x) => x + 1)",
    },
    {
      name: "Array.map",
      f: (.) => Any(intsArr |> Array.map(x => x + 1)),
      code: "intsArr |> Array.map(x => x + 1)",
    },
    {
      name: "Belt.Array.map",
      f: (.) => intsArr->Belt.Array.map(x => x + 1)->Any,
      code: "intsArr->Belt.Array.map(x => x + 1)",
    },
    {
      name: "Belt.Array.mapU",
      f: (.) => intsArr->Belt.Array.mapU((. x) => x + 1)->Any,
      code: "intsArr->Belt.Array.mapU((. x) => x + 1)",
    },
    {
      name: "Js.Array.map",
      f: (.) => Any(intsArr |> Js.Array.map(x => x + 1)),
      code: "intsArr |> Js.Array.map(x => x + 1)",
    },
  |];

  let map = {name, setup, benchmarks};

  let name = "List vs Array: access first item";

  let benchmarks = [|
    {
      name: "pattern match",
      f:
        (.) => {
          let x =
            switch (ints) {
            | [x, ..._] => Some(x)
            | [] => None
            };
          Any(x);
        },
      code: {j|let x =
  switch (ints) {
  | [x, ..._] => Some(x)
  | [] => None
  };|j},
    },
    {name: "List.hd", f: (.) => ints->List.hd->Any, code: "ints->List.hd;"},
    {
      name: "Belt.List.head",
      f: (.) => ints->Belt.List.head->Any,
      code: "ints->Belt.List.head;",
    },
    {
      name: "Belt.List.headExn",
      f: (.) => ints->Belt.List.headExn->Any,
      code: "ints->Belt.List.headExn;",
    },
    {name: "Array.get", f: (.) => intsArr[0]->Any, code: "intsArr[0];"},
    {
      name: "Belt.Array.get",
      f: (.) => Belt.(intsArr[0])->Any,
      code: "Belt.(intsArr[0]);",
    },
    {
      name: "Belt.Array.getExn",
      f: (.) => intsArr->Belt.Array.getExn(0)->Any,
      code: "intsArr->Belt.Array.getExn(0);",
    },
  |];

  let head = {setup, name, benchmarks};
};

module Maps = {
  let name = "Maps: Getting a key from a map with 100 items";

  [@bs.module "nanoid"] external randomString: unit => string = "nanoid";

  module JsMap = {
    type t('key, 'value);
    [@bs.new]
    external fromArray: array(('key, 'value)) => t('key, 'value) = "Map";
    [@bs.new] external copy: t('key, 'value) => t('key, 'value) = "Map";
    [@bs.send] external set: (t('key, 'value), 'key, 'value) => unit = "set";
    [@bs.send] external get: (t('key, 'value), 'key) => 'value = "get";
  };

  module StringMap = Map.Make(String);
  let strings = Belt.Array.makeBy(100, _ => (randomString(), randomString()));
  let dict = Js.Dict.fromArray(strings);
  let jsMap = JsMap.fromArray(strings);
  let hashmap = Belt.HashMap.String.fromArray(strings);
  let map = Belt.Map.String.fromArray(strings);
  let stdlibMap =
    Belt.Array.reduce(strings, StringMap.empty, (acc, (k, v)) =>
      StringMap.add(k, v, acc)
    );
  let (key, _) = strings[0];

  let setup = {j|[@bs.module "nanoid"] external randomString: unit => string = "nanoid";

module JsMap = {
  type t('key, 'value);
  [@bs.new] external fromArray: array(('key, 'value)) => t('key, 'value) = "Map";
  [@bs.new] external copy: t('key, 'value) => t('key, 'value) = "Map";
  [@bs.send] external set: (t('key, 'value), 'key, 'value) => unit = "set";
  [@bs.send] external get: (t('key, 'value), 'key) => 'value = "get";
};

module StringMap = Map.Make(String);
let strings = Belt.Array.makeBy(100, _ => (randomString(), randomString()));
let dict = Js.Dict.fromArray(strings);
let jsMap = JsMap.fromArray(strings);
let hashmap = Belt.HashMap.String.fromArray(strings);
let map = Belt.Map.String.fromArray(strings);
let stdlibMap =
  Belt.Array.reduce(strings, StringMap.empty, (acc, (k, v)) =>
    StringMap.add(k, v, acc)
  );
let (key, _) = strings[0];|j};

  let benchmarks = [|
    {
      name: "Map.Make(String).find",
      f: (.) => Any(stdlibMap |> StringMap.find(key)),
      code: "stdlibMap |> StringMap.find(key)",
    },
    {
      name: "Belt.Map.String.get",
      f: (.) => map->Belt.Map.String.get(key)->Any,
      code: "map->Belt.Map.String.get(key)",
    },
    {
      name: "Belt.HashMap.String.get",
      f: (.) => hashmap->Belt.HashMap.String.get(key)->Any,
      code: "hashMap->Belt.HashMap.String.get(key)",
    },
    {
      name: "Js.Dict.get",
      f: (.) => dict->Js.Dict.get(key)->Any,
      code: "dict->Js.Dict.get(key)",
    },
    {
      name: "JsMap get",
      f: (.) => jsMap->JsMap.get(key)->Any,
      code: "jsMap->JsMap.get(key)",
    },
  |];

  let getting = {name, setup, benchmarks};

  let name = "Maps: Immutably setting a key from a map with 100 items";

  [@bs.val] [@bs.scope "Object"]
  external assign: (Js.Dict.t('a), Js.Dict.t('a)) => Js.Dict.t('a) =
    "assign";
  let cloneDict = d => assign(Js.Dict.empty(), d);

  let setup =
    setup
    ++ {j|

[@bs.val] [@bs.scope "Object"]
external assign: (Js.Dict.t('a), Js.Dict.t('a)) => Js.Dict.t('a) =
  "assign";
let cloneDict = d => assign(Js.Dict.empty(), d);|j};

  let benchmarks = [|
    {
      name: "Map.Make(String).add",
      f: (.) => Any(stdlibMap |> StringMap.add(key, "a")),
      code: {j|stdlibMap |> StringMap.add(key, "a")|j},
    },
    {
      name: "Belt.Map.String.set",
      f: (.) => map->Belt.Map.String.set(key, "a")->Any,
      code: {j|map->Belt.Map.String.set(key, "a")|j},
    },
    {
      name: {j|Belt.HashMap.String.(copy->set)|j},
      f:
        (.) => {
          let hashmap' = hashmap->Belt.HashMap.String.copy;
          hashmap'->Belt.HashMap.String.set(key, "a");
          Any(hashmap');
        },
      code: {j|let hashmap' = hashmap->Belt.HashMap.String.copy;
hashmap'->Belt.HashMap.String.set(key, "a");|j},
    },
    {
      name: "cloneDict->Js.Dict.set",
      f:
        (.) => {
          let dict' = dict->cloneDict;
          dict'->Js.Dict.set(key, "a");
          Any(dict');
        },
      code: {j|let dict' = dict->cloneDict;
dict'->Js.Dict.set(key, "a");|j},
    },
    {
      name: "JsMap copy->set",
      f:
        (.) => {
          let jsMap' = jsMap->JsMap.copy;
          jsMap'->JsMap.set(key, "a");
          Any(jsMap');
        },
      code: {j|let jsMap' = jsMap->JsMap.copy;
jsMap'->JsMap.set(key, "a");|j},
    },
  |];

  let setting = {name, benchmarks, setup};
};

module ArrayAccess = {
  let name = "Array access";

  let arr = Belt.Array.make(100, "a");

  let setup = {j|let arr = Belt.Array.make(100, "a");|j};

  let benchmarks = [|
    {name: "Array.get", f: (.) => arr[50]->Any, code: "arr[50];"},
    {
      name: "Belt.Array.get",
      f: (.) => Belt.(arr[50]->Any),
      code: "Belt.(arr[50]);",
    },
    {
      name: "Belt.Array.getExn",
      f: (.) => arr->Belt.Array.getExn(50)->Any,
      code: "arr->Belt.Array.getExn(50);",
    },
  |];

  let suite = {setup, name, benchmarks};
};

module ArraySort = {
  let name = "Array sorting";

  let arr = Belt.Array.makeBy(100, _ => Js.Math.random_int(-1000, 1000));
  let intCmp = (. a: int, b: int) => compare(a, b);

  let setup = {j|let arr = Belt.Array.makeBy(100, _ => Js.Math.random_int(-1000, 1000));
let intCmp = (. a: int, b: int) => compare(a, b);|j};

  let benchmarks = [|
    {
      name: "Belt.SortArray.Int",
      code: "arr->Belt.SortArray.Int.stableSort;",
      f: (.) => arr->Belt.SortArray.Int.stableSort->Any,
    },
    {
      name: "Belt.SortArray.stableSortBy",
      code: "arr->Belt.SortArray.stableSortBy(compare);",
      f: (.) => arr->Belt.SortArray.stableSortBy(compare)->Any,
    },
    {
      name: "Belt.SortArray.stableSortByU",
      code: "arr->Belt.SortArray.stableSortByU(intCmp);",
      f: (.) => arr->Belt.SortArray.stableSortByU(intCmp)->Any,
    },
    {
      name: "Js.Array.(copy |> sortInPlace)",
      code: "arr |> Js.Array.copy |> Js.Array.sortInPlace;",
      f: (.) => Any(arr |> Js.Array.copy |> Js.Array.sortInPlace),
    },
    {
      name: "Js.Array.(copy |> sortInPlaceWith)",
      code: "arr |> Js.Array.copy |> Js.Array.sortInPlaceWith(compare);",
      f:
        (.) =>
          Any(arr |> Js.Array.copy |> Js.Array.sortInPlaceWith(compare)),
    },
  |];

  let suite = {name, setup, benchmarks};
};

module ImmutableObjUpdate = {
  let name = "Immutable record/object update";
  open Suites_Input.ImmutableObjUpdate;

  %raw
  "
  var tenFieldsJs = {
    a: 1,
    b: \"b\",
    c: 3,
    d: \"d\",
    e: 5,
    f: \"f\",
    g: 7,
    h: \"h\",
    i: 9,
    j: \"j\",
  }";
  let setup = {j|type tenFields = {
  a: int,
  b: string,
  c: int,
  d: string,
  e: int,
  f: string,
  g: int,
  h: string,
  i: int,
  j: string,
};
let tenFields = {
  a: 1,
  b: "b",
  c: 3,
  d: "d",
  e: 5,
  f: "f",
  g: 7,
  h: "h",
  i: 9,
  j: "j",
};
%raw
"
var tenFieldsJs = {
  a: 1,
  b: \\"b\\",
  c: 3,
  d: \\"d\\",
  e: 5,
  f: \\"f\\",
  g: 7,
  h: \\"h\\",
  i: 9,
  j: \\"j\\",
}";|j};
  let benchmarks = [|
    {
      name: "Record update",
      code: "let tenFields' = {...tenFields, a: 2};",
      f:
        (.) => {
          let tenFields' = {...tenFields, a: 2};
          Any(tenFields');
        },
    },
    {
      name: "JS spread syntax",
      code: {j|let tenFieldsJs': tenFields = [%bs.raw "{...tenFieldsJs, a: 2}"];|j},
      f:
        (.) => {
          let tenFieldsJs': tenFields = [%raw "{...tenFieldsJs, a: 2}"];
          Any(tenFieldsJs');
        },
    },
    {
      name: "JS Object.assign",
      code: {j|let tenFieldsJs': tenFields = [%raw "Object.assign({}, tenFieldsJs, {a: 2})"];|j},
      f:
        (.) => {
          let tenFieldsJs': tenFields = [%raw
            "Object.assign({}, tenFieldsJs, {a: 2})"
          ];
          Any(tenFieldsJs');
        },
    },
  |];

  let suite = {name, setup, benchmarks};
};

module DestructureTuple = {
  let name = "Destructure tuples";

  open Suites_Input.DestructureTuple;

  let setup = {j|
let two = (1., 2.);
let eight = (1., 2., 3., 4., 5., 6., 7., 8.);
%raw
"
var twoJs = [1, 2];
var eightJs = [1, 2, 3, 4, 5, 6, 7, 8]";
|j};
  %raw
  "
var twoJs = [1, 2];
var eightJs = [1, 2, 3, 4, 5, 6, 7, 8]";

  let twoJsFn: (. unit) => any = [%raw
    "function () {
  var [a, b] = twoJs;
  return a + b;
}"
  ];

  let eightJsFn: (. unit) => any = [%raw
    "function () {
  var [a, b, c, d, e, f, g, h] = eightJs;
  return a + b + c + d + e + f + g + h;
}"
  ];

  let benchmarks = [|
    {
      name: "Reason: destructure two-tuple",
      code: {j|let (a, b) = two;
a +. b;|j},
      f:
        (.) => {
          let (a, b) = two;
          Any(a +. b);
        },
    },
    {
      name: "Reason: destructure eight-tuple",
      code: {j|let (a, b, c, d, e, f, g, h) = eight;
a +. b +. c +. d +. e +. f +. g +. h;
|j},
      f:
        (.) => {
          let (a, b, c, d, e, f, g, h) = eight;
          Any(a +. b +. c +. d +. e +. f +. g +. h);
        },
    },
    {
      name: "JavaScript: destructure two-tuple",
      code: {j|var [a, b] = twoJs;
a + b;|j},
      f: twoJsFn,
    },
    {
      name: "JavaScript: destructure eight-tuple",
      code: {j|var [a, b, c, d, e, f, g, h] = eightJs;
a + b + c + d + e + f + g + h;|j},
      f: eightJsFn,
    },
  |];

  let suite = {name, setup, benchmarks};
};

module DestructureRecord = {
  let name = "Destructure records";

  open! Suites_Input.DestructureRecord;

  %raw
  "
var fourFieldsJs = {a: 1, b: 2, c: 3, d: 4};
var eightFieldsJs = {e: 1, f: 2, g: 3, h: 4, i: 5, j: 6, k: 7, l: 8};
  ";
  let setup = {j|type fourFields = {
  a: float,
  b: float,
  c: float,
  d: float,
};
let fourFields = {a: 1., b: 2., c: 3., d: 4.};
type eightFields = {
  e: float,
  f: float,
  g: float,
  h: float,
  i: float,
  j: float,
  k: float,
  l: float,
};
let eightFields = {e: 1., f: 2., g: 3., h: 4., i: 5., j: 6., k: 7., l: 8.};
%raw
"
var fourFieldsJs = {a: 1, b: 2, c: 3, d: 4};
var eightFieldsJs = {e: 1, f: 2, g: 3, h: 4, i: 5, j: 6, k: 7, l: 8};
";|j};

  let fourJsFn: (. unit) => any = [%raw
    "function () {
  var {a, b, c, d} = fourFieldsJs;
  return a + b + c + d;
}"
  ];

  let eightJsFn: (. unit) => any = [%raw
    "function () {
  var {e, f, g, h, i, j, k, l} = eightFieldsJs;
  return e + f + g + h + i + j + k + l;
}"
  ];

  let benchmarks = [|
    {
      name: "Reason: four fields",
      code: {j|let {a, b, c, d} = fourFields;
a +. b +. c +. d;|j},
      f:
        (.) => {
          let {a, b, c, d} = fourFields;
          Any(a +. b +. c +. d);
        },
    },
    {
      name: "Reason: eight fields",
      code: {j|let {e, f, g, h, i, j, k, l} = eightFields;
e +. f +. g +. h +. i +. j +. k +. l;|j},
      f:
        (.) => {
          let {e, f, g, h, i, j, k, l} = eightFields;
          Any(e +. f +. g +. h +. i +. j +. k +. l);
        },
    },
    {
      name: "JavaScript: four fields",
      code: {j|var {a, b, c, d} = fourFieldsJs;
a + b + c + d|j},
      f: fourJsFn,
    },
    {
      name: "JavaScript: eight fields",
      code: {j|var {e, f, g, h, i, j, k, l} = eightFieldsJs;
e + f + g + h + i + j + k + l;|j},
      f: eightJsFn,
    },
  |];

  let suite = {name, setup, benchmarks};
};

/* Add your own benchmark here. */

/*
  module MyBenchmark = {
    let name = "";
    let setup = "";
    let benchmarks = [|{name: "", f: (.) => (), code: "()"}|];
    let suite = {name, setup, benchmarks};
  };
 */

module Routes = {
  type item = {
    suite: t,
    url: string,
  };

  /* Register the route to your benchmark by giving it a variant here. */
  type key =
    | Strings
    | ListArrayMap
    | ListArrayHead
    | MapsGet
    | MapsSet
    | ArrayAccess
    | ArraySort
    | ImmutableObjUpdate
    | DestructureTuple
    | DestructureRecord;

  /* Make sure the URLs are the same in both functions! */

  let map =
    fun
    | Strings => {suite: Strings.suite, url: "concat-strings"}
    | ListArrayMap => {suite: ListArray.map, url: "list-array-map"}
    | ListArrayHead => {suite: ListArray.head, url: "list-array-head"}
    | MapsGet => {suite: Maps.getting, url: "maps-get"}
    | MapsSet => {suite: Maps.setting, url: "maps-set"}
    | ArrayAccess => {suite: ArrayAccess.suite, url: "array-access"}
    | ArraySort => {suite: ArraySort.suite, url: "array-sort"}
    | ImmutableObjUpdate => {
        suite: ImmutableObjUpdate.suite,
        url: "immutable-obj-update",
      }
    | DestructureTuple => {
        suite: DestructureTuple.suite,
        url: "destructure-tuple",
      }
    | DestructureRecord => {
        suite: DestructureRecord.suite,
        url: "destructure-record",
      };

  let fromUrl =
    fun
    | "concat-strings" => Some(Strings)
    | "list-array-map" => Some(ListArrayMap)
    | "list-array-head" => Some(ListArrayHead)
    | "maps-get" => Some(MapsGet)
    | "maps-set" => Some(MapsSet)
    | "array-access" => Some(ArrayAccess)
    | "array-sort" => Some(ArraySort)
    | "immutable-obj-update" => Some(ImmutableObjUpdate)
    | "destructure-tuple" => Some(DestructureTuple)
    | "destructure-record" => Some(DestructureRecord)
    | _ => None;

  /* The main menu uses this array to list pages. */
  let routes = [|
    ImmutableObjUpdate,
    DestructureTuple,
    DestructureRecord,
    Strings,
    ListArrayMap,
    ListArrayHead,
    MapsGet,
    MapsSet,
    ArrayAccess,
    ArraySort,
  |];
};
