
setfenv(1, require'low')

local struct bitmask {
	data: &uint8;
	w: int;
	h: int;
}

terra bitmask:init()
	fill(self)
end

terra bitmask:stride(w: int)
	return [int](ceil(w / 8.0))
end

terra bitmask:bytesize(w: int, h: int)
	return [int64](self:stride(w)) * h
end

terra bitmask:rowaddr(y: int, w: int)
	return self.data + (self:stride(w) * y)
end

terra bitmask:widen(w: int, h: int)
	if w <= self.w and h <= self.h then return end
	w = max(w, self.w)
	h = max(h, self.h)
	var new_data = alloc(uint8, self:bytesize(w, h), self.data)
	assert(new_data ~= nil)
	if self.w > 0 and self.w < w then
		for y = self.h-1, -1, -1 do
			copy(self:rowaddr(y, w), self:rowaddr(y, self.w), self:stride(self.w))
		end
	end
	self.data = new_data
	self.w = w
	self.h = h
end

terra bitmask:addr(x: int, y: int)
	var b = [int64](self:stride(self.w)) * y + x
	return b / 8, 7-[int8](b % 8)
end

terra bitmask:get(x: int, y: int)
	assert(x >= 0 and x < self.w)
	assert(y >= 0 and y < self.h)
	var B = @self:rowaddr(y, self.w)
	var b: uint8 = x % 8
	return ((B >> b) and 1) == 1
end

bitmask.methods.set = overload'set'
bitmask.methods.set:adddefinition(terra(self: &bitmask,
	x: int, y: int, val: bool
)
	assert(x >= 0 and x < self.w)
	assert(y >= 0 and y < self.h)
	var i,b = self:addr(x, y)
	var mask = self.data[i]
	if val then
		self.data[i] = self.data[i] or mask
	else
		self.data[i] = self.data[i] and not mask
	end
end)

bitmask.methods.set:adddefinition(terra(self: &bitmask,
	x1: int, y1: int, w: int, h: int, val: bool
)
	var x2 = x1 + w
	var y2 = y1 + h
	x1 = clamp(x1, 0, self.w)
	y1 = clamp(y1, 0, self.h)
	x2 = clamp(x2, 0, self.w)
	y2 = clamp(y2, 0, self.h)
	if x2 < x1 then x1, x2 = x2, x1 end
	if y2 < y1 then y1, y2 = y2, y1 end

	var stride = self:stride(self.w)
	var data = self.data
	var i1 = x1 / 8.0
	var i2 = x2 / 8.0
	var bi1: int64 = ceil(i1)  --index of first full byte
	var bi2: int64 = i2 --index of last full byte + 1
	var bytes = bi2 - bi1 --number of full bytes
	var bits1: uint8 = (bi1 - i1) * 8 --leftover bits at the beginning
	var bits2: uint8 = (i2 - bi2) * 8 --leftover bits at the end
	--bit masks for leftover bits
	var mask0: uint8 = 0
	var mask1: uint8 = 0
	var mask2: uint8 = 0
	if bytes < 0 then --all bits are on the same byte
		var bits = bits2 - (8-bits1)
		mask0 = ((1 << bits) - 1) << (8-bits1)
	else
		mask1 = iif(bits1 > 0, not((1 << 8-bits1) - 1), 0)
		mask2 = iif(bits2 > 0, (1 << bits2) - 1, 0)
	end
	var bits = iif(val, 0xff, 0)
	for y = y1, y2 do
		var bi1 = y * stride + bi1
		var bi2 = y * stride + bi2
		if bytes < 0 then --all bits are on the same byte
			if val then
				data[bi2] = data[bi2] or mask0
			else
				data[bi2] = data[bi2] and not mask0
			end
		else
			fill(data + bi1, bytes, bits)
			if mask1 ~= 0 then
				if val then
					data[bi1-1] = data[bi1-1] or mask1
				else
					data[bi1-1] = data[bi1-1] and not mask1
				end
			end
			if mask2 ~= 0 then
				if val then
					data[bi2] = data[bi2] or mask2
				else
					data[bi2] = data[bi2] and not mask2
				end
			end
		end
	end
end)

local terra test()
	var b: bitmask; b:init(); b:widen(32, 32)
	b:set(0, 0, 1, 1, true)
	for y=0,b.h do
		for x=0,b.w do
			putchar(iif(b:get(x, y), ('1')[0], ('_')[0]))
		end
		putchar(('\n')[0])
	end

end
test()
