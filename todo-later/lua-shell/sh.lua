local lfs = require'lfs'
local glue = require'glue'

--depth-first filesystem search
--API should be like in lfs: dir(path) -> next(dir_obj) -> f
	--for f in dir(path) do f.file, f.path, f.mode, f:next(), f:down(), f:back(), f:close() end


local function dir(p0, handle)
	p0 = p0 or '.'
	local function recurse(p, depth)
		local dp = p0 .. (p and '/' .. p or '')
		for f in lfs.dir(dp) do
			if f ~= '.' and f ~= '..' then
				local mode = lfs.attributes(dp .. '/' .. f, 'mode')
				if handle(f, p, mode, depth) == false then
					return false
				end
				if mode == 'directory' then
					if recurse((p and p .. '/' .. f or f), depth + 1) == false then
						return false
					end
				end
			end
		end
	end
	recurse(nil, 1)
end

local function dir(p0, handle)
	p0 = p0 or '.'
	local function recurse(p, depth)
		local dp = p0 .. (p and '/' .. p or '')
		for f in lfs.dir(dp) do
			if f ~= '.' and f ~= '..' then
				local mode = lfs.attributes(dp .. '/' .. f, 'mode')
				if handle(f, p, mode, depth) == false then
					return false
				end
			end
		end
		for f in lfs.dir(dp) do
			if f ~= '.' and f ~= '..' then
				local mode = lfs.attributes(dp .. '/' .. f, 'mode')
				if mode == 'directory' then
					if recurse((p and p .. '/' .. f or f), depth + 1) == false then
						return false
					end
				end
			end
		end
	end
	recurse(nil, 1)
end

return glue.autoload({
	dir = dir,
}, {
	glob = 'sh_glob',
})
