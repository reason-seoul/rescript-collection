let intHasher = x => x

let n = 3000000

type action = Insert(int) | Remove(int)

let actions = Belt.Array.makeBy(n, _ => {
  let x = Js.Math.random_int(0, n / 2)
  switch Js.Math.random_int(0, 2) {
  | 0 => Insert(x)
  | _ => Remove(x)
  }
})

module BeltSet = Belt.Set.Int

let init = (HashSet.make(~hasher=intHasher), BeltSet.empty)

// let start = Js.Date.now()

// Belt.Array.reduce(actions, init, ((s1, s2), action) => {
//   switch action {
//   | Insert(x) =>
//     //  Belt.Set.Int.size has serious performance problems here!
//     let len =
//       BeltSet.size(s2) + if BeltSet.get(s2, x)->Belt.Option.isNone {
//         1
//       } else {
//         0
//       }
//     let s1 = s1->HashSet.set(x)
//     let s2 = s2->BeltSet.add(x)
//     assert (s1->HashSet.size == len)
//     (s1, s2)
//   | Remove(x) =>
//     let len =
//       BeltSet.size(s2) - if BeltSet.get(s2, x)->Belt.Option.isSome {
//         1
//       } else {
//         0
//       }
//     let s1 = s1->HashSet.remove(x)
//     let s2 = s2->BeltSet.remove(x)
//     assert (s1->HashSet.size == len)
//     (s1, s2)
//   }
// })->ignore

// let end = Js.Date.now()

// Js.log("elapsed: " ++ Js.Float.toString(end -. start))

let printElapsed = (title, f) => {
  let start = Js.Date.now()
  f()->ignore
  let end = Js.Date.now()
  Js.log(`[${title}] elapsed: ${Js.Float.toString(end -. start)}`)
}

printElapsed("HashSet", () =>
  Belt.Array.reduce(actions, fst(init), (s2, action) => {
    switch action {
    | Insert(x) => s2->HashSet.set(x)
    | Remove(x) => s2->HashSet.remove(x)
    }
  })
)

printElapsed("BeltSet", () =>
  Belt.Array.reduce(actions, snd(init), (s2, action) => {
    switch action {
    | Insert(x) => s2->BeltSet.add(x)
    | Remove(x) => s2->BeltSet.remove(x)
    }
  })
)

printElapsed("HashSet", () =>
  Belt.Array.reduce(actions, fst(init), (s2, action) => {
    switch action {
    | Insert(x) => s2->HashSet.set(x)
    | Remove(x) => s2->HashSet.remove(x)
    }
  })
)

printElapsed("BeltSet", () =>
  Belt.Array.reduce(actions, snd(init), (s2, action) => {
    switch action {
    | Insert(x) => s2->BeltSet.add(x)
    | Remove(x) => s2->BeltSet.remove(x)
    }
  })
)

printElapsed("HashSet", () =>
  Belt.Array.reduce(actions, fst(init), (s2, action) => {
    switch action {
    | Insert(x) => s2->HashSet.set(x)
    | Remove(x) => s2->HashSet.remove(x)
    }
  })
)

printElapsed("BeltSet", () =>
  Belt.Array.reduce(actions, snd(init), (s2, action) => {
    switch action {
    | Insert(x) => s2->BeltSet.add(x)
    | Remove(x) => s2->BeltSet.remove(x)
    }
  })
)
