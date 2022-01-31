function resize_image(src_path, dst_path, max_w, max_h)

	local cairo = require'cairo'

	glue.fcall(function(finally)

		--decode.
		local bmp
		local src_ext = fileext(src_path)
		if src_ext == 'jpg' or src_ext == 'jpeg' then
			local libjpeg = require'libjpeg'
			local f = assert(fs.open(src_path, 'r'), 'not_found')
			finally(function() f:close() end)
			local read = f:buffered_read()
			local img = assert(libjpeg.open{read = read})
			finally(function() img:free() end)
			local w, h = box2d.fit(img.w, img.h, max_w, max_h)
			local sn = math.ceil(glue.clamp(math.max(w / img.w, h / img.h) * 8, 1, 8))
			bmp = assert(img:load{
				accept = {bgra8 = true},
				scale_num = sn,
				scale_denom = 8,
			})
		else
			assert(false)
		end

		--scale down, if necessary.
		local w, h = box2d.fit(bmp.w, bmp.h, max_w, max_h)
		if w < bmp.w or h < bmp.h then
			local src_sr = cairo.image_surface(bmp)
			local dst_sr = cairo.image_surface('bgra8', w, h)
			local cr = dst_sr:context()
			local sx = w / bmp.w
			local sy = h / bmp.h
			cr:scale(sx, sy)
			cr:source(src_sr)
			cr:paint()
			cr:free()
			src_sr:free()
			bmp = dst_sr:bitmap()
			finally(function() dst_sr:free() end)
		end

		--encode back.
		local dst_ext = fileext(dst_path)
		if dst_ext == 'jpg' or dst_ext == 'jpeg' then
			local libjpeg = require'libjpeg'
			local tmp_path = dst_path..'.tmp'
			mkdirs(tmp_path)
			local f = assert(fs.open(tmp_path, 'w'))
			finally(function() if f then f:close() end end)
			local function write(buf, len)
				assert(f:write(buf, len) == len)
			end
			assert(libjpeg.save{
				bitmap = bmp,
				write = write,
				quality = 90,
			})
			f:close()
			f = nil
			local ok, err = glue.replacefile(tmp_path, dst_path)
			if not ok then
				os.remove(tmp_path)
				assertf(false, 'glue.replacefile(%s, %s): %s', tmp_path, dst_path, err)
			end
		else
			assert(false)
		end

	end)

end
