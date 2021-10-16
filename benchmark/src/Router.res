type t =
  | Index
  | VectorSuite(Suite.Vector.Routes.key)

let toString = x =>
  switch x {
  | Index => ""
  | VectorSuite(suite) => Suite.Vector.Routes.map(suite).Suite.Vector.Routes.url
  }

let fromString = s => {
  switch Js.String2.split(s, "/") {
  | _ => Suite.Vector.Routes.fromUrl(s)->Belt.Option.map(x => VectorSuite(x))
  }->Belt.Option.getWithDefault(Index)
}

let name = x =>
  switch x {
  | Index => "Index"
  | VectorSuite(suite) => Suite.Vector.Routes.map(suite).Suite.Vector.Routes.suite.Suite.Vector.name
  }

let vectorMenu = Belt.Array.map(Suite.Vector.Routes.routes, a => VectorSuite(a))

let useUrl = () =>
  {
    open RescriptReactRouter
    useUrl().hash
  }->fromString

module HashLink = {
  @react.component
  let make = (~children, ~to_, ~className=?) => {
    let href = toString(to_)
    <a href={"#" ++ href} ?className> children </a>
  }
}
