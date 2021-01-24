type t;

[@bs.module "mori"] external vector: unit => t = "vector";
[@bs.module "mori"] external into: (t, array('a)) => t = "into";
[@bs.module "mori"] external conj: (t, 'a) => t = "conj";

[@bs.module "mori"] external nth: (t, int) => t = "nth";

[@bs.module "mori"] external assoc: (t, 'key, 'value) => t = "assoc";
