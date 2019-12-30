
setfenv(1, require'layerlib_types')

--windows --------------------------------------------------------------------

terra Window:layer(id: int)
	return self.layers:at(id)
end

terra Window:get_view()
	return self:layer(0)
end

terra Window:init(lib: &Lib)
	self.lib = lib
	self.layers:init()
	self.layers:alloc()
	self.view:init(self)
end

terra Window:free()
	self.layers:free()
end

terra Lib:window()
	var win = self.windows:alloc()
	win:init(self)
	return win
end

terra Window:free_and_dealloc()
	var lib = self.lib
	self:free()
	lib.windows:release(self)
end

--layer hierarchy ------------------------------------------------------------

Layer.metamethods.__for = function(self, body)
	return quote
		for _,id in self.child_ids do
			[ body(`self.window:layer(@id)) ]
		end
	end
end

terra Layer:get_child_count()
	return self.child_ids.len
end

terra Layer:get_parent()
	return self.window:layer(self.parent_id)
end

terra Layer:child(i: int)
	return self.window:layer(self.child_ids(i))
end

terra Layer:get_id()
	return self.window.layers:index(self)
end

terra Layer:get_index()
	return self.parent.child_ids:find(self.id)
end

terra Window:new_layer(parent_id: int, i: int)
	var parent = self.layers:at(parent_id)
	assert(parent.window == self)
	var layer, id = self.layers:alloc() --this invalidates parent!
	parent = self.layers:at(parent_id)
	layer:init(self)
	layer.parent_id = parent_id
	if i < 0 then
		i = parent.child_count - i + 1
	end
	i = clamp(i, 0, parent.child_count)
	parent.child_ids:insert(i, id)
	return layer
end

terra Layer:new_child(i: int)
	return self.window:new_layer(self.id, i)
end

terra Layer:free_and_deallocate()
	assert(self.parent ~= nil)
	self.parent.child_ids:remove(self.index)
	self.window.layers:release(self.id)
end

terra Layer:move(parent: &Layer, i: int)
	assert(parent ~= nil)
	assert(self.parent ~= nil)
	assert(parent.window == self.window)
	if parent == self.parent then
		i = clamp(i, 0, parent.child_count-1)
		parent.child_ids:move(self.index, i)
	else
		i = clamp(i, 0, parent.child_count)
		self.parent.child_ids:remove(self.index)
		parent.child_ids:insert(i, self.id)
	end
end

--geometry utils -------------------------------------------------------------

terra Layer.methods.size_changed :: {&Layer} -> {}

terra Layer:get_x() return self.x end
terra Layer:get_y() return self.y end
terra Layer:get_w() return self._w end
terra Layer:get_h() return self._h end

terra Layer:set_x(v: num) self.x = v end
terra Layer:set_y(v: num) self.y = v end
terra Layer:set_w(v: num) self._w = v; self:size_changed() end
terra Layer:set_h(v: num) self._h = v; self:size_changed() end

terra Layer:get_padding_left  () return self.padding_left   end
terra Layer:get_padding_top   () return self.padding_top    end
terra Layer:get_padding_right () return self.padding_right  end
terra Layer:get_padding_bottom() return self.padding_bottom end

terra Layer:set_padding_left  (v: num) self.padding_left   = v end
terra Layer:set_padding_top   (v: num) self.padding_top    = v end
terra Layer:set_padding_right (v: num) self.padding_right  = v end
terra Layer:set_padding_bottom(v: num) self.padding_bottom = v end

terra Layer:get_min_cw() return self.min_cw end
terra Layer:get_min_ch() return self.min_cw end

terra Layer:set_min_cw(v: num) self.min_cw = v end
terra Layer:set_min_ch(v: num) self.min_ch = v end

terra Layer:get_px(): num return self.padding_left end
terra Layer:get_py(): num return self.padding_top end
terra Layer:get_pw(): num return self.padding_left + self.padding_right end
terra Layer:get_ph(): num return self.padding_top + self.padding_bottom end
terra Layer:get_cx(): num return self.x + self.padding_left end
terra Layer:get_cy(): num return self.y + self.padding_top end
terra Layer:get_cw(): num return self.w - self.pw end
terra Layer:get_ch(): num return self.h - self.ph end
terra Layer:set_cw(cw: num) self.w = cw + (self.w - self.cw) end
terra Layer:set_ch(ch: num) self.h = ch + (self.h - self.ch) end

terra Layer:snapx(x: num) return snapx(x, self.snap_x) end
terra Layer:snapy(y: num) return snapx(y, self.snap_y) end
terra Layer:snapxw(x: num, w: num) return snap_xw(x, w, self.snap_x) end
terra Layer:snapyh(y: num, h: num) return snap_xw(y, h, self.snap_y) end
terra Layer:snapcx(cx: num) return snapx(cx-self.cx, self.snap_x)+self.cx end
terra Layer:snapcy(cy: num) return snapx(cy-self.cy, self.snap_y)+self.cy end

--layer relative geometry & matrix -------------------------------------------

terra Layer:rel_matrix() --box matrix relative to parent's content space
	var m: matrix; m:init()
	m:translate(self:snapx(self.x), self:snapy(self.y))
	self.transform:apply(&m)
	return m
end

terra Layer:abs_matrix(): matrix --box matrix in window space
	var am: matrix
	if self.parent ~= nil then
		am = self.parent:abs_matrix()
	else
		am:init()
	end
	var rm = self:rel_matrix()
	am:transform(&rm)
	return am
end

terra Layer:cr_abs_matrix(cr: &context) --box matrix in cr's current space
	var cm = cr:matrix()
	var rm = self:rel_matrix()
	cm:transform(&rm)
	return cm
end

--convert point from own box space to parent content space.
terra Layer:from_box_to_parent(x: num, y: num)
	var m = self:rel_matrix()
	return m:point(x, y)
end

--convert point from parent content space to own box space.
terra Layer:from_parent_to_box(x: num, y: num)
	var m = self:rel_matrix(); m:invert()
	return m:point(x, y)
end

--convert point from own content space to parent content space.
terra Layer:to_parent(x: num, y: num)
	var m = self:rel_matrix()
	m:translate(self.px, self.py)
	return m:point(x, y)
end

--convert point from parent content space to own content space.
terra Layer:from_parent(x: num, y: num)
	var m = self:rel_matrix()
	m:translate(self.px, self.py)
	m:invert()
	return m:point(x, y)
end

terra Layer:to_window(x: num, y: num): {num, num} --parent & child interface
	var x, y = self:to_parent(x, y)
	if self.parent ~= nil then
		return self.parent:to_window(x, y)
	else
		return x, y
	end
end

terra Layer:from_window(x: num, y: num): {num, num} --parent & child interface
	if self.parent ~= nil then
		x, y = self.parent:from_window(x, y)
	end
	return self:from_parent(x, y)
end

--content-box geometry, drawing and hit testing ------------------------------

--convert point from own box space to own content space.
terra Layer:to_content(x: num, y: num)
	return x - self.px, y - self.py
end

--content point from own content space to own box space.
terra Layer:from_content(x: num, y: num)
	return self.px + x, self.py + y
end

--layer components -----------------------------------------------------------

require'layerlib_border'
require'layerlib_background'
require'layerlib_shadow'
require'layerlib_text'
require'layerlib_draw'
require'layerlib_layout'

--init/free ------------------------------------------------------------------

terra Layer:init(window: &Window)

	fill(self)

	self.window = window
	self.lib = window.lib

	self.snap_x = true
	self.snap_y = true

	self.visible = true
	self.opacity = 1

	self.layout_solver = &null_layout
end

terra Layer:free()
	assert(self.lib ~= nil)

	for e in self do
		e:free()
	end
	self.child_ids:free()

	self:free_border()
	self:free_background()
	self:free_shadow()
	self:free_text()

	self.layout_type = LAYOUT_NULL

	self.lib = nil
	self.window = nil
	self.parent_id = 0
end
