
--free lists: dynamic allocation of fixed-size objects from a fixed-size array.
--Written by Cosmin Apreutesei. Public Domain.

local ffi = require'ffi'

local list_mt = {
	__new = function(tp, size)
		local max = size - 1
		local self = ffi.new(tp, max, max, max, max)
		for i = 0, max do
			self.list[i] = self.data + i
		end
		return self
	end,
	__index = {
		get = function(self)
			--
		end,
		put = function(self)
			--
		end,
	},
}

local function makelist(ctype)
	ctype = ffi.typeof(ctype)
	local tp = ffi.typeof([[
		struct {
			int top;
			int max;
			$  data[?];
			$* list[?];
		}
		]], ctype, ctype)
  return ffi.metatype(tp, list_mt)
end

if not ... then
	local list = makelist'int'
	local f = list(4)
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
