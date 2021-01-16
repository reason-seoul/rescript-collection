open Belt;
module B = BenchmarkJs;

module Prism = {
  [@bs.val] [@bs.scope ("window", "Prism")]
  external highlightAll: unit => unit = "highlightAll";
};

module DocTitle = {
  let prefix = "Benchmark.bs.js";

  let set = title =>
    Webapi.Dom.(
      document
      ->Document.unsafeAsHtmlDocument
      ->HtmlDocument.setTitle(prefix ++ " - " ++ title)
    );

  let reset = () =>
    Webapi.Dom.(
      document->Document.unsafeAsHtmlDocument->HtmlDocument.setTitle(prefix)
    );
};

type running =
  | NotStarted
  | Started({time: float})
  | Stopped({
      fastest: string,
      slowest: string,
      fastestHz: float,
    });

let reducer = (_oldState, newState) => newState;

let useState = initialState => {
  let (state, dispatch) = React.useReducer(reducer, initialState);
  (state, (. x) => dispatch(x));
};

let percentDiff = (a, b) => floor((b -. a) /. b *. 100.);

type speedRank =
  | Fastest
  | Slower(float)
  | Slowest(float);

let speedRank = (name: string, fastest: string, slowest: string, hz) =>
  if (name == fastest) {
    Fastest;
  } else if (name == slowest) {
    Slowest(hz);
  } else {
    Slower(hz);
  };

module Results = {
  [@react.component]
  let make = (~hz, ~rme, ~sample, ~speedRank) =>
    <div>
      {switch (speedRank) {
       | Fastest =>
         <p className="fastest speedRank"> "fastest"->React.string </p>
       | Slowest(hz') =>
         <>
           <p className="slowest speedRank"> "slowest"->React.string </p>
           <p className="speedRank">
             {percentDiff(hz, hz')->B.Browser.formatNumber
              ++ "% slower"
              |> React.string}
           </p>
         </>
       | Slower(hz') =>
         <p className="speedRank">
           {percentDiff(hz, hz')->B.Browser.formatNumber
            ++ "% slower"
            |> React.string}
         </p>
       }}
      <dl>
        <dt> "operations per second"->React.string </dt>
        <dd> {hz->Js.Math.round->B.Browser.formatNumber->React.string} </dd>
        <dt> "relative margin of error"->React.string </dt>
        <dd>
          {j|±|j}->React.string
          {rme->Js.Math.round->B.Browser.formatNumber->React.string}
          "%"->React.string
        </dd>
        <dt> "samples"->React.string </dt>
        <dd> {sample->Array.size->Int.toString->React.string} </dd>
      </dl>
    </div>;
};

module Item = {
  type status =
    | Queued
    | Running
    | Complete({
        time: float,
        benchmark: B.Benchmark.t,
      });

  [@react.component]
  let make = (~name, ~code, ~f, ~suite, ~suiteRunning) => {
    let (result, setResult) = useState(Queued);
    React.useEffect1(
      () => {
        Prism.highlightAll();
        B.Suite.add(
          suite,
          ~name,
          ~f,
          ~options=
            B.Options.make(
              ~onStart=
                (. B.Event.{currentTarget, _}) =>
                  if (!currentTarget.B.Benchmark.aborted) {
                    setResult(. Running);
                  },
              ~onComplete=
                (. B.Event.{currentTarget, _}) =>
                  if (!currentTarget.B.Benchmark.aborted) {
                    setResult(.
                      Complete({
                        time: Js.Date.now(),
                        benchmark: currentTarget,
                      }),
                    );
                  },
              (),
            ),
          (),
        )
        ->ignore;
        None;
      },
      [|suite|],
    );
    <div className="item">
      <div className="item__body">
        <header className="item__header">
          <h2 className="item__header_h">
            <code> name->React.string </code>
          </h2>
        </header>
        <div className="code item__code">
          <pre>
            <code className="language-reason"> code->React.string </code>
          </pre>
        </div>
      </div>
      <div className="item__results">
        <h3> "Results"->React.string </h3>
        {switch (suiteRunning, result) {
         | (NotStarted, Queued | Running | Complete(_))
         | (Stopped(_), Queued) =>
           <p className="subtle"> "Not started"->React.string </p>
         | (Started({time}), Complete({time: time', _})) when time < time' =>
           <p className="subtle">
             "Done. Waiting for the other tests."->React.string
           </p>
         | (Started(_), Queued | Complete(_)) =>
           <p className="subtle"> "Waiting"->React.string </p>
         | (Started(_) | Stopped(_), Running) =>
           <p className="subtle"> "Running..."->React.string </p>
         | (
             Stopped({fastest, slowest, fastestHz}),
             Complete({
               benchmark: {
                 B.Benchmark.name,
                 hz,
                 stats: B.Stats.{rme, sample, _},
                 _,
               },
               _,
             }),
           ) =>
           <Results
             hz
             rme
             sample
             speedRank={speedRank(name, fastest, slowest, fastestHz)}
           />
         }}
      </div>
    </div>;
  };
};

module SuiteComponent = {
  [@react.component]
  let make = (~benchmarks, ~suite, ~suiteRunning) => {
    <div>
      {benchmarks
       ->Array.map((Suites.{name, code, f}) =>
           <Item key=name name code f suite suiteRunning />
         )
       ->React.array}
    </div>;
  };
};

let getStats = (BenchmarkJs.Event.{currentTarget, _}) => {
  let results =
    currentTarget
    ->B.Suite.length
    ->List.makeBy(Int.toString)
    ->List.keepMap(Js.Dict.get(currentTarget))
    ->List.sort((a, b) => compare(b.B.Benchmark.hz, a.B.Benchmark.hz));
  switch (results) {
  | [] => NotStarted
  | [{B.Benchmark.hz, name, _}] =>
    Stopped({fastest: name, slowest: name, fastestHz: hz})
  | [{B.Benchmark.hz, name: fastest, _}, ...rest] =>
    switch (List.reverse(rest)) {
    | [] => NotStarted
    | [{B.Benchmark.name: slowest, _}, ..._] =>
      Stopped({fastest, slowest, fastestHz: hz})
    }
  };
};

module Wrapper = {
  [@react.component]
  let make = (~benchmarks, ~setup, ~suite) => {
    let (suiteRunning, setRunning) = useState(NotStarted);
    React.useEffect1(
      () => {
        suite
        ->B.Suite.on(`start, (B.Event.{currentTarget, _}) =>
            if (!currentTarget->B.Suite.aborted) {
              setRunning(. Started({time: Js.Date.now()}));
            }
          )
        ->B.Suite.on(`complete, e =>
            if (!e.B.Event.currentTarget->B.Suite.aborted) {
              setRunning(. getStats(e));
            }
          )
        ->ignore;
        Some(() => B.Suite.abort(suite));
      },
      [|suite|],
    );
    React.useEffect0(() => {
      DocTitle.set(suite->B.Suite.name);
      Some(DocTitle.reset);
    });
    <section>
      <header> <h1> {suite->B.Suite.name->React.string} </h1> </header>
      <div className="setup">
        <div className="setup__body">
          <h2> "Setup"->React.string </h2>
          <div className="code">
            <pre>
              <code className="language-reason"> setup->React.string </code>
            </pre>
          </div>
        </div>
        <dl className="setup__platform">
          <dt> "OCaml"->React.string </dt>
          <dd> Sys.ocaml_version->React.string </dd>
          <dt> "Browser"->React.string </dt>
          {switch (B.Browser.platform.B.Platform.name->Js.Nullable.toOption) {
           | None => <dd> "Unknown"->React.string </dd>
           | Some(name) =>
             <dd>
               name->React.string
               {switch (
                  B.Browser.platform.B.Platform.version->Js.Nullable.toOption
                ) {
                | Some(version) => " " ++ version |> React.string
                | None => React.null
                }}
             </dd>
           }}
          <dt> "Operating system"->React.string </dt>
          {switch (B.Browser.platform.B.Platform.os->Js.Nullable.toOption) {
           | None => <dd> "Unknown"->React.string </dd>
           | Some(os) => <dd> {os->B.Platform.Os.toString->React.string} </dd>
           }}
        </dl>
      </div>
      <div className="run">
        <button
          className="run__button"
          disabled={
            switch (suiteRunning) {
            | Started(_) => true
            | NotStarted
            | Stopped(_) => false
            }
          }
          onClick={_ => {
            suite->B.Suite.run(~options=B.Suite.options(~async=true, ()), ())
          }}>
          {switch (suiteRunning) {
           | Started(_) => "Running..."->React.string
           | NotStarted
           | Stopped(_) => "Run"->React.string
           }}
        </button>
      </div>
      <SuiteComponent benchmarks suite suiteRunning />
    </section>;
  };
};

[@react.component]
let make = () => {
  let url = Router.useUrl();
  React.useEffect0(() => {
    DocTitle.reset();
    None;
  });
  <div className="smallscreen-padding">
    <main className="main ">
      <header>
        <p className="site-title">
          <Router.HashLink to_=Router.Index className="site-title__link">
            "Benchmark.bs.js"->React.string
          </Router.HashLink>
        </p>
      </header>
      {switch (url) {
       | Router.Index =>
         <>
           <Pages.About />
           <h2 className="index-header"> "The benchmarks"->React.string </h2>
           <ul className="menu">
             {Router.menu
              ->Array.map(route =>
                  <li className="menu__item" key={Router.toString(route)}>
                    <Router.HashLink to_=route>
                      {Router.name(route)->React.string}
                    </Router.HashLink>
                  </li>
                )
              ->React.array}
           </ul>
         </>
       | Router.Suite(suite) =>
         let Suites.{benchmarks, setup, name} =
           Suites.Routes.map(suite).Suites.Routes.suite;
         let suite = B.Suite.make(name);
         <>
           <Router.HashLink to_=Router.Index className="go-home">
             {j|←|j}->React.string
             {Router.name(Router.Index)->React.string}
           </Router.HashLink>
           <Wrapper suite benchmarks setup />
         </>;
       }}
    </main>
    <footer className="footer">
      <p>
        "Copyright \xA9 2020 "->React.string
        <a href="https://johnridesa.bike/"> "John Jackson"->React.string </a>
      </p>
    </footer>
  </div>;
};
