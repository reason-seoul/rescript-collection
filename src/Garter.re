module Array = Garter_Array;

module Id = Garter_Id;

module Int = Garter_Int;

module List = Garter_List;

module Obj = Garter_Obj;

module Vector = Garter_Vector

module String = {
  include Js.String2;

  let toArray = s => Js.String2.castToArrayLike(s)->Js.Array2.from;

  let charCode = s => {
    int_of_float(Js.String2.charCodeAt(s, 0));
  };

  [@bs.val] external parseInt: (t, ~radix: int=?) => int = "parseInt";

  [@bs.send] external padStart: (t, int, t) => t = "padStart";
};

module Pair = {
  let first = ((first, _)) => first;
  let second = ((_, second)) => second;
};
