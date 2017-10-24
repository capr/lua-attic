local ffi = require'ffi'
local curl = require'libcurl'
local lfs = require'lfs'
local _ = string.format

local function abspath(dir)
	local pwd = lfs.currentdir()
	assert(lfs.chdir(dir))
	local dir = lfs.currentdir()
	assert(lfs.chdir(pwd))
	return dir
end

local function canopen(name, mode)
	local f = io.open(name, mode or 'rb')
	if f then f:close() end
	return f ~= nil and name or nil
end

local function exename()
	for i=0,-100,-1 do
		if not arg[i-1] then
			return arg[i]
		end
	end
end

local function fixpath(s)
	return ffi.abi'win' and s:gsub('/', '\\') or s
end

local function splitpath(path)
	local dir, file = path:match('(.-)[/\\]?([^/\\]+)$')
	local dir = dir == '' and '.' or dir
	return dir, file
end

local function splitfile(file)
	if not file:find'%.' then return file end
	local name, ext = file:match'(.-)%.([^%.]*)$'
	return name, ext
end

local exedir, exefile = splitpath(exename())
local exedir = abspath(exedir)
local exename = splitfile(exefile)
print('exe:', exedir, exename)

local function bundled()
	return not (exename:find'^luajit' and arg[0]:find'lp.lua' and #arg > 0)
end

local scriptdir, scriptfile = exedir, exename..'.lua'
if not bundled() then --not bundled, script given as arg #1
	scriptdir, scriptfile = splitpath(arg[1])
	scriptdir = abspath(scriptdir)
	scriptname = splitfile(scriptfile)
end
print('script:', scriptdir, scriptname)

package.path = fixpath(_('%s/?.lua;%s/?/init.lua;%s', scriptdir, scriptdir, package.path))
--if scriptdir ~= exedir then
	--package.path = fixpath(_('%s/?.lua;%s/?/init.lua;%s', exedir, exedir, package.path))

local module_lists = {'https://luapower.com/modules'}

local function scandir(dir, file)

end

local function getpackage(mod)

end

local function download(package)

end

print(package.path)
