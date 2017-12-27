local coro = require'coro'

local t = {}
coro.transfer(coro.create(function()
	local parent = coro.running()
	local thread = coro.create(function()
		table.insert(t, 'sub')
	end)
	coro.transfer(thread)
	table.insert(t, 'back')
end))
assert(not coro.running())
assert(#t == 2)
assert(t[1] == 'sub')
assert(t[2] == 'back')

local t = {}
coro.transfer(coro.create(function()
	local parent = coro.running()
	local thread = coro.wrap(function()
		for i=1,10 do
			coro.transfer(parent, i * i)
		end
	end)
	for s in thread do
		table.insert(t, s)
	end
end))
assert(not coro.running())
assert(#t == 10)
for i=1,10 do assert(t[i] == i * i) end

--asymmetric coroutine API

coro.install()

--print(pcall(coroutine.yield))

local c = coroutine.create(function()
	coroutine.yield('a', 'b', 'c')
	coroutine.yield('d', '.')
	return 3, 5, 7, 9
end)

print(coroutine.resume(c))
print(coroutine.resume(c))
print(coroutine.resume(c))
print(coroutine.resume(c))

local c1 = coroutine.create(function()
	print'inside c1'
	local c2 = coroutine.create(function()
		for i=1,10 do
			coroutine.yield('c2', i)
		end
		return 'c2', 'end'
	end)
	while true do
		local ok, v1, v2 = coroutine.resume(c2)
		if not ok or not v1 then break end
		print(ok, v1, v2)
	end
	print'back to c1'
end)

print(coroutine.resume(c1))

print'--end--'
