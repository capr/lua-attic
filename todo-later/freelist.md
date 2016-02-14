---
tagline: dynamic allocation of fixed-size objects
---

## `local freelist = require'freelist'`

A free list is about maintaining an array of pointers pointing to
the elements of a cdata array that are considered free.

A free list exposes an API which can allocate and deallocate fixed-size
objects in O(1) from a pre-allocated array.

## API

-------------------------------------- ---------------------------------------
freelist{size =, ctype =, ...} -> fl   create a freelist
fl:get() -> p                          get an element from the freelist
fl:put(p)                              put an element back into the freelist
fl:length() -> n                       how many elements are available
fl:alloc_data(size)                    custom allocator for the elements array
fl:alloc_list(size)                    custom allocator for the freelist
-------------------------------------- ---------------------------------------

### `freelist(fl) -> fl`

Convert an initial table to a free list and return it. The table can have fields:

  * `size`: the size of the list and array.
  * `ctype`: the element type for allocating an internal buffer, or
  * `data`: a pre-allocated buffer.
  * `last` and `list`: optional, for wrapping an existing free list.


## NOTE

When using a free list check that allocation sinking works for your use case.
If it doesn't, pointers will be allocated on the heap thus invalidating any
performance gains that you might get out of the free list.
