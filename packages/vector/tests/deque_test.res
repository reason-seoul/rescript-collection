module Circle = {
  type t = Deque.t<int>

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
      let scores = scoreMap->Belt.Map.Int.keysToArray->Belt.SortArray.Int.stableSort
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

play(Circle.make(), 459, 71790)->Js.log
