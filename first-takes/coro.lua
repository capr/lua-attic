
--symmetric coroutine implementation from
--    http://www.inf.puc-rio.br/~roberto/docs/corosblp.pdf
--
-- changes from the paper:
--   * coro.transfer() can send and return multiple values.
--   * threads created with coro.create() finish into the creator thread
--   not in main thread, unless otherwise specified.
--   * added coro.wrap() similar to coroutine.wrap().
--   * added coro.yield(), coro.resume() and coro.wrap() which can replace
-- standard coroutines

--if not ... then require'coro_test'; return end

local coroutine = coroutine

local coro = {}
local current

function coro.create(f, return_thread)
	return_thread = return_thread or current
	local co = coroutine.create(function(...)
		return return_thread, f(...)
	end)
	return function(...)
		return coroutine.resume(co, ...)
	end
end

local function go(caller, ok, thread, ...)
	if not ok then

		print(thread)
	end
	local caller = current
	current = thread
	if not thread then
		return ...
	end
	return go(caller, thread(...)) --tail call
end

function coro.transfer(thread, ...)
	if current then
		return coroutine.yield(thread, ...)
	end
	return go(true, thread, ...)
end

function coro.running()
	return current
end

local caller

local function pass(old_caller, ...)
	caller = old_caller
	return ...
end
function coro.resume(thread, ...)
	local old_caller = caller
	caller = current
	return pass(old_caller, coro.transfer(thread, ...))
end

function coro.yield(...)
	return coro.transfer(caller, ...)
end

function coro.wrap(f)
	local thread = coro.create(f)
	return function(...)
		return coro.resume(thread, ...)
	end
end

function coro.install()
	_G.coroutine = coro
	return coroutine
end


if not ... then


coro.install()
local coroutine = coro

local v = 0
local function nextval()
	v = v + 1
	return v
end

local scheduler = coroutine.create(function(thread)
	while true do
		thread = coroutine.transfer(thread, nextval())
	end
end)

local function read()
	return coroutine.transfer(scheduler, coroutine.running())
end

local iter = coroutine.wrap(function()
	for i = 1, 4 do
		local v1 = read()
		local v2 = read()
		coroutine.yield('step'..i, v1, v2)
		if i % 2 == 0 then
			coroutine.yield()
		end
	end
end)

local outer = coroutine.wrap(function()
	for i=1,2 do
		coroutine.yield('outer_a', read())
		for step, v1, v2 in iter do
			print(step, v1, v2)
		end
		coroutine.yield('outer_b', read())
	end
end)

for k,v in outer do
	print(k, v)
end
print(outer('heeeeei'))

--outer -> iter -> read -> yield[T] -> scheduler ->


end


return coro

