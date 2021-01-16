type any;

type benchmark = {
  name: string,
  code: string,
  f: (. unit) => any,
};

type t = {
  name: string,
  setup: string,
  benchmarks: array(benchmark),
};

module Routes: {
  type item = {
    suite: t,
    url: string,
  };
  type key;

  let map: key => item;

  let fromUrl: string => option(key);

  let routes: array(key);
};

