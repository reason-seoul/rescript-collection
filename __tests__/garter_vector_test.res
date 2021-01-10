open Jest
open ExpectJs

module A = Belt.Array
module V = Garter.Vector

describe("Vector.init", () => test("empty", () => expect(V.make()->V.length) |> toBe(0)))

describe("Belt.Array vs. Js.Array vs. Js.Array (mutable) vs. Garter.Vector", () => {
  let smallSet = A.rangeBy(1000, 5000, ~step=1000)->Belt.List.fromArray
  // let largeSet = list{10000, 30000, 50000, 100000, 1000000}

  let targets = [
    (
      "Js.Array2.push (mutable)",
      n => {
        let ar = []
        A.range(1, n)->A.forEach(v => ar->Js.Array2.push(v)->ignore)
        expect(ar->A.length) |> toBe(n)
      },
    ),
    (
      "Garter.Vector.push",
      n => {
        let v = V.fromArray(A.range(1, n))
        expect(v->V.length) |> toBe(n)
      },
    ),
  ]

  targets->A.forEach(((name, f)) => {
    testAll(name ++ " (small)", smallSet, f)
    // testAll(name ++ " (large)", largeSet, f)
  })
})

describe("Vector.push", () => {
  let isomorphic = ar => ar->V.fromArray->V.toArray == ar

  testAll("fromArray", A.range(1, 32)->Belt.List.fromArray, n => {
    expect(isomorphic(A.range(1, n))) |> toBeTruthy
  })

  testAll("fromArray (large)", A.rangeBy(1000, 10000, ~step=1000)->Belt.List.fromArray, n => {
    expect(isomorphic(A.range(1, n))) |> toBeTruthy
  })
})

let pushpop = (n, m) => {
  let v = V.fromArray(A.range(1, n))
  A.range(1, m)->A.reduce(v, (v, _) => v->V.pop)
}

describe("Vector.pop", () =>
  testAll("pushpop (push > pop)", list{(100, 50), (100, 100), (10000, 5000)}, ((n, m)) =>
    expect(pushpop(n, m)->V.toArray == A.range(1, n - m)) |> toBeTruthy
  )
)

describe("Vector.get", () => {
  let v = pushpop(20000, 10000)
  test("random access (10,000 times)", () => {
    let every = A.range(1, 10000)->A.every(_ => {
      let idx = Js.Math.random_int(0, 10000)
      v->V.getExn(idx) == idx + 1
    })
    expect(every) |> toBeTruthy
  })

  testAll("out of bounds", list{-1, 10000}, idx => expect(() => v->V.getExn(idx)) |> toThrow)
})

describe("Vector.set", () => {
  let size = 100000
  let v = V.fromArray(A.range(1, size))
  test(j`random update ($size times)`, () => {
    let v' = A.range(1, size)->A.shuffle->A.reduce(v, (v, idx) => v->V.setExn(idx - 1, idx * -1))
    let every = v'->V.toArray->A.every(x => x < 0)

    expect(every) |> toBeTruthy
  })

  let ar = A.range(1, size)
  test(j`mutable random update ($size times)`, () => {
    A.range(1, size)->A.shuffle->A.forEach(idx => ar->A.setUnsafe(idx - 1, idx * -1))
    let every = ar->A.every(x => x < 0)

    expect(every) |> toBeTruthy
  })
})
