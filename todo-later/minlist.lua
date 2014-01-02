--minlist: lis that keeps a minimum number of slots allocated to reduce gc pressure.
local glue = require'glue'

local minlist = {}
minlist.__index = minlist

function minlist:new(minsize)
	return setmetatable({minsize = minsize, len = 0}, self)
end

function minlist:insert(i, v)
	assert(i >= 1 and i <= #self + 1)
	if self.len < #self then
		glue.shift(self, i, 1)
		self[i] = v
	else
		table.insert(self, i, v)
	end
	self.len = self.len + 1
end

function minlist:remove(i)
	assert(i >= 1 and i <= #self + 1)
	local v = self[i]
	if #self > self.minsize then
		table.remove(self, i)
	else
		glue.shift(self, i, -1)
		self[self.len] = false --release the ref. to the last element and keep the slot
	end
	self.len = self.len - 1
	return v
end

return minlist
