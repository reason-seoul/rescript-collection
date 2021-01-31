module List = {
  type t('value);

  [@bs.module "immutable"]
  external fromArray: array('value) => t('value) = "List";

  [@bs.send]
  external filter: (t('value), 'value => bool) => t('value) = "filter";
  [@bs.send]
  external forEach: (t('value), ('value, int, t('value)) => bool) => int =
    "forEach";
  [@bs.send] external toArray: t('value) => array('value) = "toArray";
  [@bs.send] [@bs.return nullable]
  external first: t('value) => option('value) = "first";
  [@bs.send] external count: t('value) => int = "count";
  [@bs.send] external push: (t('value), 'value) => t('value) = "push";
  [@bs.send] external isEmpty: t('value) => bool = "isEmpty";
  [@bs.send]
  external map:
    (t('value), ('value, int, t('value)) => 'value2) => t('value2) =
    "map";
  [@bs.send]
  external reduce: (t('value), ('acc, 'value) => 'acc, 'acc) => 'acc =
    "reduce";

  [@bs.send] external get: (t('value), int) => 'value = "get";

  [@bs.send] external set: (t('value), int, 'value) => t('value) = "set";
};
