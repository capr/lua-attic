local esc = {
	['0']  = char(0),
	['b']  = '\b',
	['n']  = '\n',
	['r']  = '\r',
	['t']  = '\t',
	['Z']  = char(26),
	['\\'] = '\\',
}

local ops = index{
	'*', ';', ',',
	'&', '>', '>>', '>=', '<', '<>', '!=', '<<', '<=', '<=>', '%', '*', '+',
	'-','->', '->>', '/', ':=', '=', '^', '&&', '(', ')', '!', '||', '|', '~',
	'?', '??',
}

	--tokenizing --------------------------------------------------------------

	pp.ansi_quotes = false --true: treat double-quoted strings as identifiers.

	local function tokens(s)
		local i = 1
		local yield = coroutine.yield
		::again::
		local i1, c, j = s:match('^%s*()(.)()', i)
		if not c then --eof
			return
		end
		if i1 >= i then
			yield('space', i, i1)
			i = i1
			if i1 == #s then --eof
				return
			end
		end
		if c == '-' then
			local j = s:match('^%-%s+.-\r?\n?()', j) -- `-- ...` comment
			if j then
				yield('comment', i, j)
				i = j
				goto again
			end
		end
		if c == '#' then
			local j = s:match('^.-\r?\n?()', j) -- `# ...` comment
			if j then
				yield('comment', i, j)
				i = j
				goto again
			end
		end
		if c == '/' then
			local j = s:match('^%*.-%*/()', j) -- `/* ... */` comment
			yield('comment', i, j)
			i = j
			goto again
		end
		if c == '\'' or c == '"' or c == '`' then --string or backtick ident
			local patt = '()(['..c..'\\])()(.)'
			while true do
				local i1, c, j1, c2 = s:match(patt, j)
				if not c then
					yield('error', i, i, 'unfinished string')
					return
				end
				j = j1
				if c == '\\' then -- backslash escape
					if c2 == '' then
						yield('error', i1+1, i1+1, 'unfinished backslash escape')
						return
					end
					j = j+1
				elseif c2 == c then -- `foo''s bar` or `foo""s bar` quote-quote
					j = j + 1
				else --end of string
					break
				end
			end
			local token = (c == '`' or (c == '"' and pp.ansi_quotes))
				and 'ident' or 'string'
			yield(token, i, j)
			i = j
			goto again
		end
		local j = s:match('^0x[0-9a-fA-F]+()', i) --hex literal
		if j then
			yield('number', i, j)
			i = j
			goto again
		end
		local j = s:match('^0b[01]+()', i) --binary literal
		if j then
			yield('number', i, j)
			i = j
			goto again
		end
		local j = s:match('^[%-%+]?%d*%.?%d*[eE]?[%-%+]?%d*()', i) --number
		if j and j > i and s:find'%d' then
			yield('number', i, j)
			i = j
			goto again
		end
		local j = s:match('^[%a_$][%w_$]*()', i) --keyword or identifier
		if j then
			yield('ident', i, j)
			i = j
			goto again
		end
		local param, dbl, j = s:match('^:(:?)([%a_][%w_]*)()', i) --named parameter
		if j then
			yield(dbl == ':' and 'nparam' or 'vparam', i, j, param)
			i = j
			goto again
		end
		for n = 3, 1, -1 do --operator
			local op, j = s:match('^('..('[^%s]'):rep(n)..')()', i)
			if j and ops[op] then
				yield('op', i, j, op)
				i = j
				goto again
			end
		end
		yield('error', i, i+1, 'invalid char "'..s:sub(i, i+1)..'"')
	end

	function pp.tokens(s)
		local tokens = coroutine.wrap(tokens)
		return function()
			return tokens(s)
		end
	end



if not ... then


	local sql = [[
		select * from `table` where name = 'so\'me foo''s bar'
			and id <= 5
			or x = ??
			and y = :y;
			and $foo(a, b)
	]]
	for tk, i, j, s, s2 in pp.tokens(sql) do
		if tk ~= 'space' then
			print(tk, i, j, i and j and trim(sql:sub(i, j-1)), s or '', s2 or '')
		end
	end


end
