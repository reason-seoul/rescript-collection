# ReScript Queue

[![Package Version](https://img.shields.io/npm/v/rescript-qeueue)](https://www.npmjs.com/package/rescript-queue)
[![License - MIT](https://img.shields.io/npm/l/rescript-queue)](#license)

`rescript-queue` is a **persistent queue** data structure that can be used in ReScript and JavaScript.

**_Persistent_**

Any function that changes the queue returns a new instance of it while not modifying the original queue. Just like any strings or numbers, queues are treated as immutable values.

**_Queue_**

A queue is a data structure that follows the First-In-First-Out (FIFO) principle. This means that the first element added to the queue will be the first one to be removed.

## Rationale

`rescript-queue` provides a [Finger Tree](https://en.wikipedia.org/wiki/Finger_tree)-based implementation of a queue and deque (double-ended queue) in ReScript

The finger tree data structure is a persistent data structure that allows for efficient insertion and deletion at the front and back of the queue or deque. The finger tree is divided into "fingers" which are small, constant-size sub-trees and "digits" which are individual elements. The fingers are used to represent the larger elements in the tree, while the digits are used to represent the smaller elements.

It allows for a more efficient implementation and can be used to improve performance in certain use cases.

## LICENSE

MIT
