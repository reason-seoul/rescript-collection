module StringComparable =
  Belt.Id.MakeComparableU({
    type t = string;
    let cmp = (. a, b) => Js.String2.localeCompare(a, b)->int_of_float;
  });
