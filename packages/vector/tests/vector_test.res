open Zora

module A = Belt.Array
module V = Vector

let isomorphic = ar => ar->V.fromArray->V.toArray == ar
let pushpop = (n, m) => {
  let v = V.fromArray(A.range(1, n))
  A.reduce(A.range(1, m), v, (v, _) => v->V.pop)
}

zora("Vector initialize", t => {
  t->equal(V.make()->V.length, 0, "make empty vector")
  t->equal(V.fromArray([]), V.make(), "make from empty array")

  A.range(1, 32)
  ->Belt.List.fromArray
  ->Belt.List.forEach(n => {
    t->ok(isomorphic(A.range(1, n)), `fromArray length=${n->Belt.Int.toString}`)
  })

  A.rangeBy(1000, 10000, ~step=1000)
  ->Belt.List.fromArray
  ->Belt.List.forEach(n => {
    t->ok(isomorphic(A.range(1, n)), `fromArray length=${n->Belt.Int.toString}`)
  })

  done()
})

zora("Vector.push", t => {
  t->test("push", t => {
    A.range(1, 64)
    ->Belt.List.fromArray
    ->Belt.List.forEach(n => {
      let v1 = A.reduce(A.range(1, n), V.make(), (v, i) => V.push(v, i))
      let v2 = A.range(1, n)->V.fromArray
      t->equal(v1, v2, "should be equal")
    })

    done()
  })

  t->test("root overflow", t => {
    let n = 32768
    let v1 = A.reduce(A.range(1, n), V.make(), (v, i) => V.push(v, i))
    let v2 = A.range(1, n)->V.fromArray

    t->equal(v1, v2, "should be equal")

    done()
  })

  done()
})

zora("Vector.pop", t => {
  t->test("pop", t => {
    list{(100, 50), (100, 100), (10000, 5000)}->Belt.List.forEach(((n, m)) => {
      t->equal(pushpop(n, m)->V.toArray, A.range(1, n - m), "should be equal")
    })
    done()
  })

  t->test("root overflow", t => {
    let ar = A.range(1, 32768)
    let v = V.fromArray(ar)
    let ev = A.reduce(ar, v, (v, _) => V.pop(v))

    t->ok(ev->V.length == 0, "should be empty")
    done()
  })

  done()
})

zora("Vector.get", t => {
  let v = pushpop(20000, 10000)
  t->block("random access (10,000 times)", t => {
    let every = A.every(A.range(1, 10000), _ => {
      let idx = Js.Math.random_int(0, 10000)
      V.getExn(v, idx) == idx + 1
    })
    t->ok(every, "should be succeed")
  })

  t->block("tail offset 0", t => {
    let v = V.push(V.make(), 1)
    let v' = V.setUnsafe(v, 0, 2)
    t->is(V.getUnsafe(v', 0), 2, "should be 2")
  })

  t->block("optional get", t => {
    list{-1, 0, 10000}->Belt.List.forEach(idx => {
      switch V.get(v, idx) {
      | Some(_) => t->ok(idx >= 0 && idx < V.length(v))
      | None => t->ok(idx >= 0 && idx < V.length(v))
      }
    })
  })

  t->block("out of bounds", t => {
    list{-1, 10000}->Belt.List.forEach(idx => {
      t->optionNone(V.get(v, idx), "should be none")
    })
  })

  done()
})

zora("Vector.set", t => {
  let size = 10000
  let v = V.fromArray(A.range(1, size))

  t->block(j`random update ($size items)`, t => {
    let ar = A.range(1, size)->A.shuffle
    let v' = A.reduce(ar, v, (v, idx) => V.setExn(v, idx - 1, idx * -1))
    let every = A.every(v'->V.toArray, x => x < 0)

    t->ok(every, "shoud be ok")
  })

  t->block("optional set", t => {
    list{-1, 0, 10000}->Belt.List.forEach(idx => {
      switch V.set(v, idx, 42) {
      | Some(_) => t->ok(idx >= 0 && idx < V.length(v))
      | None => t->ok(idx >= 0 && idx < V.length(v))
      }
    })
  })

  let ar = A.range(1, size)
  t->block(j`mutable random update ($size times)`, t => {
    A.forEach(A.range(1, size)->A.shuffle, idx => A.setUnsafe(ar, idx - 1, idx * -1))
    let every = A.every(ar, x => x < 0)
    t->ok(every, "should be ok")
  })

  done()
})

zora("Vector.reduce", t => {
  let size = 100
  let v = V.fromArray(A.range(1, size))

  t->block("sum", t => {
    let sum = V.reduce(v, 0, (acc, i) => acc + i)
    t->is(sum, 5050, "sum is 5050")
  })

  t->block("sum (uncurried)", t => {
    let sum = V.reduceU(v, 0, (. acc, i) => acc + i)
    t->is(sum, 5050, "sum is 5050")
  })

  done()
})
