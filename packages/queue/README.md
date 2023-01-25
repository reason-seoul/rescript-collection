# ReScript Queue

[![Package Version](https://img.shields.io/npm/v/rescript-qeueue)](https://www.npmjs.com/package/rescript-queue)
[![License - MIT](https://img.shields.io/npm/l/rescript-queue)](#license)

`rescript-queue` is a **persistent queue and deque** data structure that can be used in ReScript and JavaScript.

**_Persistent_**

Any function that changes the queue returns a new instance of it while not modifying the original queue. Just like any strings or numbers, queues are treated as immutable values.

**_Queue_**

A queue is a data structure that follows the First-In-First-Out (FIFO) principle. This means that the first element added to the queue will be the first one to be removed.

**_Deque_**

A deque, short for "double-ended queue", is a data structure that allows elements to be inserted and removed from both ends. Like a regular queue, it follows the FIFO principle, but it also allows for elements to be added and removed from the back, making it a "double-ended" data structure.

## Rationale

### Finger Tree

The [**Finger Tree**](https://en.wikipedia.org/wiki/Finger_tree) data structure is a persistent data structure that allows for efficient insertion and deletion at the front and back of the queue or deque. The finger tree is divided into "fingers" which are small, constant-size sub-trees and "digits" which are individual elements. The fingers are used to represent the larger elements in the tree, while the digits are used to represent the smaller elements.

It allows for better efficiency and better space complexity than the list when implementing queue and deque.

1. **Efficiency**: Lists have a linear time complexity for insertion and deletion operations at the front and back of the queue, whereas finger trees have a logarithmic time complexity for these operations. This means that finger trees can be more efficient when dealing with large queues or deques.

2. **Space complexity**: Lists have a linear space complexity, which means that they will use more memory as the number of elements in the queue or deque increases. Finger trees, on the other hand, have a balanced space complexity, which means that they will use less memory for large queues or deques.

`rescript-queue` provides a finger tree-based implementation of a deque in ReScript.

### Batch Queue

`rescript-queue` provides a **Batch Queue** implementation, which is introduced from [Purely Functional Data Structures](https://doc.lagout.org/programmation/Functional%20Programming/Chris_Okasaki-Purely_Functional_Data_Structures-Cambridge_University_Press%281998%29.pdf) by Chris Okasaki.

The Batch Queue is based on the idea of "batches" of elements, which are grouped together to form a single unit.

The Batch Queue has two main components: a front queue and a back queue. The front queue holds the elements that have been dequeued, while the back queue holds the elements that have been enqueued. The front and back queues are both using finger tree data structure.

When an element is enqueued, it is added to the back queue. If the back queue becomes too large, it is split into two smaller queues, and the front queue is concatenated with one of the smaller queues to form a new front queue.

When an element is dequeued, it is removed from the front queue. If the front queue becomes too small, it is concatenated with the back queue to form a new front queue.

By using the concept of "batches" the Batch Queue is able to maintain a balance between time and space complexity, and also allows for efficient insertion and deletion at the front and back of the queue, as well as efficient concatenation and splitting of the queue.

## LICENSE

MIT
