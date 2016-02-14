
-- unidirectional table-based ring buffers that can grow on request.
-- Written by Cosmin Apreutesei. Public Domain.

local bit = require'bit'
local min, max, band, assert = math.min, math.max, bit.band, assert

--select the offset normalization function to use: if the buffer size
--is a power-of-2, we can normalize offsets faster.
local function offset_and(self, offset) return band(offset, (self.size - 1)) end
local function offset_mod(self, offset) return offset % self.size end
local function offset_func(size)
	local pow2_size = band(size, size - 1) == 0
	return pow2_size and offset_and or offset_mod
end

--given a buffer (0, size) and a segment (offset, length) where `length`
--can exceed `size`, return the two segments (offset1, length1) and
--(offset2, length2) that map the input segment to the buffer.
local function segments(offset, length, size)
	local length1 = size - offset
	return offset, min(length, length1), 0, max(0, length - length1)
end

local vbuf = {}

function vbuf:offset(offset)
	return self:_offset(offset - 1) + 1 --count from 1
end

function vbuf:push(v)
	local start, length, size = self.start, self.length, self.size
	assert(size - length >= 1, 'buffer overflow')
	local i = self:offset(start + length)
	self.length = length + 1
	self.data[i] = v
	return i
end

function vbuf:pull()
	local start, length = self.start, self.length
	assert(length >= 1, 'buffer underflow')
	local i = self:offset(start)
	local v = self.data[i]
	self.data[i] = nil
	return v
end

function vbuf:head(ofs) return self:offset(self.start + ofs) end
function vbuf:tail(ofs) return self:offset(self.start + ofs + self.length) end

function vbuf:checksize(len)
	if len <= self.size - self.length then return end
	local newsize = max(self.size * 2, self.length + len)
	local i1, n1, i2, n2 = segments(self.start, self.length, self.size)
	if n1 > n2 then --move segment 2 right after segment 1
		local o = i1 + n1 - 1
		for i = 1, n2 do
			self.data[o + i] = self.data[i]
			self.data[i] = false --keep the slot
		end
	else --move segment 1 to the end of the new buffer
		local o = newsize - n1 + 1
		for i = 0, n1-1 do
			self.data[o + i] = self.data[i1 + i]
			self.data[i1 + i] = false --keep the slot
		end
		self.start = o
	end
	self.size = newsize
	self.last = newsize
	self.offset = offset_func(newsize)
end

local function vbuffer(self)
	self.start = self.start or 1
	self.length = self.length or 0
	self.size = self.size or 0
	self.last = self.size
	self.data = self.data or {}
	self._offset = offset_func(self.size)
	for k,v in pairs(vbuf) do self[k] = v end --copy methods
	return self
end

return {
	--algorithm
	offset_func = offset_func,
	segments = segments,
	--data structures
	cbuffer = cbuffer,
	vbuffer = vbuffer,
}
