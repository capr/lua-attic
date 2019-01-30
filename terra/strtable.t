
setfenv(1, require'low'.C)
local ffi = require'ffi'
local phf = require'phf'

local strs = {}
local str_indices = {}
local str_count = 0
local str_len = 0
local max_len = 0

function S(s)
	local i = strs[s]
	if not i then
		i = str_count
		strs[s] = i
		str_indices[i] = s
		str_count = str_count + 1
		str_len = str_len + #s
		max_len = math.max(max_len, str_len)
	end
	return i
end

local function num_type(n)
	return ffi.typeof(n >= 2^16 and 'uint32_t' or n >= 2^8 and 'uint16_t' or 'uint8_t')
end
num_type = terralib.memoize(num_type)

ffi.cdef'void *memcpy(void *str1, const void *str2, size_t n)'

local function const_string_array()
	local num_t = num_type(str_count)
	local len_t = num_type(max_len)
	local len_pt = ffi.typeof('$*', len_t)
	local offsets = ffi.new(ffi.typeof('$[?]', num_t), str_count)
	local buf_size = str_len + str_count * (ffi.sizeof(len_t) + 1)
	local buf = ffi.new('uint8_t[?]', buf_size)
	local offset = 0
	for i = 0, #str_indices do
		local s = str_indices[i]
		ffi.cast(len_pt, buf + offset)[0] = #s
		offset = offset + ffi.sizeof(len_t)
		offsets[i] = offset
		ffi.C.memcpy(buf + offset, s, #s + 1)
		offset = offset + #s + 1
	end
end

string -> hash -> string_index


function gen_strings()
	local lookup = phf(strings, int16, vtype, invalid_value, complete_set, thash)

end

S'Hello'
S'World!'
S'Hello'
const_string_array()
