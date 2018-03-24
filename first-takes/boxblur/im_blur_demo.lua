local ffi = require'ffi'
local time = require'time'
local boxblur = require'im_boxblur'.blur_8888
local boxblur_lua = require'im_boxblur_lua'.blur_8888
local stackblur = require'im_stackblur'.blur_8888

local player = require'cplayer'
local jpeg = require'nanojpeg'
local bitmap = require'bitmap'

local simg = jpeg.load'media/jpeg/birds.jpg'
simg = bitmap.copy(simg, 'bgra8', false, true)

ffi.cdef[[
void fast_blur_horiz2d( const void *in, void *blurred,
	int32_t width, int32_t height, int32_t src_stride, int32_t dst_stride );
void fast_blur_halide( const void *in, void *blurred,
	int32_t width, int32_t height, int32_t src_stride, int32_t dst_stride );
void boxblur_argb8( const void *src, void *dst,
	int32_t width, int32_t height, int32_t src_stride, int32_t dst_stride,
	int32_t radius, int32_t passes);
]]
local fastblur1 = ffi.load'fastblur1'.fast_blur_horiz2d
local fastblur2 = ffi.load'fastblur2'.fast_blur_horiz2d
local fastblur3 = ffi.load'fastblur3'.fast_blur_horiz2d
local fastblur_halide = ffi.load'fastblur_halide'.fast_blur_halide

local img = bitmap.new(simg.w + 64, simg.h + 512, 'ga8', false, 16)
local img1 = bitmap.sub(img, 32, 256, simg.w, simg.h)
bitmap.paint(simg, img1)
bitmap.paint(img1, img1, function(g)
	return g, 0-- / 256
end)
local dimg = bitmap.new(simg.w, simg.h + 512, 'ga8', false, 16)
local img2 = bitmap.sub(dimg, 0, 256, simg.w, simg.h)

local n = 10
local t0 = time.clock()
for i=1,n do
	--print(img1.data, img2.data, img1.size, img2.size)
	fastblur3(img1.data, img2.data, img1.w, img1.h, img1.stride / 2, img2.stride / 2)
	--here = true
	--bitmap.paint(img2, img1)
	--here = false
end
--bitmap.paint(img1, img2)
local t1 = time.clock()
local d = (t1 - t0) / n
local b = img1.w * img1.h
local B = 1920 * 1080
local dB = B * d / b
local fps = 1 / dB
print(string.format('%d fps @ full-hd', fps))

bitmap.paint(img2, img2, function(g)
	return g, 128
end)

player.h = 900

local data2
function player:on_render()
	local radius = math.floor((self.mousex or 1) / 20) - 10
	--local img = bitmap.copy(simg)
	for i=1,1 do
		--stackblur(img.data, img.w, img.h, radius)
		--boxblur(img.data, img.w, img.h, radius)
		--boxblur_lua(img.data, img.w, img.h, radius)
	end
	--self:image{x = 2, y = 2, image = simg}
	self:image{x = 2, y = 2, image = img2}
end

player:play()
