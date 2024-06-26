# Collections

Set of performant type safe collections written in ruby.

### Queue

Regular parameterized FIFO queue with O(1) enqueue and dequeue operations. The difference between Mayak's Queue and standard library Queue is that former is plain data struture that doesn't block, while the latter is a synchronization multi-producer, multi-consumer queue.

Usage:
```ruby
queue = Mayak::Collections::Queue[Integer].new

# adds an element to the queue
queue.enqueue(1)
queue.enqueue(2)
queue.enqueue(3)

# returns first queue element without updating the queue
queue.peak # 1

# returns an element and remove it from collection
queue.dequeue # 1
queue.dequeue # 2
queue.dequeue # 3
queue.dequeue # nil

# checks whether collection is empty
queue.empty? # true
queue.enqueue(1)
queue.empty? # false
```

### Priority Queue

Implements a queue where aach element has an associated priority. Elements with high priority are served before elements with low priority. The priority queue is parameterized with both element and priority types. Priority queue is initialized with a comparator function that returns a boolean value (true if a first argument is larger that a second).

Usage:
```ruby
pqueue = Mayak::Collections::PriorityQueue[String, Integer].new { |a, b| a > b }

# adds an element with a priority
pqueue.enqueue("second", 8)
pqueue.enqueue("third", 5)
pqueue.enqueue("first", 10)
# returns a pair of value and priority and remove it from the queue
pqueue.dequeue # ["first", 10]
pqueue.dequeue # ["second", 8]
pqueue.dequeue # ["third", 5]

# returns a first pair without removing it from the queue
pqueue.peak # nil
pqueue.enqueue("first", 10)
pqueue.peak # ["first", 10]
pqueue.dequeue # ["first", 10]

pqueue.enqueue("second", 8)
pqueue.enqueue("third", 5)
pqueue.enqueue("first", 10)

# returns an array containing all pairs preserving internal heap structure
pqueue.to_a # [["first", 10], ["third", 5], ["second", 8]]
```