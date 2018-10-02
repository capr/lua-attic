
--Bidimensional 1-bit-array-based selection masks.
--Written by Cosmin Apreutesei. Public Domain.

local ffi = require'ffi'
local bit = require'bit'

local min, max, floor, ceil = math.min, math.max, math.floor, math.ceil
local band, bor, shr, shl, bnot =
	bit.band, bit.bor, bit.rshift, bit.lshift, bit.bnot

local function clamp(x, x0, x1)
	return min(max(x, x0), x1)
end

--static, auto-growing buffer allocation pattern (from glue).
local function growbuffer(ctype, growth_factor)
	local ctype = ffi.typeof(ctype or 'char[?]')
	growth_factor = growth_factor or 1
	local buf, len = nil, -1
	return function(newlen)
		if not newlen then
			buf, len = nil, -1
		elseif newlen > len then
			len = math.max(newlen, len * growth_factor)
			buf = ctype(len)
		end
		return buf, newlen
	end
end

local bitarray = {}
setmetatable(bitarray, bitarray)

function bitarray:realloc(w, h)
	self.w = max(0, w)
	self.h = max(0, h)
	self.stride = ceil(self.w / 8)
	self.data = self.buffer(self.stride * self.h)
	self.max_i = self.stride * self.h - 1/8
end

function bitarray:__call(w, h)
	self = {__index = self}
	setmetatable(self, self)
	self.buffer = growbuffer('char[?]', 2)
	self:realloc(w, h)
	return self
end

function bitarray:get(x, y)
	local i = clamp(y * self.stride + x / 8, 0, self.max_i)
	local bit = band(i*8, 7)
	return band(shr(self.data[i], bit), 1) == 1
end

function bitarray:set(x, y, val)
	local i = clamp(y * self.stride + x / 8, 0, self.max_i)
	local mask = shl(1, band(i*8, 7))
	if val then
		self.data[i*8] = bor(self.data[i/8], mask)
	else
		self.data[i*8] = band(self.data[i/8], bnot(mask))
	end
end

function bitarray:rect(x1, y1, w, h, val)
	local x2 = x1 + w
	local y2 = y1 + h
	local w = self.w
	local h = self.h
	x1 = clamp(x1, 0, w)
	x2 = clamp(x2, 0, w)
	y1 = clamp(y1, 0, h)
	y2 = clamp(y2, 0, h)
	if x2 < x1 then
		x1, x2 = x2, x1
	end
	if y2 < y1 then
		y1, y2 = y2, y1
	end
	local stride = self.stride
	local data = self.data
	local fill = ffi.fill
	local i1 = x1 / 8
	local i2 = x2 / 8
	local bi1 = ceil(i1)  --index of first full byte
	local bi2 = floor(i2) --index of last full byte + 1
	local bytes = bi2 - bi1 --number of full bytes
	local bits1 = (bi1 - i1) * 8 --leftover bits at the beginning
	local bits2 = (i2 - bi2) * 8 --leftover bits at the end
	local mask0, mask1, mask2 --bit masks for leftover bits
	if bytes < 0 then --all bits are on the same byte
		local bits = bits2 - (8-bits1)
		mask0 = shl(shl(1, bits) - 1, 8-bits1)
	else
		mask1 = bits1 > 0 and bnot(shl(1, 8-bits1) - 1)
		mask2 = bits2 > 0 and shl(1, bits2) - 1
	end
	local bits = val and 0xff or 0
	for y = y1, y2-1 do
		local bi1 = y * stride + bi1
		local bi2 = y * stride + bi2
		if mask0 then --all bits are on the same byte
			if val then
				data[bi2] = bor(data[bi2], mask0)
			else
				data[bi2] = band(data[bi2], bnot(mask0))
			end
		else
			fill(data + bi1, bytes, bits)
			if mask1 then
				if val then
					data[bi1-1] = bor(data[bi1-1], mask1)
				else
					data[bi1-1] = band(data[bi1-1], bnot(mask1))
				end
			end
			if mask2 then
				if val then
					data[bi2] = bor(data[bi2], mask2)
				else
					data[bi2] = band(data[bi2], bnot(mask2))
				end
			end
		end
	end
end

function bitarray:insert_rows(y, h, val) --shift rows down
	local data1, h1 = self.data, self.h
	self:realloc(self.w, self.h + h)
	if self.data ~= data1 then --data was relocated, copy contents over
		ffi.copy(self.data, data1, self.stride * h1)
	end
	local i1 = self.stride * y
	local i2 = self.stride * (y + h)
	local size = self.stride * self.h - i2
	ffi.copy(self.data + i2, self.data + i1, size)
	self:rect(0, y, self.w, h, val)
	self.h = self.h + h
	self.max_i = self.stride * self.h
end

function bitarray:remove_rows(y, h) --shift rows up
	y = clamp(y, 0, self.h)
	h = clamp(h, 0, self.h - y)
	local i1 = self.stride * y
	local i2 = self.stride * (y + h)
	local size = self.stride * self.h - i2
	ffi.copy(self.data + i1, self.data + i2, size)
	self.h = self.h - h
	self.max_i = self.stride * self.h
end


if not ... then

local b = bitarray(58, 40)
b:rect(0, 0, 1/0, 1/0, true)
for i=0,b.w do
	b:rect(i * 2 - 2, i, i, 1, false)
end
for i=0,b.w do
	b:rect(b.w-i+1, i, -i, 4, false)
end
b:remove_rows(0, 5)
b:remove_rows(b.h - 5, 5)
b:remove_rows(30, 50)
b:insert_rows(15, 50)
for y=0,b.h-1 do
	for x=0,b.w-1 do
		io.stdout:write(b:get(x, y) and '1' or '_')
	end
	io.stdout:write'\n'
end

end

return bitarray
