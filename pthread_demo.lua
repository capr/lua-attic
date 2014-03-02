local pthread = require'pthread'
local lua = require'lua'
local ffi = require'ffi'

local queue = {}

local function push(chan, msg)
	queue[chan] = queue[chan] or {}
	table.insert(queue[chan], msg)
end

local function pop(chan)
	queue[chan] = queue[chan] or {}
	return table.remove(queue[chan])
end

local state = lua.open()
state:openlibs()
state:push(function()
	local ffi = require'ffi'
	local pthread = require'pthread'
	local function send(msg)
		--
	end
	local function receive()
		return 'received'
	end
	local hello_cb
	local function hello()
		print'Hello from another Lua state!'

		local m = pthread.mutex.new()
		m:lock()
		assert(m:trylock() == false)
		m:unlock()
		m:free()

		local c = pthread.cond.new()
		c:free()

		send('hello')
		print(receive())
		local thread = pthread.self()
		assert(thread == thread)
		hello_cb:free()
		pthread.exit(ffi.cast('void*', 1234))
	end
	hello_cb = ffi.cast('void *(*)(void *)', hello)
	return tonumber(ffi.cast('intptr_t', hello_cb))
end)
local func_ptr = ffi.cast('void*', state:call())

local thread = pthread.new(func_ptr)
print(tonumber(ffi.cast('intptr_t', thread:join())))

state:close()

