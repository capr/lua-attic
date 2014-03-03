--a way to send cdata types accross Lua states
local ffi = require'ffi'

local function pickle(cdata)
	return tonumber(ffi.cast('intptr_t', ffi.cast('void*', cdata)))
end

local function unpickle(n, ctype)
	return ffi.cast(ctype, n)
end

if not ... then
	local pp = require'pp'.pp
	local n = ffi.new('int[1]')
	local t = pickle(n, 'int*')
	print(string.format('%s, 0x00%x', tostring(n), t.cdata))
	print(unpickle(t))
end

return {
	pickle = pickle,
	unpickle = unpickle,
}
