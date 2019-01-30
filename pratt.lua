--https://dev.to/jrop/pratt-parsing

local s = '1 + 2 + 3'

local t = {}
for s in s:gmatch'[^%s]+' do
	t[#t+1] = s
end

local i = 0
local function next()
	i = i + 1
	return t[i]
end
local function peek()
	return t[i+1]
end

local expr

local op = {['+'] = 10, ['*'] = 20, ['^'] = 30}
local ra = {['^'] = 1}
local function bp(s)
	return s and op[s] or -1
end

local function prefix(s)
	return s == '-' and {s, expr()} or s
end

local function infix(lhs, op)
	return {op, lhs, expr(bp(op) - (ra[op] or 0))}
end

function expr(rbp)
	local lhs = prefix(next())
	while bp(peek()) > (rbp or 0) do
		lhs = infix(lhs, next())
	end
	return lhs
end

require'pp'(expr())
