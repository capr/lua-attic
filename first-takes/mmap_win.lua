
--portable memory mapping for LuaJIT / Windows backend
--Written by Cosmin Apreutesei. Public Domain.

if not ... then require'mmap_test'; return end

local ffi = require'ffi'
local bit = require'bit'
setfenv(1, require'mmap_common')

