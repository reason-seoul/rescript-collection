let fromStringExn = s => {
  switch (Belt.Int.fromString(s)) {
  | Some(n) => n
  | None => raise(Failure("fromStringExn"))
  };
};

[@bs.val]
external fromStringWithRadix: (string, ~radix: int) => int = "parseInt";
