module About = {
  [@react.component]
  let make = () =>
    <article>
      <h1> "About Benchmark.bs.js"->React.string </h1>
      <p>
        {j|This is a web-app for measuring and comparing the performance speed
           of |j}
        ->React.string
        <a href="https://reasonml.github.io/"> "Reason"->React.string </a>
        {j| functions when compiled with |j}->React.string
        <a href="https://bucklescript.github.io/">
          "BuckleScript"->React.string
        </a>
        {j|. It's powered by |j}->React.string
        <a href="https://benchmarkjs.com/"> "Benchmark.js"->React.string </a>
        "."->React.string
      </p>
      <p>
        {j|Understanding performance isn't easy, and is made more complicated in
           Reason. Functions that may be performant on native Reason, but much
           slower when compiled to JavaScript. Many libraries use functions that
           appear the same, but may have different underlying implementations.|j}
        ->React.string
      </p>
      <p>
        {j|To add your own benchmark tests, you will need to |j}->React.string
        <a href="https://github.com/johnridesabike/benchmark-bs">
          "fork and clone this project's git repository"->React.string
        </a>
        {j|. Follow the instructions in its README.|j}->React.string
      </p>
    </article>;
};
