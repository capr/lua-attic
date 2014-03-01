local glue = require'glue'


--[[

function glue.unprotect(ok, result, ...)
	if not ok then return nil, result, ... end
	if result == nil then result = true end
	return result, ...
end

local function pcall_error(e)
	return tostring(e) .. '\n' .. debug.traceback()
end
function glue.pcall(f, ...) --luajit and lua 5.2 only!
	return xpcall(f, pcall_error, ...)
end

local function pass(ok, ...)
	if not ok then error(...) end
	return ...
end
function glue.call(f, ...)
	return function(...)
		return pass(glue.pcall(f, ...))
	end
end

local unprotect = glue.unprotect
function glue.fpcall(f,...) --bloated: 2 tables, 4 closures. can we reduce the overhead?
	local fint, errt = {}, {}
	local function finally(f) fint[#fint+1] = f end
	local function onerror(f) errt[#errt+1] = f end
	local function err(e)
		for i=#errt,1,-1 do errt[i]() end
		for i=#fint,1,-1 do fint[i]() end
		return tostring(e) .. '\n' .. debug.traceback()
	end
	local function pass(ok,...)
		if ok then
			for i=#fint,1,-1 do fint[i]() end
		end
		return unprotect(ok,...)
	end
	return pass(xpcall(f, err, finally, onerror, ...))
end

local fpcall = glue.fpcall
function glue.fcall(f,...)
	return assert(fpcall(f,...))
end
]]


local function pass(ok, ...)
	if not ok then error(...) end
	return ...
end

function glue.trace(f)
	return function(...)
		return pass(glue.pcall(f, ...))
	end
end


function glue.fcall(f, finally)

end

glue.fcall(function()

end, function()

end)

