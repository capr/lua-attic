setfenv(1, require'low')

includepath'$L/csrc/xxhash'
include'xxhash.h'
linklibrary'xxhash'

local fnv_1a = terra(s: &uint8, n: int64, d: uint32): uint32 --FNV-1A
	for i=0,n do
		d = (d ^ s[i]) * 16777619
	end
	return d
end

local fnv_1a2 = macro(function(k, n, s)
	return quote
		for i=0,n do
			s = ((s ^ k[i]) * 16777619) and 0x7fffffff
		end
		in s
	end
end)

local xxh32 = macro(function(k, n, s) return `XXH32(k, n, s) end)
local xxh64 = macro(function(k, n, s) return `XXH64(k, n, s) end)

local benchmark = macro(function(s, hash, iter, seed, out_t)
	local sz = floor(1024^2 * 1)
	local iter = iter or 100
	out_t = out_t:astype()
	return quote
		var key = new(uint8, sz)
		for i=0,sz do key[i] = i end
		var h: out_t = seed
		var t0 = clock()
		for i=1,iter do
			h = hash(key, sz, h)
		end
		var t1 = clock()
		free(key)
		pfn('%s  %8.2f MB/s (%d)', s, [double](sz) * iter / pow(1024, 2) / (t1 - t0), h)
	end
end)

terra test()
	benchmark('xxHash32 C     ', xxh32, 4096, 0, uint32)
	benchmark('xxHash64 C     ', xxh64, 4096, 0, uint64)
	benchmark('FNV-1A Terra   ', fnv_1a, 4096, 0x811C9DC5, int32)
end
test()
