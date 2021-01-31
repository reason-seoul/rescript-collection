type t;

[@bs.module "mori"] external vector: unit => t = "vector";
[@bs.module "mori"] external into: (t, array('a)) => t = "into";
[@bs.module "mori"] external conj: (t, 'a) => t = "conj";

[@bs.module "mori"] external nth: (t, int) => t = "nth";

[@bs.module "mori"] external assoc: (t, 'key, 'value) => t = "assoc";

[@bs.module "mori"] external map: ('a => 'b, t) => t = "map";

[@bs.module "mori"] external reduce: ('a => 'b, 'a, t) => 'a = "reduce";
