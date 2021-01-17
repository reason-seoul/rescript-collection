open Jest
open ExpectJs

module A = Belt.Array
module V = Re_Vector

describe("Vector initialize", () => {
  test("empty", () => expect(V.make()->V.length) |> toBe(0))
  test("empty fromArray", () => expect(V.fromArray([]) == V.make()) |> toBeTruthy)

  let isomorphic = ar => ar->V.fromArray->V.toArray == ar

  testAll("fromArray", A.range(1, 32)->Belt.List.fromArray, n => {
    expect(isomorphic(A.range(1, n))) |> toBeTruthy
  })

  testAll("fromArray (large)", A.rangeBy(1000, 10000, ~step=1000)->Belt.List.fromArray, n => {
    expect(isomorphic(A.range(1, n))) |> toBeTruthy
  })
})

describe("Vector.push", () => {
  testAll("push", A.range(1, 32)->Belt.List.fromArray, n => {
    let v1 = A.range(1, n)->A.reduce(V.make(), (v, i) => V.push(v, i))
    let v2 = A.range(1, n)->V.fromArray

    expect(v1 == v2) |> toBeTruthy
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
