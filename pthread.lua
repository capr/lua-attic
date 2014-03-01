require'pthread_h'
local ffi = require'ffi'
local C = ffi.load'pthread'

if not ... then

local pthread = C
local lualib = require'lua'

local queue = {}

local function push(chan, msg)
	queue[chan] = queue[chan] or {}
	table.insert(queue[chan], msg)
end

local function pop(chan)
	queue[chan] = queue[chan] or {}
	return table.remove(queue[chan])
end

local lua = lualib.open()
lua:openlibs()
lua:push(function()
	local ffi = require'ffi'
	local function send(msg)
		--
	end
	local function hello()
		print'Hello from another Lua state!'
		send('hello')
		print(receive())
	end
	return tonumber(ffi.cast('intptr_t', ffi.cast('void *(*)(void *)', hello)))
end)
local ptr = lua:call()

local thread = ffi.new'pthread_t[1]'
local res = pthread.pthread_create(thread, nil, ffi.cast('void *(*)(void *)', ptr), nil)
assert(res == 0)

local res = pthread.pthread_join(thread[0], nil)
assert(res == 0)

lua:close()

end
