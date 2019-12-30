--go@ luajit -jp=z *

setfenv(1, require'layerlib_types')
require'layerlib_layer'

--init/free

terra Lib:init()
	self.windows:init()
	self.text_renderer:init()

	self.transforms:init()
	self.transforms:alloc()
	self.transforms:at(0):init()

	self.borders:init()
	self.borders:alloc()
	self.borders:at(0):init()

	self.backgrounds:init(self)
	self.backgrounds:alloc()
	self.backgrounds:at(0):init()

	self.shadows:init()
	self.shadows:alloc()
	self.shadows:at(0):init(nil)

	self.texts:init()
	self.texts:alloc()
	self.texts:at(0):init(&self.text_renderer)

	self.flexs:init()
	self.flexs:alloc()
	self.flexs:at(0):init()

	self.grids:init()
	self.grids:alloc()
	self.grids:at(0):init()

	self.grid_occupied:init()
	self.default_text_span:init()
end

terra Lib:free()

	self.windows:free()

	--check that layers clean up after themselves.
	assert(self.transforms  .items.len == self.transforms .freeindices.len + 1)
	assert(self.borders     .items.len == self.borders    .freeindices.len + 1)
	assert(self.backgrounds .items.len == self.backgrounds.freeindices.len + 1)
	assert(self.shadows     .items.len == self.shadows    .freeindices.len + 1)
	assert(self.texts       .items.len == self.texts      .freeindices.len + 1)
	assert(self.flexs       .items.len == self.flexs      .freeindices.len + 1)
	assert(self.grids       .items.len == self.grids      .freeindices.len + 1)

	--free the defaults too...
	self.transforms:free()
	self.borders:free()
	self.backgrounds:free()
	self.shadows:free()
	self.texts:free()
	self.flexs:free()
	self.grids:free()

	self.text_renderer:free()
	self.grid_occupied:free()
	self.default_text_span:free()
end

--text rendering engine configuration

terra Lib:get_font_size_resolution       (): num return self.text_renderer.font_size_resolution end
terra Lib:get_subpixel_x_resolution      (): num return self.text_renderer.subpixel_x_resolution end
terra Lib:get_word_subpixel_x_resolution (): num return self.text_renderer.word_subpixel_x_resolution end
terra Lib:get_glyph_cache_size           () return self.text_renderer.glyphs.max_size end
terra Lib:get_glyph_run_cache_size       () return self.text_renderer.glyph_runs.max_size end

terra Lib:set_font_size_resolution       (v: num) self.text_renderer.font_size_resolution = v end
terra Lib:set_subpixel_x_resolution      (v: num) self.text_renderer.subpixel_x_resolution = v end
terra Lib:set_word_subpixel_x_resolution (v: num) self.text_renderer.word_subpixel_x_resolution = v end
terra Lib:set_glyph_cache_size           (v: int) self.text_renderer.glyphs.max_size = v end
terra Lib:set_glyph_run_cache_size       (v: int) self.text_renderer.glyph_runs.max_size = v end

--font registration

terra Lib:font(load: tr.FontLoadFunc, unload: tr.FontUnloadFunc)
	return self.text_renderer:font(load, unload)
end

--self-alloc API for ffi

terra layerlib.new()
	return low.new(Lib)
end

terra Lib:free_and_dealloc()
	free(self)
end

--debugging stuff

terra Lib:dump_stats()
	pfn('Glyph cache size     : %d', self.text_renderer.glyphs.size)
	pfn('Glyph cache count    : %d', self.text_renderer.glyphs.count)
	pfn('GlyphRun cache size  : %d', self.text_renderer.glyph_runs.size)
	pfn('GlyphRun cache count : %d', self.text_renderer.glyph_runs.count)
end

return layerlib
