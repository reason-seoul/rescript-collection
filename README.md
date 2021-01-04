# garter-vector

> Belt's missing piece, Persistent Vector for ReScript.


### Benchmarks

Tested on 3.1 GHz 6-Core Intel Core i5.

1) Adds one element to the end

| implementation            |  2,000 | 10,000 |  30,000 |  50,000 | 1,000,000 |
| ------------------------- | -----: | -----: | ------: | ------: | --------: |
| Belt.Array.concat         |    6ms |   89ms |  2071ms |  6657ms |       N/A |
| Js.Array2.concat          |    3ms |   42ms |  1670ms |  5392ms |       N/A |
| **Garter.Vector.push**    |    1ms |    4ms |    13ms |    25ms |     650ms |
| Js.Array2.push (mutable)  |  < 1ms |    2ms |     2ms |     2ms |      29ms |


### TODO

- Keep tail node for O(1) access
- Use bit operation on every tree traversal
- Implement utility functions similar to Belt.Array and/or Belt.List


### References

- [ClojureScript's PersistentVector](https://github.com/clojure/clojurescript/blob/r1.10.773-2-g946348da/src/main/cljs/cljs/core.cljs#L5498-L5693)