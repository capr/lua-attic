--Lua C API binding for Lua 5.1 (Cosmin Apreutesei, public domain)
require'lua_h'
local ffi = require'ffi'
local C = ffi.C
local M = {C = C}

--states

function M.new_state()
	local L = C.luaL_newstate()
	assert(L ~= nil)
	ffi.gc(L, M.close)
	return L
end

function M.close(L)
	ffi.gc(L, nil)
	C.lua_close(L)
end

M.status = C.lua_status --0, error or LUA_YIELD

--compiler

function M.loadbuffer(L, buf, sz, chunkname)
	assert(C.luaL_loadbuffer(L, buf, sz, chunkname) == 0)
end

function M.loadstring(L, s, name)
	M.loadbuffer(L, s, #s, name)
end

function M.loadfile(L, filename)
	assert(C.luaL_loadfile(L, filename) == 0)
end

function M.load(L, reader, data, chunkname)
	local reader_cb
	if type(reader) == 'function' then
		reader_cb = ffi.cast('lua_Reader', reader)
	end
	local ret = C.lua_load(L, reader_cb or reader, data, chunkname)
	if reader_cb then reader_cb:free() end
	if ret ~= 0 then error(string.format('lua_load error: %d', ret)) end
end

local lib_openers = {
	base = C.luaopen_base,
	table = C.luaopen_table,
	io = C.luaopen_io,
	os = C.luaopen_os,
	string = C.luaopen_string,
	math = C.luaopen_math,
	debug = C.luaopen_debug,
	package = C.luaopen_package,
}

function M.openlibs(L, ...) --open specific libs (or all libs if no args)
	local n = select('#',...)
	if n == 0 then
		C.luaL_openlibs(L)
		return
	end
	for i=1,n do
		C.lua_pushcclosure(L, assert(lib_openers[select(i,...)]), 0)
		C.lua_call(L, 0, 0)
	end
end

--stack (read)

M.gettop = C.lua_gettop

local lua_types = {
	[C.LUA_TNIL] = 'nil',
	[C.LUA_TBOOLEAN] = 'boolean',
	[C.LUA_TLIGHTUSERDATA] = 'lightuserdata',
	[C.LUA_TNUMBER] = 'number',
	[C.LUA_TSTRING] = 'string',
	[C.LUA_TTABLE] = 'table',
	[C.LUA_TFUNCTION] = 'function',
	[C.LUA_TUSERDATA] = 'userdata',
	[C.LUA_TTHREAD] = 'thread',
}

function M.type(L, index)
	local t = C.lua_type(L, index)
	assert(t ~= C.LUA_TNONE)
	return lua_types[t]
end

function M.lua_toboolean(L, index)
	return C.lua_toboolean(L, index) == 1
end

M.tonumber = C.lua_tonumber
M.tothread = C.lua_tothread
M.touserdata = C.lua_touserdata

local sz
function M.tolstring(L, index)
	sz = sz or ffi.new('size_t[1]')
	return C.tolstring(L, index, sz), sz[0]
end

function M.tostring(L, index)
	return ffi.string(C.lua_tolstring(L, index))
end

M.next = C.lua_next
M.gettable = C.lua_gettable

function M.get(L, index, dupes)
	index = index or -1
	local t = M.type(L, index)
	if t == 'nil' then
		return nil
	elseif t == 'boolean' then
		return M.toboolean(L, index)
	elseif t == 'lightuserdata' or t == 'userdata' then
		return M.touserdata(L, index)
	elseif t == 'number' then
		return M.tonumber(L, index)
	elseif t == 'string' then
		return M.tostring(L, index)
	elseif t == 'table' then
		local dt = {}
		C.lua_pushnil(L) -- first key
		while C.lua_next(L, index) ~= 0 do
			local k = M.get(L, -2, dupes)
			local v = M.get(L, -1, dupes)
			dt[k] = v
			C.lua_pop(L, 1) -- remove 'value'; keep 'key' for next iteration
		end
		return dt
	elseif t == 'function' then
		--TODO
	elseif t == 'thread' then
		--TODO
	end
end

function M.pop(L, n)
	C.lua_settop(L, -(n or 1) - 1)
end

--stack (write)

M.settop = C.lua_settop
M.pushnil = C.lua_pushnil
M.pushboolean = C.lua_pushboolean
M.pushinteger = C.lua_pushinteger
M.pushnumber = C.lua_pushnumber
M.pushcclosure = C.lua_pushcclosure
function M.pushcfunction(L, f)
	C.lua_pushcclosure(L, f, 0)
end
M.pushlightuserdata = C.lua_pushlightuserdata
function M.pushstring(L, s, sz)
	C.lua_pushlstring(L, s, sz or #s)
end
M.pushthread = C.lua_pushthread
M.pushvalue = C.lua_pushvalue --push stack element

function M.push(L, v)
	if type(v) == 'nil' then
		M.pushnil(L)
	elseif type(v) == 'boolean' then
		M.pushboolean(L, v)
	elseif type(v) == 'number' then
		M.pushnumber(L, v)
	elseif type(v) == 'string' then
		M.pushstring(L, v)
	elseif type(v) == 'table' then
		--TODO
	elseif type(v) == 'function' then
		M.loadstring(L, string.dump(v))
	elseif type(v) == 'userdata' then
		--M.pushlightuserdata(L, v)
		--TODO
	elseif type(v) == 'thread' then
		M.pushthread(L, v)
	elseif type(v) == 'cdata' then
		--TODO
	end
end

--stack (copy)

function M.copy(L, index, dL)
	index = index or -1
	local t = C.lua_type(L, index)
	if t == C.LUA_TNIL then
		C.lua_pushnil(dL)
	elseif t == C.LUA_TBOOLEAN then
		C.lua_pushboolean(dL, C.lua_toboolean(L, index))
	elseif t == C.LUA_TNUMBER then
		C.lua_pushnumber(dL, C.lua_tonumber(L, index))
	elseif t == C.LUA_TSTRING then
		M.pushstring(dL, M.tolstring(L, index))
	elseif t == C.LUA_TFUNCTION then
		C.lua_pushvalue(L, index)
		C.lua_dump(L, writer, 0)
		C.lua_pop(L, 1)
		--M.loadbuffer()
		--TODO: dump to a string buffer in the dest. state
	elseif t == C.LUA_TLIGHTUSERDATA then
		C.lua_pushlightuserdata(dL, C.lua_touserdata(L, index))
	elseif t == C.LUA_TUSERDATA then
		--TODO:
	elseif t == 'thread' then
		--TODO
	elseif t == C.LUA_TTABLE then
		local dt = {}
		C.lua_pushnil(L) -- first key
		while C.lua_next(L, index) ~= 0 do
			local k = M.get(L, -2)
			local v = M.get(L, -1)
			dt[k] = v
			C.lua_pop(L, 1) -- remove 'value'; keep 'key' for next iteration
		end
		return dt
	end
end

--calling functions

function M.pcall(L, nargs, nresults, errfunc)
	nresults = nresults or C.LUA_MULTRET
	errfunc = errfunc or 0
	return C.lua_pcall(L, nargs, nresults, errfunc)
end

--hi-level API

function M.pcall(L, f, ...)
	--
end

ffi.metatype('lua_State', {__index = {
	--states
	close = M.close,
	status = M.status,
	--compiler
	loadbuffer = M.loadbuffer,
	loadstring = M.loadstring,
	load = M.load,
	openlibs = M.openlibs,
	--stack (read)
	gettop = M.gettop,
	type = M.type,
	toboolean = M.toboolean,
	tonumber = M.tonumber,
	tothread = M.tothread,
	touserdata = M.touserdata,
	tolstring = M.tolstring,
	tostring = M.tostring,
	next = M.next,
	gettable = M.gettable,
	get = M.get,
	pop = M.pop,
	--stack (write)
	settop = M.settop,
	pushnil = M.pushnil,
	pushboolean = M.pushboolean,
	pushinteger = M.pushinteger,
	pushcclosure = M.pushcclosure,
	pushcfunction = M.pushcfunction,
	pushlightuserdata = M.pushlightuserdata,
	pushstring = M.pushstring,
	pushthread = M.pushthread,
	pushvalue = M.pushvalue,
	push = M.push,
	--calling functions
	pcall = M.pcall,
}})

if not ... then
	local lua = M.new_state()
	lua:openlibs('base')
	lua:openlibs()
	lua:loadstring('print("hello"); return 42, nil, "str"')
	print(lua:pcall(0))
	print(lua:gettop())
	for i=1,3 do
		print(lua:type(-i), lua:tostring(-i))
	end
	lua:close()
end

return M
