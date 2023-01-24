/***
A Persitent Vector.
*/

type t<'a>

/**
Creates an empty vector.
*/
@genType
let make: unit => t<'a>

/**
Uncurried version of `makeBy`.
*/
@genType
let makeByU: (int, (. int) => 'a) => t<'a>

/**
Makes a vector of length `n`.
The `i`th element is initialized by `f(i)`.

```
Vector.makeBy(5, i => i * i) // => vec{0, 1, 4, 9, 16}
```
*/
@genType
let makeBy: (int, int => 'a) => t<'a>

/**
Alias of `size`.
*/
@genType
let length: t<'a> => int

/**
Gets the size of a given vector.

Time: O(1)
*/
@genType
let size: t<'a> => int

/**
Returns a new vector concatenated two given vectors.

Time: O(n + m)
*/
let concat: (t<'a>, t<'a>) => t<'a>
let concatMany: array<t<'a>> => t<'a>

/**
Appends an element to the end of the vector.

Time: O(1) amortized, O(log n) at worst.
*/
@genType
let push: (t<'a>, 'a) => t<'a>

let pushMany: (t<'a>, array<'a>) => t<'a>

/**
Returns a new vector last element removed.
For empty vectors it returns an empty vector as is.

Time: O(1)
*/
@genType
let pop: t<'a> => t<'a>

/**
Time: O(log n)
*/
@genType
let get: (t<'a>, int) => option<'a>
@genType
let getExn: (t<'a>, int) => 'a
@genType
let getUnsafe: (t<'a>, int) => 'a

/**
Uncurried version of `getByU`.
*/
@genType
let getByU: (t<'a>, (. 'a) => bool) => option<'a>

/**
Time: O(n)
*/
@genType
let getBy: (t<'a>, 'a => bool) => option<'a>

/**
Uncurried version of `getIndexBy`.
*/
@genType
let getIndexByU: (t<'a>, (. 'a) => bool) => option<int>

/**
Time: O(n)
*/
@genType
let getIndexBy: (t<'a>, 'a => bool) => option<int>

/**
Time: O(n)
*/
@genType
let set: (t<'a>, int, 'a) => option<t<'a>>
@genType
let setExn: (t<'a>, int, 'a) => t<'a>
@genType
let setUnsafe: (t<'a>, int, 'a) => t<'a>

/**
Sequential functions.

Time: O(n)
*/

@genType
let reduceU: (t<'a>, 'b, (. 'b, 'a) => 'b) => 'b
@genType
let reduce: (t<'a>, 'b, ('b, 'a) => 'b) => 'b

@genType
let reduceWithIndexU: (t<'a>, 'b, (. 'b, 'a, int) => 'b) => 'b
@genType
let reduceWithIndex: (t<'a>, 'b, ('b, 'a, int) => 'b) => 'b

@genType
let mapU: (t<'a>, (. 'a) => 'b) => t<'b>
@genType
let map: (t<'a>, 'a => 'b) => t<'b>

@getType
let mapWithIndexU: (t<'a>, (. 'a, int) => 'b) => t<'b>

@genType
let mapWithIndex: (t<'a>, ('a, int) => 'b) => t<'b>

@genType
let keepU: (t<'a>, (. 'a) => bool) => t<'a>
@genType
let keep: (t<'a>, 'a => bool) => t<'a>

@genType
let keepMapU: (t<'a>, (. 'a) => option<'b>) => t<'b>
@genType
let keepMap: (t<'a>, 'a => option<'b>) => t<'b>

@genType
let keepWithIndexU: (t<'a>, (. 'a, int) => bool) => t<'a>
@genType
let keepWithIndex: (t<'a>, ('a, int) => bool) => t<'a>

@genType
let forEachU: (t<'a>, (. 'a) => unit) => unit
@genType
let forEach: (t<'a>, 'a => unit) => unit

@genType
let forEachWithIndexU: (t<'a>, (. 'a, int) => unit) => unit
@genType
let forEachWithIndex: (t<'a>, ('a, int) => unit) => unit

@genType
let someU: (t<'a>, (. 'a) => bool) => bool
@genType
let some: (t<'a>, 'a => bool) => bool

@genType
let some2U: (t<'a>, t<'a>, (. 'a, 'a) => bool) => bool
@genType
let some2: (t<'a>, t<'a>, ('a, 'a) => bool) => bool

@genType
let everyU: (t<'a>, (. 'a) => bool) => bool
@genType
let every: (t<'a>, 'a => bool) => bool

@genType
let every2U: (t<'a>, t<'a>, (. 'a, 'a) => bool) => bool
@genType
let every2: (t<'a>, t<'a>, ('a, 'a) => bool) => bool

@genType
let cmpU: (t<'a>, t<'a>, (. 'a, 'a) => int) => int
@genType
let cmp: (t<'a>, t<'a>, ('a, 'a) => int) => int

@genType
let eqU: (t<'a>, t<'a>, (. 'a, 'a) => bool) => bool
@genType
let eq: (t<'a>, t<'a>, ('a, 'a) => bool) => bool

@genType
let zip: (t<'a>, t<'b>) => t<('a, 'b)>
@genType
let zipByU: (t<'a>, t<'b>, (. 'a, 'b) => 'c) => t<'c>
@genType
let zipBy: (t<'a>, t<'b>, ('a, 'b) => 'c) => t<'c>

@genType
let unzip: t<('a, 'b)> => (t<'a>, t<'b>)

// @genType
// let drop: (t<'a>, int) => option<t<'a>>

// @genType
// let take: (t<'a>, int) => option<t<'a>>

// @genType
// let splitAt: (t<'a>, int) => option<(t<'a>, t<'a>)>

// @genType
// let parititionU: (t<'a>, (. 'a) => bool) => (t<'a>, t<'a>)
// @genType
// let paritition: (t<'a>, 'a => bool) => (t<'a>, t<'a>)

@genType
let sortU: (t<'a>, (. 'a, 'a) => int) => t<'a>

/**
Time: O(n log n)
*/
@genType
let sort: (t<'a>, ('a, 'a) => int) => t<'a>

/**
Reverses a vector using `array.reverse` internally.

Time: O(n log n)

```res
let v = vec{1, 2, 3, 4, 5}
Vector.reverse(v) == vec{5, 4, 3, 2, 1}
```
*/
@genType
let reverse: t<'a> => t<'a>

/**
Shuffles a vector using `Belt.Array.shuffleInplace` internallly.

Time: O(n)
*/
@genType
let shuffle: t<'a> => t<'a>

/**
Creates a new vector from an array.

Time: O(n)
*/
@genType
let fromArray: array<'a> => t<'a>

/**
Returns an array from the vector.

Time: O(n)
*/
@genType
let toArray: t<'a> => array<'a>
