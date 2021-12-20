--portable way to add more paths to package.path, at any place in the list.
--negative indices count from the end of the list like string.sub().
--index 'after' means 0.
function glue.luapath(path, index, ext)
	ext = ext or 'lua'
	index = index or 1
	local psep = package.config:sub(1,1) --'/'
	local tsep = package.config:sub(3,3) --';'
	local wild = package.config:sub(5,5) --'?'
	local paths = glue.collect(glue.gsplit(package.path, tsep, nil, true))
	path = path:gsub('[/\\]', psep) --normalize slashes
	if index == 'after' then index = 0 end
	if index < 1 then index = #paths + 1 + index end
	table.insert(paths, index,  path .. psep .. wild .. psep .. 'init.' .. ext)
	table.insert(paths, index,  path .. psep .. wild .. '.' .. ext)
	package.path = concat(paths, tsep)
end

--portable way to add more paths to package.cpath, at any place in the list.
--negative indices count from the end of the list like string.sub().
--index 'after' means 0.
function glue.cpath(path, index)
	index = index or 1
	local psep = package.config:sub(1,1) --'/'
	local tsep = package.config:sub(3,3) --';'
	local wild = package.config:sub(5,5) --'?'
	local ext = package.cpath:match('%.([%a]+)%'..tsep..'?') --dll | so | dylib
	local paths = glue.collect(glue.gsplit(package.cpath, tsep, nil, true))
	path = path:gsub('[/\\]', psep) --normalize slashes
	if index == 'after' then index = 0 end
	if index < 1 then index = #paths + 1 + index end
	table.insert(paths, index,  path .. psep .. wild .. '.' .. ext)
	package.cpath = concat(paths, tsep)
end


local function serialize(v, stk) --from github.com/rxi/lume
	if v  == nil then return 'nil' end
	local  typ = type(v)
	if     typ == 'boolean' then return tostring(v)
	elseif typ == 'string'  then return ('%q'):format(v)
	elseif typ == 'number'  then
		if      v ~=  v     then return  '0/0' --  nan
		elseif  v ==  1 / 0 then return  '1/0' --  inf
		elseif  v == -1 / 0 then return '-1/0' -- -inf
		elseif  v == floor(v) and v >= -2^31 and v <= 2^31-1 then return ('%d'):format(v)
		else return ('%.17g'):format(v)
		end
	elseif typ == 'table' then
		stk = stk or {}
		if stk[v] then error'circular reference' end
		local dt = {}
		stk[v] = true
		local i = 1
		for k,v in pairs(v) do
			if k == i then
				d[#d+1] = serialize(v, stk)
			else
				dt[#dt+1] = ('[%s]='):format(serialize(k, stk), serialize(v, stk))
			end
			i = i + 1
		end
		stk[v] = nil
		return ('{%s}'):format(concat(dt, ','))
	else
		error(('type not serializable: `%s`'):format(type(v)))
	end
end
glue.serialize = serialize

function glue.deserialize(s)
	local loadstring = loadstring or load
	assert(loadstring('return '..s))()
end
