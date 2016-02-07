
--sha1 based on code by Chris Osgood (C) 2011 MIT License.

local ffi = require'ffi'
local bit = require'bit'

local band, bor, bxor, bnot, rshift, lshift, rol, bswap, tohex =
		bit.band, bit.bor, bit.bxor, bit.bnot, bit.rshift, bit.lshift, bit.rol,
		bit.bswap, bit.tohex

local uint32_ptr = ffi.typeof'uint32_t*'
local w = ffi.new'uint32_t[80]'

local function nbinary32(n)
	return string.char(band(rshift(n, 24), 0xFF),
							 band(rshift(n, 16), 0xFF),
							 band(rshift(n, 8), 0xFF),
							 band(n, 0xFF))
end

local function digest()

	local hash = {
		0x67452301, -- h0
		0xEFCDAB89, -- h1
		0x98BADCFE, -- h2
		0x10325476, -- h3
		0xC3D2E1F0, -- h4
		0,          -- data length
		'',         -- partial data buffer
		nil         -- flag: hash is finalized
	}

	local function update(data)

		hash[6] = hash[6] + #data
		data = hash[7]..data

		-- Process 512-bit chunks
		local steps = math.floor(#data / 64) * 16 - 1
		local pdata = ffi.cast(uint32_ptr, data)

		for pos=0,steps,16 do
			for i=0,15,1 do
				w[i] = bswap(pdata[pos + i])
			end

			for i=16,79,1 do
				w[i] = rol(bxor(bxor(bxor(w[i-3], w[i-8]), w[i-14]), w[i-16]), 1)
			end

			local a,b,c,d,e = hash[1],hash[2],hash[3],hash[4],hash[5]
			local f,k,temp

			-- Main loop
			for i=0,19,1 do
				f, k = bor(band(b, c), band(bnot(b), d)), 0x5A827999
				temp = band(rol(a, 5) + f + e + k + w[i], 0xFFFFFFFF)
				e,d,c,b,a = d,c,rol(b, 30),a,temp
			end
			for i=20,39,1 do
				f, k = bxor(bxor(b, c), d), 0x6ED9EBA1
				temp = band(rol(a, 5) + f + e + k + w[i], 0xFFFFFFFF)
				e,d,c,b,a = d,c,rol(b, 30),a,temp
			end
			for i=40,59,1 do
				f, k = bor(bor(band(b, c), band(b, d)), band(c, d)), 0x8F1BBCDC
				temp = band(rol(a, 5) + f + e + k + w[i], 0xFFFFFFFF)
				e,d,c,b,a = d,c,rol(b, 30),a,temp
			end
			for i=60,79,1 do
				f, k = bxor(bxor(b, c), d), 0xCA62C1D6
				temp = band(rol(a, 5) + f + e + k + w[i], 0xFFFFFFFF)
				e,d,c,b,a = d,c,rol(b, 30),a,temp
			end

			hash[1] = band(hash[1] + a, 0xFFFFFFFF)
			hash[2] = band(hash[2] + b, 0xFFFFFFFF)
			hash[3] = band(hash[3] + c, 0xFFFFFFFF)
			hash[4] = band(hash[4] + d, 0xFFFFFFFF)
			hash[5] = band(hash[5] + e, 0xFFFFFFFF)
		end

		hash[7] = data:sub((steps+1) * 4 + 1)
	end

	local function final(data)
		if not hash[8] then
			-- Pre-processing
			data = data or ''
			local len = (hash[6] + #data) * 8

			-- FIXME: need 64-bit "bit" functions
			len = string.char(band(math.floor(len / 0x100000000000000), 0xFF),
									band(math.floor(len / 0x1000000000000), 0xFF),
									band(math.floor(len / 0x10000000000), 0xFF),
									band(math.floor(len / 0x100000000), 0xFF),
									band(rshift(len, 24), 0xFF),
									band(rshift(len, 16), 0xFF),
									band(rshift(len, 8), 0xFF),
									band(len, 0xFF))

			local pad = 64 - ((hash[6] + 9) % 64)
			if pad == 64 then pad = 0 end
			data = data.."\128"..string.rep("\0", pad)..len

			-- Produce the final hash value
			update(hash, data)
			hash[8] = true
		end

		return nbinary32(hash[1])..
				 nbinary32(hash[2])..
				 nbinary32(hash[3])..
				 nbinary32(hash[4])..
				 nbinary32(hash[5])
	end

	local s1
	return function(s)
		if not s then
			return final(s1)
		else
			update(s)
		end
	end
end

return {
	sum = sum,
	digest = digest,
}
