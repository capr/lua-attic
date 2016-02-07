
--free lists: dynamic allocation of fixed-size objects from a fixed-size array.
--Written by Cosmin Apreutesei. Public Domain.

local ffi = require'ffi'

local list = {}

function list:alloc_data(size)
	return ffi.new(self.atype, size)
end

function list:alloc_list(size)
	return ffi.new(self.ltype, size)
end

function list:get()
	assert(self.last >= 0, 'freelist empty')
	local p = self.list[self.last]
	self.last = self.last - 1
	return p
end

function list:put(p)
	assert(self.last < self.size, 'freelist full')
	self.last = self.last + 1
	self.list[self.last] = p
end

function list:length()
	return self.last + 1
end

function list:new(t)
	local size = assert(t.size, 'size missing')
	assert(size >= 1 and size <= 2^52, 'size out of range')
	assert(t.ctype, 'ctype missing')
	t.__index = self
	local self = setmetatable(t, t)
	self.size  = size
	self.ctype = ffi.typeof(t.ctype)
	self.atype = ffi.typeof('$[?]', self.ctype)
	self.ltype = ffi.typeof('$*[?]', self.ctype)
	self.data = t.data or self:alloc_data(size)
	self.list = self:alloc_list(size)
	if t.last then
		--consider the list initialized
		self.last = t.last
	else
		--initialize the list: all slots are free
		self.last = size-1
		for i = 0, self.last do
			self.list[i] = self.data + i
		end
	end
	return self
end

setmetatable(list, list)
list.__call = list.new


if not ... then
	local f = list{ctype = 'int', size = 4}
	local t = {}
	for i = 1, 4 do
		t[i] = f:get()
		print(t[i], f:length())
	end

	for i = 1, 4 do
		f:put(t[i])
		print(f:length())
	end
end


return list
