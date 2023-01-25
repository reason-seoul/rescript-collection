# ReScript Vector

[![Package Version](https://img.shields.io/npm/v/rescript-vector)](https://www.npmjs.com/package/rescript-vector)
[![License - MIT](https://img.shields.io/npm/l/rescript-vector)](#license)

`rescript-vector` is a **persistent vector** data structure that can be used in ReScript.

**_Persistent_**

Any function that changes the vector returns a new instance of it while not modifying the original vector. Just like any strings or numbers, vectors are treated as never-changing values.

**_Vector_**

Similar to Array, but vectors can be dynamically increased or decreased in size. (in this sense, JS arrays are better called vectors)
Elements can be added or deleted to the end of the vector, and you can access them in constant time.

## Rationale

ReScript's standard library `Belt` has persistent data structures like Array and List, which are mature and complete.

However, `Belt.Array` does not have push/pop functions like Js.Array2 does. This is because pushing/popping while maintaining the persistency cost **a lot**. Specifically, it takes _O(n)_ time and space complexity.

`Belt.List` can add or delete elements in _O(1)_, but its access time is _O(n)_ which could cause another latent performance issue.

`rescript-vector` do push/pop in amortized _O(1)_ and _O(log n)_ at worst. Accessing an element takes _O(log n)_ time complexity. [^footnote]

While gaining persistency, this is also a good trade-off in most cases.

Inside the vector, there is a very specially implemented trie, a _bit-partitioned vector trie_. You can find more detailed explanation [here](https://hypirion.com/musings/understanding-persistent-vector-pt-1).

[^footnote]: Typically, the base of the log is 32. Because of this nature, even when n is 1 million, log<sub>32</sub>10<sup>6</sup> is less than 4.

## Binding isn't enough

Yes, there exists prior JavaScript implementations for persistent vector.
The most famous ones are [Immutable.js](https://immutable-js.github.io/immutable-js/) and [mori](https://swannodette.github.io/mori/). [^2]

[^2]: [Immer](https://immerjs.github.io/immer/) is an exception as it works as COW(copy-on-write).

Though they are great in many ways, the biggest problem is that their interfaces do not match Belt.
So we either have to give up zero-cost binding or ergonimics.
Moreover, they are both designed for heterogeneous vectors, a considerable overhead is inevitable.

Last but not least, as a fanatic ReScript user, I had to rewrite it in 100% ReScript.

## Benchmarks

In the process of implementing persistent vector,
some optimizations found could further improve performance compared to other libraries.

As a result, many operations are much faster, especially Array conversion, making `rescript-vector` more tolerable in practice.

See [benchmarks](https://reason-seoul.github.io/rescript-collection/).

## LICENSE

MIT
