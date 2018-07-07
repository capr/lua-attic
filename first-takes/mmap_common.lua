
--portable memory mapping for LuaJIT / common code
--Written by Cosmin Apreutesei. Public Domain.

if not ... then require'mmap_test'; return end

local ffi = require'ffi'
local bit = require'bit'

local backend = setmetatable({}, {__index = _G})
setfenv(1, backend)

fs = require'fs'
local fsbk = fs.backend

cdef = ffi.cdef

x64 = fsbk.x64
osx = fsbk.osx
linux = fsbk.linux
win = fsbk.win
check = fsbk.check

return backend
