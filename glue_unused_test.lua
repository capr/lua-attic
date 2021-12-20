glue.luapath('foo')
glue.cpath('bar')
glue.luapath('baz', 'after')
glue.cpath('zab', 'after')
local so = package.cpath:match'%.dll' and 'dll' or 'so'
local norm = function(s) return s:gsub('/', package.config:sub(1,1)) end
assert(package.path:match('^'..glue.esc(norm'foo/?.lua;')))
assert(package.cpath:match('^'..glue.esc(norm'bar/?.'..so..';')))
assert(package.path:match(glue.esc(norm'baz/?.lua;baz/?/init.lua')..'$'))
assert(package.cpath:match(glue.esc(norm'zab/?.'..so)..'$'))
