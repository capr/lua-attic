
local coroutine = coroutine

local coro = {}
local T = {} --internal identity to signal transfer

local function p(...)
	local thread = coroutine.running()
	if not thread then thread = 'thread: <main>    ' end
	print(thread, ...)
	return ...
end

local function ps(n, ...)
	p(...)
	return select(n, ...)
end

--inherit all coroutine methods before overriding some of them.
for k,v in pairs(coroutine) do
	coro[k] = v
end

local function pass(thread, ok, ...)
	print('transferred from ', thread, ...)
	return ...
end
function coro.transfer(thread, ...)
	p('transf', thread, ...)
	if not coroutine.running() then
		--we're in the main thread, resume the thread normally
		return pass(thread, coro.resume(thread, ...))
	end
	--we're inside a thread, yield the need for a transfer
	return coro.yield(T, thread, ...)
end

local function pass3(ok, ...)
	return ...
end
local function passback(thread, ...)
	print('transferring back to ', thread, ...)
	return pass3(coroutine.resume(thread, ...))
end
local function pass(thread, ok, ...)
	if (...) == T then --the coroutine needs a transfer
		p('need transfer', select(2, ...))
		return passback(thread, coro.transfer(select(2, ...)))
	end
	return ok, ...
end
function coro.resume(thread, ...)
	p('resume', thread, ...)
	return pass(thread, coroutine.resume(thread, ...))
end

--reimplement coroutine.wrap() with the same semantics except based on
--the overriden version of coroutine.resume().
local function pass(ok, ...)
	if not ok then
		error((...), 2)
	end
	return ...
end
function coro.wrap(f)
	p('wrap', '', '', '', f)
	local thread = coro.create(f)
	return function(...)
		return pass(coro.resume(thread, ...))
	end
end

function coro.create(...)
	local thread = coroutine.create(...)
	p('create', thread, ...)
	return thread
end

function coro.yield(...)
	p('yield', ...)
	return coroutine.yield(...)
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
	p('read-transfer', coroutine.running(), '->', scheduler)
	return ps(2, 'read-back', coroutine.transfer(scheduler, coroutine.running()))
end

local iter = coroutine.wrap(function()
	local v1 = read()
	local v2 = read()
	coroutine.yield('step1', v1, v2)
	local v1 = read()
	local v2 = read()
	coroutine.yield('step2', v1, v2)
end)

local outer = coroutine.wrap(function()
	for step, v1, v2 in iter do
		print(step, v1, v2)
	end
end)

outer()

--outer -> iter -> read -> yield[T] -> scheduler ->


end

return coro
