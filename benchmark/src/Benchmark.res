@unboxed
type rec any = Any('a): any

type t = {
  name: string,
  code: string,
  f: (. unit) => any,
}
