module Array = Garter_Array;

module Id = Garter_Id;

module Int = Garter_Int;

module List = Garter_List;

module Obj = Garter_Obj;

module Vector = Garter_Vector;

module String = Garter_String;

module Pair = {
  let first = ((first, _)) => first;
  let second = ((_, second)) => second;
};

module Queue = Garter_Queue;
