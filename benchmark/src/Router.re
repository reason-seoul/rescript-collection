type t =
  | Index
  | Suite(Suites.Routes.key);

let toString =
  fun
  | Index => ""
  | Suite(suite) => Suites.Routes.map(suite).Suites.Routes.url;

let fromString = s =>
  switch (Suites.Routes.fromUrl(s)) {
  | Some(suite) => Suite(suite)
  | None => Index
  };

let name =
  fun
  | Index => "Index"
  | Suite(suite) => Suites.Routes.map(suite).Suites.Routes.suite.Suites.name;

let menu = Belt.Array.map(Suites.Routes.routes, a => Suite(a));

let useUrl = () => ReasonReact.Router.(useUrl().hash)->fromString;

module HashLink = {
  [@react.component]
  let make = (~children, ~to_, ~className=?) => {
    let href = toString(to_);
    <a href={"#" ++ href} ?className> children </a>;
  };
};
