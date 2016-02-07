
--cdata-based hash maps.
--Written by Andy Wingo. MIT Licensed.

local ffi = require'ffi'
local bit = require'bit'
local C = ffi.C
local bxor, bnot = bit.bxor, bit.bnot
local tobit, lshift, rshift = bit.tobit, bit.lshift, bit.rshift
local max, floor, ceil = math.max, math.floor, math.ceil

ffi.cdef'int memcmp(const void*, const void*, size_t);'

local ctable = {}

local HASH_MAX = 0xFFFFFFFF
local uint16_ptr_t = ffi.typeof'uint16_t*'
local uint32_ptr_t = ffi.typeof'uint32_t*'
local uint64_ptr_t = ffi.typeof'uint64_t*'

local function make_entry_type(key_type, value_type)
	return ffi.typeof([[struct {
			uint32_t hash;
			$ key;
			$ value;
		} __attribute__((packed))]],
		key_type,
		value_type)
end

local function make_entries_type(entry_type)
	return ffi.typeof('$[?]', entry_type)
end

-- hash := [0,HASH_MAX); scale := size/HASH_MAX
local function hash_to_index(hash, scale)
	return floor(hash*scale + 0.5)
end

local function make_equal_fn(key_type)
	local size = ffi.sizeof(key_type)
	local cast = ffi.cast
	if tonumber(ffi.new(key_type)) then
		return function (a, b)
			return a == b
		end
	elseif size == 2 then
		return function (a, b)
			return cast(uint16_ptr_t, a)[0] == cast(uint16_ptr_t, b)[0]
		end
	elseif size == 4 then
		return function (a, b)
			return cast(uint32_ptr_t, a)[0] == cast(uint32_ptr_t, b)[0]
		end
	elseif size == 6 then
		return function (a, b)
			return (cast(uint32_ptr_t, a)[0] == cast(uint32_ptr_t, b)[0] and
					  cast(uint16_ptr_t, a)[2] == cast(uint16_ptr_t, b)[2])
		end
	elseif size == 8 then
		return function (a, b)
			return cast(uint64_ptr_t, a)[0] == cast(uint64_ptr_t, b)[0]
		end
	else
		return function (a, b)
			return C.memcmp(a, b, size) == 0
		end
	end
end

-- FIXME: For now the value_type option is required, but in the future
-- we should allow for a nil value type to create a set instead of a
-- map.

function ctable.alloc(t, count)
	return ffi.new(make_entries_type(t), count)
end

local function new(user_params)
	local ctab = {}
	local params = {
		initial_size = 8,
		max_occupancy_rate = 0.9,
		min_occupancy_rate = 0.0,
	}
	for k,v in pairs(user_params) do
		params[k] = v
	end
	ctab.entry_type = make_entry_type(params.key_type, params.value_type)
	ctab.type = make_entries_type(ctab.entry_type)
	ctab.hash_fn = params.hash_fn
	ctab.equal_fn = make_equal_fn(params.key_type)
	ctab.size = 0
	ctab.occupancy = 0
	ctab.max_occupancy_rate = params.max_occupancy_rate
	ctab.min_occupancy_rate = params.min_occupancy_rate
	ctab = setmetatable(ctab, { __index = ctable })
	ctab:resize(params.initial_size)
	return ctab
end

function ctable:resize(size)
	assert(size >= (self.occupancy / self.max_occupancy_rate))
	local old_entries = self.entries
	local old_size = self.size

	-- Allocate double the requested number of entries to make sure there
	-- is sufficient displacement if all hashes map to the last bucket.
	self.entries = self.alloc(self.entry_type, size * 2)
	self.size = size
	self.scale = self.size / HASH_MAX
	self.occupancy = 0
	self.max_displacement = 0
	self.occupancy_hi = ceil(self.size * self.max_occupancy_rate)
	self.occupancy_lo = floor(self.size * self.min_occupancy_rate)
	for i=0,self.size*2-1 do self.entries[i].hash = HASH_MAX end

	for i=0,old_size*2-1 do
		if old_entries[i].hash ~= HASH_MAX then
			self:insert(old_entries[i].hash, old_entries[i].key, old_entries[i].value)
		end
	end
end

function ctable:insert(hash, key, value, updates_allowed)
	if self.occupancy + 1 > self.occupancy_hi then
		self:resize(self.size * 2)
	end

	local entries = self.entries
	local scale = self.scale
	local start_index = hash_to_index(hash, self.scale)
	local index = start_index

	while entries[index].hash < hash do
		index = index + 1
	end

	while entries[index].hash == hash do
		if self.equal_fn(key, entries[index].key) then
			assert(updates_allowed, 'key is already present in ctable')
			entries[index].key = key
			entries[index].value = value
			return index
		end
		index = index + 1
	end

	assert(updates_allowed ~= 'required', 'key not found in ctable')

	self.max_displacement = max(self.max_displacement, index - start_index)

	if entries[index].hash ~= HASH_MAX then
		-- In a robin hood hash, we seek to spread the wealth around among
		-- the members of the table.  An entry that can be stored exactly
		-- where hash_to_index() maps it is a most wealthy entry.  The
		-- farther from that initial position, the less wealthy.  Here we
		-- have found an entry whose hash is greater than our hash,
		-- meaning it has travelled less far, so we steal its position,
		-- displacing it by one.  We might have to displace other entries
		-- as well.
		local empty = index;
		while entries[empty].hash ~= HASH_MAX do empty = empty + 1 end
		while empty > index do
			entries[empty] = entries[empty - 1]
			local displacement = empty - hash_to_index(entries[empty].hash, scale)
			self.max_displacement = max(self.max_displacement, displacement)
			empty = empty - 1;
		end
	end

	self.occupancy = self.occupancy + 1
	entries[index].hash = hash
	entries[index].key = key
	entries[index].value = value
	return index
end

function ctable:add(key, value, updates_allowed)
	local hash = self.hash_fn(key)
	assert(hash >= 0)
	assert(hash < HASH_MAX)
	return self:insert(hash, key, value, updates_allowed)
end

function ctable:update(key, value)
	return self:add(key, value, 'required')
end

function ctable:lookup_ptr(key)
	local hash = self.hash_fn(key)
	local entry = self.entries + hash_to_index(hash, self.scale)

	-- Fast path in case we find it directly.
	if hash == entry.hash and self.equal_fn(key, entry.key) then
		return entry
	end

	while entry.hash < hash do entry = entry + 1 end

	while entry.hash == hash do
		if self.equal_fn(key, entry.key) then return entry end
		-- Otherwise possibly a collision.
		entry = entry + 1
	end

	-- Not found.
	return nil
end

function ctable:lookup_and_copy(key, entry)
	local entry_ptr = self:lookup_ptr(key)
	if not ptr then return false end
	entry = entry_ptr
	return true
end

function ctable:remove_ptr(entry)
	local scale = self.scale
	local index = entry - self.entries
	assert(index >= 0)
	assert(index <= self.size + self.max_displacement)
	assert(entry.hash ~= HASH_MAX)

	self.occupancy = self.occupancy - 1
	entry.hash = HASH_MAX

	while true do
		entry = entry + 1
		index = index + 1
		if entry.hash == HASH_MAX then break end
		if hash_to_index(entry.hash, scale) == index then break end
		-- Give to the poor.
		entry[-1] = entry[0]
		entry.hash = HASH_MAX
	end

	if self.occupancy < self.occupancy_lo then
		self:resize(self.size / 2)
	end
end

-- FIXME: Does NOT shrink max_displacement
function ctable:remove(key, missing_allowed)
	local ptr = self:lookup_ptr(key)
	if not ptr then
		assert(missing_allowed, 'key not found in ctable')
		return false
	end
	self:remove_ptr(ptr)
	return true
end

function ctable:selfcheck()
	local occupancy = 0
	local max_displacement = 0

	local function fail(expected, op, found, what, where)
		if where then where = 'at '..where..': ' else where = '' end
		error(where..what..' check: expected '..expected..op..'found '..found)
	end
	local function expect_eq(expected, found, what, where)
		if expected ~= found then fail(expected, '==', found, what, where) end
	end
	local function expect_le(expected, found, what, where)
		if expected > found then fail(expected, '<=', found, what, where) end
	end

	local prev = 0
	for i = 0,self.size*2-1 do
		local entry = self.entries[i]
		local hash = entry.hash
		if hash ~= 0xffffffff then
			expect_eq(self.hash_fn(entry.key), hash, 'hash', i)
			local index = hash_to_index(hash, self.scale)
			if prev == 0xffffffff then
				expect_eq(index, i, 'undisplaced index', i)
			else
				expect_le(prev, hash, 'displaced hash', i)
			end
			occupancy = occupancy + 1
			max_displacement = max(max_displacement, i - index)
		end
		prev = hash
	end

	expect_eq(occupancy, self.occupancy, 'occupancy')
	-- Compare using <= because remove_at doesn't update max_displacement.
	expect_le(max_displacement, self.max_displacement, 'max_displacement')
end

function ctable:dump()
	local function dump_one(index)
		io.write(index..':')
		local entry = self.entries[index]
		if (entry.hash == HASH_MAX) then
			io.write'\n'
		else
			local distance = index - hash_to_index(entry.hash, self.scale)
			io.write(' hash: '..entry.hash..' (distance: '..distance..')\n')
			io.write('    key: '..tostring(entry.key)..'\n')
			io.write('  value: '..tostring(entry.value)..'\n')
		end
	end
	for index=0,self.size-1 do dump_one(index) end
	for index=self.size,self.size*2-1 do
		if self.entries[index].hash == HASH_MAX then break end
		dump_one(index)
	end
end

function ctable:iterate()
	local max_entry = self.entries + self.size + self.max_displacement
	local function next_entry(max_entry, entry)
		while entry <= max_entry do
			entry = entry + 1
			if entry.hash ~= HASH_MAX then return entry end
		end
	end
	return next_entry, max_entry, self.entries - 1
end

if not ... then
	print'selftest: ctable'
	local hash32 = require'burtlehash'.hash32

	-- 32-byte entries
	local occupancy = 2e6
	local params = {
		key_type = ffi.typeof'uint32_t',
		value_type = ffi.typeof'int32_t[6]',
		hash_fn = hash32,
		max_occupancy_rate = 0.4,
		initial_size = ceil(occupancy / 0.4)
	}
	local ctab = new(params)
	ctab:resize(occupancy / 0.4 + 1)

	-- Fill with i -> { bnot(i), ... }.
	local v = ffi.new'int32_t[6]';
	for i = 1,occupancy do
		for j=0,5 do v[j] = bnot(i) end
		ctab:add(i, v)
	end

	-- In this case we know max_displacement is 8.  Assert here so that
	-- we can detect any future deviation or regression.
	assert(ctab.max_displacement == 8)

	ctab:selfcheck()

	for i = 1, occupancy do
		local value = ctab:lookup_ptr(i).value[0]
		assert(value == bnot(i))
	end
	ctab:selfcheck()

	local iterated = 0
	for entry in ctab:iterate() do iterated = iterated + 1 end
	assert(iterated == occupancy)

	-- OK, all looking good with our ctab.

	-- A check that our equality functions work as intended.
	local numbers_equal = make_equal_fn(ffi.typeof'int')
	assert(numbers_equal(1,1))
	assert(not numbers_equal(1,2))

	local function check_bytes_equal(type, a, b)
		local equal_fn = make_equal_fn(type)
		assert(equal_fn(ffi.new(type, a), ffi.new(type, a)))
		assert(not equal_fn(ffi.new(type, a), ffi.new(type, b)))
	end
	check_bytes_equal(ffi.typeof'uint16_t[1]', {1}, {2})         -- 2 byte
	check_bytes_equal(ffi.typeof'uint32_t[1]', {1}, {2})         -- 4 byte
	check_bytes_equal(ffi.typeof'uint16_t[3]', {1,1,1}, {1,1,2}) -- 6 byte
	check_bytes_equal(ffi.typeof'uint32_t[2]', {1,1}, {1,2})     -- 8 byte
	check_bytes_equal(ffi.typeof'uint32_t[3]', {1,1,1}, {1,1,2}) -- 12 byte

	print'selftest: ok'
end

return ctable
