--------------------------------------------------------------------------------------------------------------------------

## `glue.keys(t[, sorted | cmp]) -> dt` {#keys}

Make a list of all the keys of `t`, optionally sorted.

### Examples:

An API expects a list of things but you have them as keys in a table because you are indexing something on them.

For instance, you have a table of the form `{socket = thread}` but `socket.select` wants a list of sockets.

See also: [glue.sortedpairs](#sortedpairs).

--------------------------------------------------------------------------------------------------------------------------

## `glue.update(dt,t1,...) -> dt` {#update}

Update a table with elements of other tables, overwriting any existing keys.

  * nil arguments are skipped.

### Examples:

Create an options table by merging the options received as an argument (if any) over the default options.

~~~{.lua}
function f(opts)
   opts = glue.update({}, default_opts, opts)
end
~~~

Shallow table copy:

~~~{.lua}
t = glue.update({}, t)
~~~

Static multiple inheritance:

~~~{.lua}
C = glue.update({}, A, B) --#TODO: find real-world example of multiple inheritance
~~~

See also: [glue.extend](#extend), [glue.inherit](#inherit).

--------------------------------------------------------------------------------------------------------------------------

## `glue.merge(dt,t1,...) -> dt` {#merge}

Update a table with elements of other tables skipping on any existing keys.

  * nil arguments are skipped.

### Examples:

Normalize a data object with default values:

~~~{.lua}
glue.merge(t, defaults)
~~~

See also: [glue.update](#update).

--------------------------------------------------------------------------------------------------------------------------

## `glue.sortedpairs(t[,cmp]) -> iterator<k,v>` {#sortedpairs}

Like pairs() but in key order.

The implementation creates a temporary table to sort the keys in.

See also: [glue.keys](#keys).

--------------------------------------------------------------------------------------------------------------------------

## `glue.extend(dt,t1,...) -> dt` {#extend}

Extend the list with the elements of other lists.

  * nil arguments are skipped.
  * list elements are the ones from 1 to `#dt`.

### Uses:

Accumulating values from multiple list sources.

See also: [glue.append](#append), [glue.update](#update).

--------------------------------------------------------------------------------------------------------------------------

## `glue.append(dt,v1,...) -> dt` {#append}

Append one or more values to a list.

### Uses:

Appending an object to a flattened list of lists (eg. appending a path element to a 2d path).

See also: [glue.extend](#extend), [glue.update](#update).

--------------------------------------------------------------------------------------------------------------------------

## `glue.shift(t,i,n) -> t` {#shift}

Shift all the list elements starting at index `i`, `n` positions to the left or further to the right.

For a positive `n`, shift the elements further to the right, effectively creating room for `n` new elements at index `i`.
When `n` is 1, the effect is the same as for `table.insert(t, i, t[i])`.
The old values at index `i` to `i+n-1` are preserved, so `#t` still works after the shifting.

For a negative `n`, shift the elements to the left, effectively removing the `n` elements at index `i`.
When `n` is -1, the effect is the same as for `table.remove(t, i)`.

### Uses:

Removing a portion of a list or making room for more elements inside the list.

See also: [glue.extend](#extend).

--------------------------------------------------------------------------------------------------------------------------

## `glue.gsplit(s,sep[,plain]) -> iterator<e[,captures...]>` {#gsplit}

Split a string by a separator pattern (or plain string) and iterate over the elements.

  * if sep is "" return the entire string in one iteration
  * if s is "" return s in one iteration
  * empty strings between separators are always returned, eg. `glue.gsplit(',', ',')` produces 2 empty strings
  * captures are allowed in sep and they are returned after the element, except for the last element for
    which they don't match (by definition).

### Examples:

~~~{.lua}
for s in glue.gsplit('Spam eggs spam spam and ham', '%s*spam%s*') do
   print('"'..s..'"')
end

> "Spam eggs"
> ""
> "and ham"
~~~

### Design notes:

  * name choice: associate with `gmatch` and `gsub`
  * allowing captures in `sep` doesn't have very readable semantics

--------------------------------------------------------------------------------------------------------------------------

## `glue.trim(s) -> s` {#trim}

Remove whitespace (defined as Lua pattern `%s`) from the beginning and end of a string.

--------------------------------------------------------------------------------------------------------------------------

## `glue.escape(s[,mode]) -> pat` {#escape}

Escape magic characters of the string `s` so that it can be used as a pattern to string matching functions.

  * the optional argument `mode` can have the value `"*i"` (for case insensitive), in which case each alphabetical
    character in `s` will also be escaped as `[aA]` so that it matches both its lowercase and uppercase variants.
  * escapes embedded zeroes as the `%z` pattern.

### Uses:

  * workaround for lack of pattern syntax for "this part of a match is an arbitrary string"
  * workaround for lack of a case-insensitive flag in pattern matching functions

### Design notes:

Test the performance of the case-insensitive hack to see if it's feasible.

--------------------------------------------------------------------------------------------------------------------------

## `glue.tohex(s[,upper]) -> s` {#tohex}

## `glue.tohex(n[,upper]) -> s`

Convert a binary string or a Lua number to its hex representation.

  * lowercase by default
  * uppercase if `upper` is anything non-false, like say, the string "upper"
  * numbers must be in the unsigned 32 bit integer range

See also: [glue.fromhex](#fromhex).

--------------------------------------------------------------------------------------------------------------------------

## `glue.fromhex(s) -> s` {#fromhex}

Convert a hex string to its binary representation.

See also: [glue.tohex](#tohex).

--------------------------------------------------------------------------------------------------------------------------

## `glue.collect([i, ]iterator) -> t` {#collect}

Iterate an iterator and collect its i'th return value of every step into a list.

  * i defaults to 1

### Examples:

Implementation of `keys()` and `values()` in terms of `collect()`

~~~{.lua}
keys = function(t) return glue.collect(pairs(t)) end
values = function(t) return glue.collect(2,pairs(t)) end
~~~

Collecting string matches:

~~~{.lua}
s = 'a,b,c,'
t = glue.collect(s:gmatch'(.-),')
for i=1,#t do print(t[i]) end

> a
> b
> c
~~~

### Design notes:

Alt. name: `ipack` - like pack but for iterators; collect is better at suggesting a process done in steps.

--------------------------------------------------------------------------------------------------------------------------

## `glue.ipcall(iterator<v1,...>) -> iterator<true,v1,...|false,error>` {#ipcall}

Wraps an iterator such that each iteration is wrapped in a pcall.

### Uses:

Iterators that can break with an error (eg. database fetch iterators).

--------------------------------------------------------------------------------------------------------------------------

## `glue.pass(...) -> ...` {#pass}

The identity function. Does nothing, returns back all arguments.

### Uses:

Default value for optional callback arguments:

~~~{.lua}
function urlopen(url, callback, errback)
   callback = callback or glue.pass
   errback = errback or glue.pass
   ...
   callback()
end
~~~

--------------------------------------------------------------------------------------------------------------------------

## `glue.inherit(t, parent) -> t` {#inherit}

## `glue.inherit(t, nil) -> t`

Set a table to inherit attributes from a parent table, or clear inheritance.

If the table has no metatable (and inheritance has to be set, not cleared) make it one.

### Examples:

Logging mixin:

~~~{.lua}
AbstractLogger = glue.inherit({}, function(t,k) error('abstract '..k) end)
NullLogger = glue.inherit({log = function() end}, AbstractLogger)
PrintLogger = glue.inherit({log = function(self,...) print(...) end}, AbstractLogger)

HttpRequest = glue.inherit({
   perform = function(self, url)
      self:log('Requesting', url, '...')
      ...
   end
}, NullLogger)

LoggedRequest = glue.inherit({log = PrintLogger.log}, HttpRequest)

LoggedRequest:perform'http://lua.org/'

> Requesting	http://lua.org/	...
~~~

Defining a module in Lua 5.2

~~~{.lua}
_ENV = glue.inherit({},_G)
...
~~~

Hints:

  * to get the effect of static (single or multiple) inheritance, use [glue.update](#update).
  * when setting inheritance, you can pass in a function.

### Design notes:

`t = setmetatable({},{__index=parent})` is not much longer and it's idiomatic, but doesn't shout
inheritance at you (you have to process the indirection, like with functional idioms) and you can't
use it to change the parent (a minor quibble nevertheless).

Overriding of methods needs an easy way to access the "parent" or to invoke a method on the parent.
A top-level class could provide this simply by defining `function Object:parent() return getmetatable(self).__index end`.

--------------------------------------------------------------------------------------------------------------------------

## `glue.fileexists(file) -> true | false` {#fileexists}

Checks whether a file exists and it's available for reading.

See also: [glue.readfile](#readfile).

--------------------------------------------------------------------------------------------------------------------------

## `glue.readfile(file[,format]) -> s` {#readfile}

Read the contents of a file into a string.

  * `format` can be `t` in which case the file will be read in text mode (default is binary mode).

See also: [glue.writefile](#writefile), [glue.fileexists](#fileexists).

--------------------------------------------------------------------------------------------------------------------------

## `glue.writefile(file,s[,format])` {#writefile}

Write the contents of a string to a file.

  * `format` can be `t` in which case the file will be written in text mode (default is binary mode).

See also: [glue.readfile](#readfile).

--------------------------------------------------------------------------------------------------------------------------

## `glue.assert(v[, message[, format_args...]])` {#assert}

Like `assert` but supports formatting of the error message using string.format.

This is better than `assert(string.format(message, format_args...))` because it avoids creating
the message string when the assertion is true.

### Example:

~~~{.lua}
glue.assert(depth <= maxdepth, 'maximum depth %d exceeded', maxdepth)
~~~

--------------------------------------------------------------------------------------------------------------------------

## `glue.unprotect(ok,result,...) -> result,... | nil,result,...` {#unprotect}

In Lua, API functions conventionally signal errors by returning nil and an error message instead of raising exceptions.
In the implementation however, using assert() and error() is preferred to coding explicit conditional flows to cover
exceptional cases. Use this function to convert error-raising functions to nice nil,error-returning functions:

~~~{.lua}
function my_API_function()
  return glue.unprotect(pcall(function()
    ...
    assert(...)
    ...
    error(...)
    ...
    return result_value
  end))
end
~~~

--------------------------------------------------------------------------------------------------------------------------

__Note: Lua 5.2 and LuaJIT 2 only.__

## `glue.pcall(f,...) -> true,... | false,error..'\n'..traceback` {#pcall}

With Lua's pcall() you lose the stack trace, and with usual uses of pcall() you don't want that,
thus this variant that appends the traceback to the error message.

--------------------------------------------------------------------------------------------------------------------------

## `glue.fpcall(f,...) -> result | nil,error..'\n'..traceback` {#fpcall}

## `glue.fcall(f,...) -> result`

These constructs bring the ubiquitous try/finally/except idiom to Lua. The first variant returns nil,error
when errors occur while the second re-raises the error.

### Pseudo-example:

~~~{.lua}
local result = glue.fpcall(function(finally, except, ...)
  local temporary_resource = acquire_resource()
  finally(function() temporary_resource:free() end)
  ...
  local final_resource = acquire_resource()
  except(function() final_resource:free() end)
  ... code that might break ...
  return final_resource
end, ...)
~~~

--------------------------------------------------------------------------------------------------------------------------

## `glue.autoload(t, submodules) -> t` {#autoload}

Assign a metatable to `t` such that when a missing key is accessed, the module said to contain that key is require'd automatically.

The `submodules` argument is a table of form `{key = module_name | load_function}` specifying the corresponding
Lua module (or load function) that make each key available to `t`.

### Motivation:

Module autoloading allows you to split the implementation of a module in many submodules containing optional,
self-contained functionality, without having to make this visible in the user API. This effectively separates
how you split your APIs from how you split the implementation, allowing you to change the way the implementation
is split at a later time while keeping the API intact.

### Example:

**main module (foo.lua):**

~~~{.lua}
local function bar() --function implemented in the main module
  ...
end

--create and return the module table
return glue.autoload({
   ...
   bar = bar,
}, {
   baz = 'foo_extra', --autoloaded function, implemented in module foo_extra
})
~~~

**submodule (foo_extra.lua):**

~~~{.lua}
local foo = require'foo'

function foo.baz(...)
  ...
end
~~~

**in usage:**

~~~{.lua}
local foo = require'foo'

foo.baz(...) -- foo_extra was now loaded automatically
~~~

--------------------------------------------------------------------------------------------------------------------------

### Tips

String functions are also in the `glue.string` table. You can extend the Lua `string` namespace:

	glue.update(string, glue.string)

so you can use them as string methods:

	s = s:trim()


### Keywords
_for syntax highlighting_

glue.index, glue.keys, glue.update, glue.merge, glue.extend, glue.append, glue.shift, glue.gsplit, glue.trim,
glue.escape, glue.collect, glue.ipcall, glue.pass, glue.inherit, glue.fileexists,
glue.readfile, glue.writefile, glue.assert, glue.unprotect, glue.pcall, glue.fpcall, glue.fcall, glue.autoload

### Design

[glue_design]
