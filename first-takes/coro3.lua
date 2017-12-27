
--symmetric coroutine implementation from
--    http://www.inf.puc-rio.br/~roberto/docs/corosblp.pdf
--
-- changes from the paper:
--   * can yield multiple values.
--   * threads created with coro.create() finish into the creator thread
--   not in main thread, unless otherwise specified.
--   * added coro.wrap() similar to coroutine.wrap().

local coroutine = coroutine

local coro = {}
local current

local function finish(thread, ...)
	assert(thread.caller, 'coroutine ended without transferring control')
	return thread.caller, ...
end
function coro.create(f)
	local thread = {}
	thread.co = coroutine.create(function(...)
		return finish(thread, f(...))
	end)
	return thread
end

local function go(thread, ...)
	--[[
	if goerror then
		return go(false, caller, false, caller.caller, ...)
	end
	if not ok then
		--if the thread was resumed with coro.resume(), pass back the error
		if caller and caller.caller then
			return go(false, caller, false, caller.caller, ...)
		end
		--errors from coro.transfer() are raised in the main thread
		error(thread, 2)
	end
	]]
	current = thread
	if not thread then
		--transferring to main thread: stop the scheduler
		return true, ...
	end
	return go(thread, coroutine.resume(thread.co, ...)) --tail call
end

local function pass(...)
	print('', ...)
	return ...
end
local function transfer(thread, ...)
	print('transfer',
		(current and current.name or 'main')..'->'..
		(thread and thread.name or 'main'), ...)
	if current then
		return pass(coroutine.yield(thread, ...)) --yield to scheduler
	end
	return pass(go(thread, ...) --start scheduler
end

local function pass(ok, ...)
	if not ok then
		error(..., 2)
	end
	return ...
end
function coro.transfer(thread, ...)
	return pass(transfer(thread, ...))
end

local function nilcaller(thread, ...)
	thread.caller = nil
	return ...
end
function coro.resume(thread, ...)
	thread.caller = current or false
	return nilcaller(thread, transfer(thread, ...))
end

function coro.yield(...)
	assert(current, 'yield from the main thread')
	assert(current.caller ~= nil, 'yield from a non-resumed thread')
	return coro.transfer(current.caller, ...)
end

function coro.wrap(f, name)
	local thread = coro.create(f)
	thread.name = name
	return function(...)
		thread.caller = current
		return nilcaller(thread, coro.transfer(thread, ...))
	end
end

function coro.running()
	return current
end

function coro.status(thread)
	return coroutine.status(thread.co)
end

function coro.install()
	_G.coroutine = coro
	return coroutine
end


if not ... then

local coroutine = coro

local i = 0
local function nextval()
	if i == 10 then
		return
	end
	i = i + 1
	return i
end

local scheduler = coroutine.create(function(thread)
	while true do
		thread = coroutine.transfer(thread, nextval())
	end
end)
scheduler.name = 'scheduler'

local function read()
	return coroutine.transfer(scheduler, coroutine.running())
end

local thread = coroutine.wrap(function()

	local iter = coroutine.wrap(function()
		while true do
			local v1 = read()
			local v2 = read()
			coroutine.yield(v1, v2)
			if v2 == 10 then break end
			if not v1 or not v2 then break end
		end
	end, 'iter')

	for v1,v2 in iter do
		print(v1, v2)
	end
	coroutine.yield'done'

end, 'thread')

print(thread())


end


return coro

