# garter-vector

> Belt's missing piece, Persistent Vector for ReScript.


### Benchmarks

Tested on 3.1 GHz 6-Core Intel Core i5.

1) Adds one element to the end

| implementation            |  2,000 | 10,000 |  30,000 |  50,000 | 100,000 | 1,000,000 |
| ------------------------- | -----: | -----: | ------: | ------: | ------: | --------: |
| Belt.Array.concat         |    6ms |   89ms |  2071ms |  6657ms |         |       N/A |
| Js.Array2.concat          |    3ms |   42ms |  1670ms |  5392ms |         |       N/A |
| **Garter.Vector.push**    |  < 1ms |    2ms |     4ms |     7ms |    13ms |     112ms |
| Js.Array2.push (mutable)  |  < 1ms |    1ms |     2ms |     2ms |     3ms |      30ms |


### TODO

- Use bit operation on every tree traversal
- Implement utility functions similar to Belt.Array and/or Belt.List


### References

- [Extreme Cleverness: Functional Data Structures in Scala](https://www.infoq.com/presentations/Functional-Data-Structures-in-Scala/)
- [Understanding Clojure's Persistent Vectors](https://hypirion.com/musings/understanding-persistent-vector-pt-1)
