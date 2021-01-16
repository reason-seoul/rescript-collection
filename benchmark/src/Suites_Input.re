module DestructureTuple = {
  let two = (1., 2.);
  let eight = (1., 2., 3., 4., 5., 6., 7., 8.);
};

module ImmutableObjUpdate = {
  type tenFields = {
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
};

module DestructureRecord = {
  type fourFields = {
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
};
