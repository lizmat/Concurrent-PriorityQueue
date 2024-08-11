[![Actions Status](https://github.com/lizmat/Concurrent-PriorityQueue/actions/workflows/linux.yml/badge.svg)](https://github.com/lizmat/Concurrent-PriorityQueue/actions) [![Actions Status](https://github.com/lizmat/Concurrent-PriorityQueue/actions/workflows/macos.yml/badge.svg)](https://github.com/lizmat/Concurrent-PriorityQueue/actions) [![Actions Status](https://github.com/lizmat/Concurrent-PriorityQueue/actions/workflows/windows.yml/badge.svg)](https://github.com/lizmat/Concurrent-PriorityQueue/actions)

NAME
====

Concurrent::PriorityQueue - provide a thread-safe priority queue

SYNOPSIS
========

```raku
use Concurrent::PriorityQueue;

my @a is Concurrent::PriorityQueue;

@a.push(666);
@a.push(42);

say @a.shift;  # 42
say @a.shift;  # 666

@a.push(666 => "bar");
@a.push(42  => "foo");

say @a.shift;  # foo
say @a.shift;  # bar
```

DESCRIPTION
===========

Concurrent::PriorityQueue provides a customizable role to create an ordered queue to which one can `.push` values to, and <.shift> or `.pop` values from. By default, the underlying order of values pushed, is in ascending order, using `infix:<cmp>` semantics.

If a `Pair` was `.push`ed, then the `.key` will determine the position in the underlying order. And `.shift` and `.pop` will produce the associated `.value`.

If any other value was `.push`ed, then it will both serve as key as well as value.

METHODS
=======

push
----

```raku
@a.push(42);          # key and value same

@a.push(42 => "foo")  # key and value different
```

Adds a key or a key/value pair to the queue.

pop
---

```raku
say @a.pop;  # value associated with highest key
```

Produces the value associated with the highest key, and removes that entry from the queue. Or produces a `Failure` if there were no values in the queue.

shift
-----

```raku
say @a.shift;  # value associated with lowest key
```

Produces the value associated with the lowest key, and removes that entry from the queue. Or produces a `Failure` if there were no values in the queue.

elems
-----

```raku
say @a.elems;  # number of items remaining in queue
```

Produces the current number of items in the queue.

List
----

```raku
@a.List;  # representation for
```

Produces the queue as a `List` of `Pair`s. Intended to be used to provide more permanent storage for the queue, to later re-initialize a new queue with.

PARAMETERIZATION
================

```raku
# only allow Int as key
my @b = Concurrent::PriorityQueue[Int];
```

By default, `Any` defined value can serve as key. This can be parameterized by specifying a type, e.g. `Int` to only allow integers as keys.

```raku
# only allow Int as key with <=> order semantics
my @b = Concurrent::PriorityQueue[ Int, :cmp(&[<=>]) ];
```

By default the `infix:<cmp>` comparator is used to determine the order in which values will be produced, This can be parameterized with the `:cmp` named argument, e.g. `:cmp(&infix«<=>»)` to use numerical comparisons only.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Concurrent::PriorityQueue Comments and Pull Requests are welcome.

If you like this module, or what I’m doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2024 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

