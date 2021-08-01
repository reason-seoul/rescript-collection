let get = Js.Array2.unsafe_get
let set = Js.Array2.unsafe_set
let length = Js.Array2.length

// Belt.Array.slice does element-wise operation for no reason.
// It's only better than Js.Array2.slice in its argument design.
let slice = (ar, ~offset, ~len) => Js.Array2.slice(ar, ~start=offset, ~end_=offset + len)

// Belt.Array.copy uses Belt.Array.slice internally.
// The fastest way to copy one array to another is using Js.Array2.copy
let clone = Js.Array2.copy

let cloneAndSet = (ar, i, a) => {
  let newAr = clone(ar)
  set(newAr, i, a)
  newAr
}

@val
external make: int => array<'a> = "Array"

// src and dst must not overlap
let blit = (~src, ~srcOffset, ~dst, ~dstOffset, ~len) =>
  for i in 0 to len - 1 {
    Js.Array2.unsafe_set(dst, dstOffset + i, get(src, srcOffset + i))
  }

@send
external forEach: (array<'a>, 'a => unit) => unit = "forEach"
