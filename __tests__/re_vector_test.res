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
  testAll("push", A.range(1, 64)->Belt.List.fromArray, n => {
    let v1 = A.reduce(A.range(1, n), V.make(), (v, i) => V.push(v, i))
    let v2 = A.range(1, n)->V.fromArray

    expect(v1 == v2) |> toBeTruthy
  })
  test("root overflow", () => {
    let n = 32768
    let v1 = A.reduce(A.range(1, n), V.make(), (v, i) => V.push(v, i))
    let v2 = A.range(1, n)->V.fromArray

    expect(v1 == v2) |> toBeTruthy
  })
})

let pushpop = (n, m) => {
  let v = V.fromArray(A.range(1, n))
  A.reduce(A.range(1, m), v, (v, _) => v->V.pop)
}

describe("Vector.pop", () => {
  testAll("pushpop (push > pop)", list{(100, 50), (100, 100), (10000, 5000)}, ((n, m)) =>
    expect(pushpop(n, m)->V.toArray == A.range(1, n - m)) |> toBeTruthy
  )

  test("root underflow", () => {
    let ar = A.range(1, 32768)
    let v = V.fromArray(ar)
    let ev = A.reduce(ar, v, (v, _) => V.pop(v))

    expect(ev->V.length == 0) |> toBeTruthy
  })
})

describe("Vector.get", () => {
  let v = pushpop(20000, 10000)
  test("random access (10,000 times)", () => {
    let every = A.every(A.range(1, 10000), _ => {
      let idx = Js.Math.random_int(0, 10000)
      V.getExn(v, idx) == idx + 1
    })
    expect(every) |> toBeTruthy
  })

  test("tail offset 0", () => {
    let v = V.push(V.make(), 1)
    let v' = V.setUnsafe(v, 0, 2)
    expect(V.getUnsafe(v', 0) == 2) |> toBeTruthy
  })

  testAll("optional get", list{-1, 0, 10000}, idx => {
    switch V.get(v, idx) {
    | Some(_) => expect(idx >= 0 && idx < V.length(v)) |> toBeTruthy
    | None => expect(idx >= 0 && idx < V.length(v)) |> toBeFalsy
    }
  })

  testAll("out of bounds", list{-1, 10000}, idx => expect(() => V.getExn(v, idx)) |> toThrow)
})

describe("Vector.set", () => {
  let size = 10000
  let v = V.fromArray(A.range(1, size))
  test(j`random update ($size times)`, () => {
    let ar = A.range(1, size)->A.shuffle
    let v' = A.reduce(ar, v, (v, idx) => V.setExn(v, idx - 1, idx * -1))
    let every = A.every(v'->V.toArray, x => x < 0)

    expect(every) |> toBeTruthy
  })

  testAll("optional set", list{-1, 0, 10000}, idx => {
    switch V.set(v, idx, 42) {
    | Some(_) => expect(idx >= 0 && idx < V.length(v)) |> toBeTruthy
    | None => expect(idx >= 0 && idx < V.length(v)) |> toBeFalsy
    }
  })

  let ar = A.range(1, size)
  test(j`mutable random update ($size times)`, () => {
    A.forEach(A.range(1, size)->A.shuffle, idx => A.setUnsafe(ar, idx - 1, idx * -1))
    let every = A.every(ar, x => x < 0)

    expect(every) |> toBeTruthy
  })
})

describe("Vector.reduce", () => {
  let size = 100
  let v = V.fromArray(A.range(1, size))
  test(j`sum`, () => {
    let sum = V.reduce(v, 0, (acc, i) => acc + i)
    expect(sum) |> toBe(5050)
  })
  test(j`sum (uncurried)`, () => {
    let sum = V.reduceU(v, 0, (. acc, i) => acc + i)
    expect(sum) |> toBe(5050)
  })
})
