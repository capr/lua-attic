local ffi = require'ffi'
local pthread = require'pthread'
local lua = require'lua'
local glue = require'glue'

----------------------------------------------------

local shared
local mutex

local function init(shared_, mutex_)
	shared = shared_ or lua.open():openlibs()
	mutex = mutex_ or pthread.mutex.new()
end

local function pass(ok, ...)
	mutex:unlock()
	if not ok then error(...) end
	return ...
end
local function forwarder(k)
	return function(...)
		mutex:lock()
		mutex:getglobal(k)
		pass(shared:pcall(...))
	end
end

shared:push(function()

	local ffi = require'ffi'
	local pthread = require'pthread'
	local lua = require'lua'
	local glue = require'glue'

	--create a new Lua state and a new thread, and run a worker function in that state and thread.
	local function create_thread(worker, args)
		local state = lua.open()
		state:openlibs()
		state:push(function(worker, args)
			local ffi = require'ffi'
			local function wrapper()
				worker(args)
			end
			local wrapper_cb = ffi.cast('void *(*)(void *)', wrapper)
			return tonumber(ffi.cast('intptr_t', wrapper_cb))
		end)
		local wrapper_cb_ptr = ffi.cast('void *', state:call(worker, args))
		local thread = pthread.new(wrapper_cb_ptr)
		local function join()
			thread:join()
			state:close()
		end
		return join
	end

	local function addr(cdata)
		return tonumber(ffi.cast('intptr_t', ffi.cast('void*', cdata)))
	end


	local queue = {}

	function newproc()

	end

	function createworker()
		local join = create_thread(function()
			--
		end, {shared_ptr = shared_ptr, mutex_ptr = mutex_ptr})
		table.insert(threads, join)
	end

	function destroyworker()
		if #threads == 0 then return end
		local join = table.remove(threads)
		join()
	end

	function send(chan, ...)

	end

	function receive(chan, async)

	end

	function newchannel(chan)

	end

	function delchannel(chan)

	end

end)
shared:call()

local luaproc = setmetatable({}, {__index = function(t, k)
	luaproc[k] = forwarder(k)
	return luaproc[k]
end})

function luaproc.exit()
	pthread.exit() --join all
end


if not ... then


end

return luaproc
