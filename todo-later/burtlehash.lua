
-- One of Bob Jenkins' hashes from
-- http://burtleburtle.net/bob/hash/integer.html.  It's about twice as
-- fast as MurmurHash3_x86_32 and seems to do just as good a job --
-- tables using this hash function seem to have the same max
-- displacement as tables using the murmur hash.

-- Written by Andy Wingo. MIT License.

local ffi = require'ffi'
local bit = require'bit'
local cast = ffi.cast
local tobit, bor, bxor, lshift, rshift, bnot =
	bit.tobit, bit.bor, bit.bxor, bit.lshift, bit.rshift, bit.bnot

local uint16_ptr_t = ffi.typeof'uint16_t*'
local uint32_ptr_t = ffi.typeof'uint32_t*'
local uint64_ptr_t = ffi.typeof'uint64_t*'

local uint32_cast = ffi.new'uint32_t[1]'
local function hash_32(i32)
	i32 = tobit(i32)
	i32 = i32 + bnot(lshift(i32, 15))
	i32 = bxor(i32, (rshift(i32, 10)))
	i32 = i32 + lshift(i32, 3)
	i32 = bxor(i32, rshift(i32, 6))
	i32 = i32 + bnot(lshift(i32, 11))
	i32 = bxor(i32, rshift(i32, 16))

	-- Unset the low bit, to distinguish valid hashes from HASH_MAX.
	i32 = lshift(i32, 1)

	-- Project result to u32 range.
	uint32_cast[0] = i32
	return uint32_cast[0]
end

local function hashv_32(key)
	return hash_32(cast(uint32_ptr_t, key)[0])
end

local function hashv_48(key)
	local hi = cast(uint32_ptr_t, key)[0]
	local lo = cast(uint16_ptr_t, key)[2]
	-- Extend lo to the upper half too so that the hash function isn't
	-- spreading around needless zeroes.
	lo = bor(lo, lshift(lo, 16))
	return hash_32(bxor(hi, hash_32(lo)))
end

local function hashv_64(key)
	local hi = cast(uint32_ptr_t, key)[0]
	local lo = cast(uint32_ptr_t, key)[1]
	return hash_32(bxor(hi, hash_32(lo)))
end

if not ... then
	print(hash_32(4131))
	local s = 'abcdefgh'
	local k = ffi.new('const char*', s)
	print(hashv_48(k))
	print(hashv_64(k))
end

return {
	hash32 = hash_32,
	hashv32 = hashv_32,
	hashv64 = hashv_64,
}
