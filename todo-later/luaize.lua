
--luaization utilities
--Written by Cosmin Apreutesei. Public Domain.

local ffi = require'ffi'

--assert() with string formatting.
local function assert(v, err, ...)
	if v then return v end
	err = err or 'assertion failed!'
	if select('#',...) > 0 then
		err = string.format(err,...)
	end
	error(err, 2)
end

--turn a table of boolean options into a bit mask.
local function table_flags(t, masks, strict)
	local bits = 0
	local mask = 0
	for k,v in pairs(t) do
		local flag
		if type(k) == 'string' and v then --flags as table keys: {flag->true}
			flag = k
		elseif type(k) == 'number'
			and math.floor(k) == k
			and type(v) == 'string'
		then --flags as array: {flag1,...}
			flag = v
		end
		local bitmask = masks[flag]
		if strict then
			assert(bitmask, 'invalid flag %s', tostring(flag))
		elseif bitmask then
			mask = bit.bor(mask, bitmask)
			if flag then
				bits = bit.bor(bits, bitmask)
			end
		end
	end
	return bits, mask
end

--turn 'opt1 +opt2 -opt3' -> {opt1=true, opt2=true, opt3=false}
local function string_flags(s, masks, strict)
	local t = {}
	for s in s:gmatch'[^ ,]+' do
		local m,s = s:match'^([%+%-]?)(.*)$'
		t[s] = m ~= '-'
	end
	return table_flags(t, masks, strict)
end

--set one or more bits of a value without affecting other bits.
local function setbits(bits, mask, over)
	return over and bit.bor(bits, bit.band(over, bit.bnot(mask))) or bits
end

--cache tuple(options_string, masks_table) -> bits, mask
local cache = {}
local function getcache(s, masks)
	cache[masks] = cache[masks] or {}
	local t = cache[masks][s]
	if not t then return end
	return t[1], t[2]
end
local function setcache(s, masks, bits, mask)
	cache[masks][s] = {bits, mask}
end

local function prefix_masks(prefix, namespace)
	namespace = namespace or ffi.C
	local function get_bits(t, k)
		local v = namespace[prefix .. k:upper()]
		assert(v ~= nil, 'invalid flag %s', k)
		rawset(t, k, v)
		return v
	end
	return setmetatable({}, {__index = get_bits})
end

local function multiple_masks(mask_tables)
	local function get_bits(t, k)
		for i,masks in ipairs(mask_tables) do
			local ok, v = pcall(getk, masks, k)
			if ok then
				assert(v ~= nil, 'invalid flag %s', k)
				rawset(t, k, v)
				return v
			end
		end
		assert(false, 'invalid flag %s', k)
	end
	return setmetatable({}, {__index = get_bits})
end

local function flags(arg, masks, cur_bits, strict)
	if type(masks) == 'string' then
		if masks:find'[ \t]' then
			local t = {}
			for prefix in masks:gmatch'[^ \t]+' do
				table.insert(t, prefix_masks(prefix))
			end
			masks = multiple_masks(t)
		end
		masks = prefix_masks(masks)
	end
	if type(arg) == 'string' then
		local bits, mask = getcache(arg, masks)
		if not bits then
			bits, mask = string_flags(arg, masks, strict)
			setcache(arg, masks, bits, mask)
		end
		return setbits(bits, mask, cur_bits)
	elseif type(arg) == 'table' then
		local bits, mask = table_flags(arg, masks, strict)
		return setbits(bits, mask, cur_bits)
	elseif type(arg) == 'number' then
		return arg
	elseif arg == nil then
		return 0
	else
		assert(false, 'flags expected but %s given', type(arg))
	end
end

------------------------------------------------------------------------------

local function same_char_at(t, i)
	if #t[1] < i then return false end
	local b = t[1]:byte(i)
	for j=2,#t do
		if #t[j] < i or b ~= t[j]:byte(i) then
			return false
		end
	end
	return true
end
local function find_prefix(t)
	assert(#t > 0)
	local i = 1
	while same_char_at(t, i) do
		i = i + 1
	end
	return s:sub(1, i-1)
end

--bidirectional mapper for enum values to names
local enums = {} --{prefix -> {enumval -> name; name -> enumval}}
local function enums(t)
	local prefix = find_prefix(t)
	local dt = {}
	for i,v in ipairs(t) do
		local k = ffi.C[prefix..v:upper()]
		local v = v:lower()
		dt[k] = v
		dt[v] = k
	end
	enums[prefix] = dt
end

--'foo' -> C.<PREFIX>_FOO and C.<PREFIX>_FOO -> 'foo' conversion
local function enum(prefix, val)
	local val = enums[prefix][val]
	if val == nil then
		error('invalid enum value for '..prefix, 2)
	end
	return val
end

------------------------------------------------------------------------------

local bitmask_class = {}
local bitmask_meta = {__index = bitmask_class}

function bitmask(fields)
	return setmetatable({fields = fields}, bitmask_meta)
end

function negate(mask)
	return {[true] = 0, [false] = mask}
end

function bitmask_class:compute_mask(t) --compute total mask for use with setbits()
	t = t or self.fields
	local v = 0
	for _, mask in pairs(t) do
		if type(mask) == 'table' then --choice mask
			v = bit.bor(v, self:compute_mask(mask))
		else
			v = bit.bor(v, mask)
		end
	end
	return v
end

local setbit, setbits = setbit, setbits

function bitmask_class:setbit(over, k, v)
	local mask = self.fields[k] --def: {name = mask | choicemask}; choicemask: {name = mask}
	assert(mask, 'unknown bitmask field "%s"', k)
	if type(mask) == 'table' then --choicemask
		over = setbits(over, self:compute_mask(mask), mask[v] or 0)
	else
		over = setbit(over, mask, v)
	end
	return over
end

function bitmask_class:set(over, t)
	if not t then return over end --no table is an empty table
	for k in pairs(self.fields) do
		if t[k] ~= nil then
			over = self:setbit(over, k, t[k])
		end
	end
	return over
end

function bitmask_class:getbit(from, k)
	local mask = self.fields[k]
	assert(mask, 'unknown bitmask field "%s"', k)
	if type(mask) == 'table' then --choicemask
		local default_choice
		for choice, choicemask in pairs(mask) do
			if choicemask == 0 then default_choice = choice end
			if bit.band(from, choicemask) ~= 0 then --return the first found choice
				return choice
			end
		end
		return default_choice
	end
	return bit.band(from, mask) == mask
end

function bitmask_class:get(from, into)
	local t = into or {}
	for k in pairs(self.fields) do
		t[k] = self:getbit(from, k)
	end
	return t
end







return {
	prefix_masks = prefix_masks,
	multiple_masks = multiple_masks,
	flags = flags,
	enums = enums,
	enum = enum,
}

