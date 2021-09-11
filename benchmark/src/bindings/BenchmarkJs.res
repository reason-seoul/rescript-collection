@ocaml.doc("
 * Zero-runtime bindings for Benchmark.js (https://benchmarkjs.com/)
 ")
module Stats = {
  type t = {
    deviation: float,
    mean: float,
    moe: float,
    rme: float,
    sample: array<float>,
    variance: float,
  }
}

module Times = {
  type t = {
    cycle: float,
    elapsed: float,
    period: float,
    timeStamp: float,
  }
}

module Benchmark = {
  type t = {
    aborted: bool,
    name: string,
    hz: float,
    stats: Stats.t,
  }

  @send external toString: t => string = "toString"
}

module Event = {
  type t<'currentTarget, 'target, 'result> = {
    aborted: bool,
    cancelled: bool,
    currentTarget: 'currentTarget,
    result: 'result,
    timeStamp: float,
    type_: string,
    target: 'target,
  }
}

module Options = {
  type t<'currentTarget, 'target, 'result>
  @obj
  external make: (
    ~async: bool=?,
    ~defer: bool=?,
    ~delay: float=?,
    ~id: string=?,
    ~initCount: int=?,
    ~maxTime: float=?,
    ~minSamples: int=?,
    ~minTime: float=?,
    ~name: string=?,
    ~onAbort: (. Event.t<'currentTarget, 'target, 'result>) => unit=?,
    ~onComplete: (. Event.t<'currentTarget, 'target, 'result>) => unit=?,
    ~onCycle: (. Event.t<'currentTarget, 'target, 'result>) => unit=?,
    ~onError: (. Event.t<'currentTarget, 'target, 'result>) => unit=?,
    ~onReset: (. Event.t<'currentTarget, 'target, 'result>) => unit=?,
    ~onStart: (. Event.t<'currentTarget, 'target, 'result>) => unit=?,
    unit,
  ) => t<'currentTarget, 'target, 'result> = ""
}

module Suite = {
  type t = Js.Dict.t<Benchmark.t>

  @get external name: t => string = "name"
  @get external length: t => int = "length"
  @get external aborted: t => bool = "aborted"

  @module("benchmark") @new external make: string => t = "Suite"

  @send
  external add: (
    t,
    ~name: string,
    ~f: /* We must guarantee this won't be curried at runtime. */
    (. unit) => 'result,
    ~options: Options.t<Benchmark.t, Benchmark.t, 'result>=?,
    unit,
  ) => t = "add"

  @send
  external on: (
    t,
    [#cycle | #start | #complete],
    @uncurry (Event.t<t, Benchmark.t, 'result> => 'result),
  ) => t = "on"

  type options
  @obj
  external options: (~async: bool=?, ~queued: bool=?, unit) => options = ""

  @send external run: (t, ~options: options=?, unit) => unit = "run"

  @send external abort: t => unit = "abort"

  @send external clone: (t, ~options: options=?, unit) => t = "clone"
}

module Platform = {
  module Os = {
    type t = {
      architecture: Js.Nullable.t<int>,
      family: Js.Nullable.t<string>,
      version: Js.Nullable.t<string>,
    }

    @send external toString: t => string = "toString"
  }

  type t = {
    description: Js.Nullable.t<string>,
    layout: Js.Nullable.t<string>,
    product: Js.Nullable.t<string>,
    name: Js.Nullable.t<string>,
    manufacturer: Js.Nullable.t<string>,
    os: Js.Nullable.t<Os.t>,
    prerelease: Js.Nullable.t<string>,
    version: Js.Nullable.t<string>,
  }

  @send external toString: t => string = "toString"
}

module Support = {
  type t = {
    browser: bool,
    decompilation: bool,
    timeout: bool,
  }
}

module Browser = {
  @ocaml.doc("
   * Benchmark.js is incompatible with some bundlers, so it has to be loaded
   * into the browsers global \"window\" object. These function are for those
   * situations.
   ")
  @scope(("window", "Benchmark"))
  @val
  external formatNumber: float => string = "formatNumber"

  @scope(("window", "Benchmark")) @val
  external platform: Platform.t = "platform"

  module Suite = {
    @scope(("window", "Benchmark")) @new
    external make: string => Suite.t = "Suite"
  }
}
