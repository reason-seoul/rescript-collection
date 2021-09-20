type t =
  | Index
  | VectorSuite(Suite.Vector.Routes.key)
  | HashmapSuite(Suite.Hashmap.Routes.key)

let toString = x =>
  switch x {
  | Index => ""
  | VectorSuite(suite) => Suite.Vector.Routes.map(suite).Suite.Vector.Routes.url
  | HashmapSuite(suite) => "hashmap/" ++ Suite.Hashmap.Routes.map(suite).Suite.Hashmap.Routes.url
  }

let fromString = s => {
  switch Js.String2.split(s, "/") {
  | ["hashmap", path] => Suite.Hashmap.Routes.fromUrl(path)->Belt.Option.map(x => HashmapSuite(x))
  | _ => Suite.Vector.Routes.fromUrl(s)->Belt.Option.map(x => VectorSuite(x))
  }->Belt.Option.getWithDefault(Index)
}

let name = x =>
  switch x {
  | Index => "Index"
  | VectorSuite(suite) => Suite.Vector.Routes.map(suite).Suite.Vector.Routes.suite.Suite.Vector.name
  | HashmapSuite(suite) =>
    Suite.Hashmap.Routes.map(suite).Suite.Hashmap.Routes.suite.Suite.Hashmap.name
  }

let vectorMenu = Belt.Array.map(Suite.Vector.Routes.routes, a => VectorSuite(a))
let hashmapMenu = Belt.Array.map(Suite.Hashmap.Routes.routes, a => HashmapSuite(a))

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
