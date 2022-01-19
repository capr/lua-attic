
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
