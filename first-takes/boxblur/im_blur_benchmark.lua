local ffi = require'ffi'
local clock = require'time'.clock

local function benchmark(blurmod, w, h, n, r)
	local r = r or 30
	local size = w * h * 4
	local img = ffi.new('uint8_t[?]', size)
	local imgcopy = ffi.new('uint8_t[?]', size)
	local blur = require(blurmod:gsub(' ', '')).blur_8888
	local t0 = clock()
	for i=1,n do
		ffi.copy(img, imgcopy, size)
		blur(img, w, h, r)
	end
	local fps = 1 / ((clock() - t0) / n)
	print(string.format('%s  r=%d fps @ %dx%d:  ', blurmod, r, w, h), fps)
end

benchmark('im_stackblur  ', 1920, 1080, 5)
benchmark('im_boxblur_lua', 1920, 1080, 10)
benchmark('im_boxblur    ', 1920, 1080, 10)

benchmark('im_stackblur  ', 1024, 768, 20)
benchmark('im_boxblur_lua', 1024, 768, 60)
benchmark('im_boxblur    ', 1024, 768, 60)

benchmark('im_stackblur  ', 320, 200, 80)
benchmark('im_boxblur_lua', 320, 200, 400)
benchmark('im_boxblur    ', 320, 200, 400)

