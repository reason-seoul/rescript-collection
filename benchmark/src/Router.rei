type t =
  | Index
  | Suite(Suites.Routes.key);

let fromString: string => t;
let toString: t => string;

let name: t => string;

let menu: array(t);

let useUrl: unit => t;

module HashLink: {
  [@react.component]
  let make:
    (~children: React.element, ~to_: t, ~className: string=?) => React.element;
};
