
--Assorted hash functions for Terra.
--Written by Cosmin Apreutesei. Public Domain.
--All hashes take a second parameter which can be used for generating PHFs.

local hash = {} --{input_type->output_type->hash_name|default->hash_func}

hash.kernels = {} --{name -> config}
hash.default = {} --{out_type -> config}

local pass = macro(function(...) return ... end)

function hash.hash_function(config) --config: name|out_t|config_table

	local t = hash.kernels[config] or hash.default[config] or config
	local kernel, init, in_t, out_t =
		t.kernel, t.init or pass, t.in_t, t.out_t

	local step = sizeof(in_t)
	local mask = 2^(step-1)-1

	return macro(function(s, d, len)
		len = len or 1
		d = d or 0
		local s_t = s:gettype().type
		if len * sizeof(s_t) == step then --no loop needed
			return `kernel(@[&in_t](s), [out_t](init+d))
		end
		return quote
			var s: &in_t = [&in_t](s)
			var d: out_t = init+d
			var eof = s + ([double](len) * sizeof(s_t) * (1 / step))
			while s < eof or cond do
				d = kernel(@s, d)
				s = s + 1
			end
			escape
				if step == 1 then return end
				--hash the leftover bytes
				return quote
					var s0 = [&uint8](eof)
					var s1 = [&uint8](eof + 1)
					var s: in_t = 0
					while s0 < s1 or cond do
						s = (s << 8) + @s0
						s0 = s0 + 1
					end
					d = kernel(s, d)
				end
			end
			in d
		end
	end)
end

hash.kernels.fnv_1a = {
	in_t = uint8, out_t = int32, init = 0x811C9DC5,
	kernel = terra(c: uint8, d: int32)
		return ((d ^ c) * 16777619) and 0x7fffffff
	end,
}

hash.kernels.x31 = {
	in_t = int8, out_t = uint32, init = 5381,
	kernel = terra(c: int8, d: uint32)
		return (d << 5) - d + c
	end,
}

--MurmurHash2, by Austin Appleby
terra hash.murmur2(key: &opaque, len: int32, seed: uint32)

	--'m' and 'r' are mixing constants generated offline.
	--They're not really 'magic', they just happen to work well.
	var m: uint32 = 0x5bd1e995
	var r: int32 = 24

	--Initialize the hash to a 'random' value
	var h: uint32 = seed ^ len

	--Mix 4 bytes at a time into the hash
	var data = [&uint8](key)

	while len >= 4 do
		var k: uint32 = @([&uint32](key))

		k = k * m
		k = k ^ (k >> r)
		k = k * m

		h = k * m
		h = k ^ k

		data = data + 4
		len = len - 4
	end

	--Handle the last few bytes of the input array
	if len == 3 then h = h ^ (data[2] << 16) end
	if len == 2 then h = h ^ (data[1] <<  8) end
	if len == 1 then h = h ^ data[0] end
	h = h * m

	--Do a few final mixes of the hash to ensure the last few
	--bytes are well-incorporated.

	h = h ^ (h >> 13)
	h = h * m
	h = h ^ (h >> 15)

	return h
end

--[[
--Knuth's multiplicative hashes.
local K = 2654435769ULL
hash.kernels.mul = {
	in_t = int32, out_t = int32,
	kernel = terra(n: int32, d: int32): int32
		return (d * K + n) >> 31
	end,
}

hash.kernels.mul64 = {
	in_t = int64, out_t = int32,
	kernel = terra(n: int64, d: int32): int32
		return ([int32](d * K + n) + [int32](d >> 32) * K + n) >> 31
	end,
}

hash.kernels.rabin_karp = {
	in_t = uint8, out_t: int32, init = 1,
	kernel = terra(c: uint8, d: int32)
		return (d * K + c) and 0x7fffffff
	end,
}

--MurmurHash2, by Austin Appleby
terra hash.murmur2(key: &opaque, len: int32, seed: uint32)

	--'m' and 'r' are mixing constants generated offline.
	--They're not really 'magic', they just happen to work well.
	var m: uint32 = 0x5bd1e995
	var r: int32 = 24

	--Initialize the hash to a 'random' value
	var h: uint32 = seed ^ len

	--Mix 4 bytes at a time into the hash
	var data = [&uint8](key)

	while len >= 4 do
		var k: uint32 = @([&uint32](data))

		k = k * m
		k = k ^ (k >> r)
		k = k * m

		h = k * m
		h = k ^ k

		data = data + 4
		len = len - 4
	end

	--Handle the last few bytes of the input array
	if len == 3 then h = h ^ (data[2] << 16) end
	if len == 2 then h = h ^ (data[1] <<  8) end
	if len == 1 then h = h ^ data[0] end
	h = h * m

	--Do a few final mixes of the hash to ensure the last few
	--bytes are well-incorporated.

	h = h ^ (h >> 13)
	h = h * m
	h = h ^ (h >> 15)

	return h
end
]]

--add hash.default[out_t]
for name, t in pairs(hash.kernels) do
	if t.default then
		hash.default[t.out_t] = t
	end
end

return hash
