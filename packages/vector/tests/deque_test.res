open Zora

zora("emptyness", t => {
  let empty = Deque.empty
  t->test("remove", t => {
    t->is(empty, empty->Deque.popFront, "")
    t->is(empty, empty->Deque.popBack, "")
    done()
  })

  t->test("get", t => {
    t->is(None, empty->Deque.peekFront, "")
    t->is(None, empty->Deque.peekBack, "")
    t->is(empty, empty->Deque.popFront, "")
    t->is(empty, empty->Deque.popFront, "")
    done()
  })

  done()
})

zora("toArray", t => {
  let dq =
    Deque.empty
    ->Deque.pushBack(0)
    ->Deque.pushBack(1)
    ->Deque.pushFront(2)
    ->Deque.pushFront(3)
    ->Deque.pushFront(4)
    ->Deque.pushFront(5)
    ->Deque.pushFront(6)
    ->Deque.pushFront(7)
    ->Deque.pushFront(8)
    ->Deque.pushFront(9)
    ->Deque.toArray
  t->is(true, dq == [9,8,7,6,5,4,3,2,0,1], "")
  done()
})

zora("adventofcode 2018-9", t => {
  module Circle = {
    // type t = Deque.t<int>

    let make = () => {
      Deque.empty->Deque.pushFront(0)
    }

    let ccw = circle => {
      switch Deque.peekBack(circle) {
      | Some(v) => circle->Deque.popBack->Deque.pushFront(v)
      | None => assert false
      }
    }
    let cw = circle => {
      switch Deque.peekFront(circle) {
      | Some(v) => circle->Deque.popFront->Deque.pushBack(v)
      | None => assert false
      }
    }
    let push = Deque.pushBack
    let pop = Deque.popBack
    let peek = circle =>
      switch Deque.peekBack(circle) {
      | Some(v) => v
      | None => assert false
      }
  }

  let place = (circle, nextNum) => {
    if mod(nextNum, 23) == 0 {
      let circle =
        circle->Circle.ccw->Circle.ccw->Circle.ccw->Circle.ccw->Circle.ccw->Circle.ccw->Circle.ccw
      let scoreAt = Circle.peek(circle)
      (circle->Circle.pop->Circle.cw, scoreAt + nextNum)
    } else {
      (circle->Circle.cw->Circle.push(nextNum), 0)
    }
  }

  let play = (circle, numPlayers, lastMarble) => {
    let rec f = (circle, marble, scoreMap) => {
      if marble > lastMarble {
        let scores = scoreMap->Belt.Map.Int.valuesToArray->Belt.SortArray.Int.stableSort
        scores->Belt.Array.getExn(Belt.Array.length(scores) - 1)
      } else {
        let (circle, score) = place(circle, marble)
        let player = mod(marble, numPlayers)
        let scoreMap = scoreMap->Belt.Map.Int.update(player, v =>
          switch v {
          | Some(s) => s + score
          | None => score
          }->Some
        )
        f(circle, marble + 1, scoreMap)
      }
    }
    f(circle, 1, Belt.Map.Int.empty)
  }

  t->is(play(Circle.make(), 9, 25), 32, "")

  t->is(play(Circle.make(), 459, 71790), 386151, "")
  t->is(play(Circle.make(), 459, 717900), 32700280, "")

  done()
})
