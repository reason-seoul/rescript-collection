type t;

[@bs.module "mori"] external vector: unit => t = "vector";
[@bs.module "mori"] external into: (t, array('a)) => t = "into";
[@bs.module "mori"] external conj: (t, 'a) => t = "conj";
