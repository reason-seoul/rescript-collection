# Convert (to array)

## Setup

```res
let ar10k = A.range(1, 10000)

let v = Vector.fromArray(ar10k)
let l = ImmutableJs.List.fromArray(ar10k)
let m = Mori.into(Mori.vector(), ar10k)
```

## Test
