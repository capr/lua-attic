
--layerlib C/ffi module.

--NOTE: This is a graphics API and it's for Lua consumption so all input
--is valid in any state (no asserts!). Oh, and no explicit invalidation!

setfenv(1, require'layerlib')

--layer geometry

terra Layer:size_changed()
	self.shadow:invalidate()
	self:unwrap()
end

do end --borders (and fix for terra issue #358)

terra Layer:get_border_left   () return self.border.left   end
terra Layer:get_border_right  () return self.border.right  end
terra Layer:get_border_top    () return self.border.top    end
terra Layer:get_border_bottom () return self.border.bottom end

terra Layer:set_border_left   (v: num) self:new_border().left   = v; self.shadow:invalidate() end
terra Layer:set_border_right  (v: num) self:new_border().right  = v; self.shadow:invalidate() end
terra Layer:set_border_top    (v: num) self:new_border().top    = v; self.shadow:invalidate() end
terra Layer:set_border_bottom (v: num) self:new_border().bottom = v; self.shadow:invalidate() end

terra Layer:get_corner_radius_top_left     () return self.border.corner_radius_top_left     end
terra Layer:get_corner_radius_top_right    () return self.border.corner_radius_top_right    end
terra Layer:get_corner_radius_bottom_left  () return self.border.corner_radius_bottom_left  end
terra Layer:get_corner_radius_bottom_right () return self.border.corner_radius_bottom_right end
terra Layer:get_corner_radius_kappa        () return self.border.corner_radius_kappa        end

terra Layer:set_corner_radius_top_left     (v: num) self:new_border().corner_radius_top_left     = v; self.shadow:invalidate() end
terra Layer:set_corner_radius_top_right    (v: num) self:new_border().corner_radius_top_right    = v; self.shadow:invalidate() end
terra Layer:set_corner_radius_bottom_left  (v: num) self:new_border().corner_radius_bottom_left  = v; self.shadow:invalidate() end
terra Layer:set_corner_radius_bottom_right (v: num) self:new_border().corner_radius_bottom_right = v; self.shadow:invalidate() end
terra Layer:set_corner_radius_kappa        (v: num) self:new_border().corner_radius_kappa        = v; self.shadow:invalidate() end

terra Layer:get_border_color_left   () return self.border.color_left   .uint end
terra Layer:get_border_color_right  () return self.border.color_right  .uint end
terra Layer:get_border_color_top    () return self.border.color_top    .uint end
terra Layer:get_border_color_bottom () return self.border.color_bottom .uint end

terra Layer:set_border_color_left   (v: uint32) self:new_border().color_left   .uint = v end
terra Layer:set_border_color_right  (v: uint32) self:new_border().color_right  .uint = v end
terra Layer:set_border_color_top    (v: uint32) self:new_border().color_top    .uint = v end
terra Layer:set_border_color_bottom (v: uint32) self:new_border().color_bottom .uint = v end

terra Layer:get_border_dash_count() return self.border.dash.len end
terra Layer:clear_border_dashes() self.border.dash.len = 0 end
terra Layer:get_border_dash(i: int) return self:new_border().dash(i) end
terra Layer:set_border_dash(i: int, v: num) return self:new_border().dash:set(i, v, 0) end
terra Layer:get_border_dash_offset() return self.border.dash_offset end
terra Layer:set_border_dash_offset(v: int) self:new_border().dash_offset = v end

terra Layer:get_border_offset() return self.border.offset end
terra Layer:set_border_offset(v: int) self:new_border().offset = v; self.shadow:invalidate() end

terra Layer:set_border_line_to(line_to: BorderLineToFunc)
	self:new_border().line_to = line_to; self.shadow:invalidate()
end

do end --drawing

terra Layer:get_visible      () return self.visible end
terra Layer:get_clip_content () return self.clip_content end
terra Layer:get_snap_x       () return self.snap_x end
terra Layer:get_snap_y       () return self.snap_y end
terra Layer:get_opacity      () return self.opacity end

terra Layer:set_visible      (v: bool) self.visible = v end
terra Layer:set_clip_content (v: enum) self.clip_content = v end
terra Layer:set_snap_x       (v: bool) self.snap_x = v end
terra Layer:set_snap_y       (v: bool) self.snap_y = v end
terra Layer:set_opacity      (v: num)  self.opacity = v end

do end --backgrounds

terra Layer:get_background_type() return self.background.type end
terra Layer:set_background_type(v: enum)
	var b = self.background
	if b.type == v then return end
	self:free_background()
	if v ~= BACKGROUND_TYPE_NONE then
		b = self:new_background()
		b.type = v
		if b.type > BACKGROUND_TYPE_COLOR then
			b.pattern:init()
		end
	end
end

terra Layer:get_background_hittable    () return self.background.hittable end
terra Layer:get_background_clip_border_offset() return self.background.clip_border_offset end
terra Layer:get_background_operator    () return self.background.operator end

terra Layer:set_background_hittable    (v: bool) self:new_background().hittable = v end
terra Layer:set_background_clip_border_offset(v: num) self:new_background().clip_border_offset = v; self.shadow:invalidate() end
terra Layer:set_background_operator    (v: enum) self:new_background().operator = v end

terra Layer:get_background_color()
	return iif(self.background_type == BACKGROUND_TYPE_COLOR,
		self.background.color.uint, 0)
end
terra Layer:set_background_color(v: uint)
	if self.background_type == BACKGROUND_TYPE_COLOR then
		self.background.color.uint = v
	end
end

local get = function(self, FIELD)
	return `iif(self.background_type == BACKGROUND_TYPE_LINEAR_GRADIENT,
		self.background.pattern.gradient.points.[FIELD], 0)
end
terra Layer:get_background_gradient_x1() return [get(self, 'x1')] end
terra Layer:get_background_gradient_y1() return [get(self, 'y1')] end
terra Layer:get_background_gradient_x2() return [get(self, 'x2')] end
terra Layer:get_background_gradient_y2() return [get(self, 'y2')] end

local set = function(self, FIELD, val)
	return quote
		if self.background_type == BACKGROUND_TYPE_LINEAR_GRADIENT then
			self.background.pattern.gradient.points.[FIELD] = val
		end
	end
end
terra Layer:set_background_gradient_x1(x1: num) [set(self, 'x1', x1)] end
terra Layer:set_background_gradient_y1(y1: num) [set(self, 'y1', y1)] end
terra Layer:set_background_gradient_x2(x2: num) [set(self, 'x2', x2)] end
terra Layer:set_background_gradient_y2(y2: num) [set(self, 'y2', y2)] end

local get = function(self, FIELD)
	return `iif(self.background_type == BACKGROUND_TYPE_RADIAL_GRADIENT,
		self.background.pattern.gradient.circles.[FIELD], 0)
end
terra Layer:get_background_gradient_cx1() return [get(self, 'cx1')] end
terra Layer:get_background_gradient_cy1() return [get(self, 'cy1')] end
terra Layer:get_background_gradient_cx2() return [get(self, 'cx2')] end
terra Layer:get_background_gradient_cy2() return [get(self, 'cy2')] end
terra Layer:get_background_gradient_r1 () return [get(self, 'r1' )] end
terra Layer:get_background_gradient_r2 () return [get(self, 'r2' )] end

local set = function(self, FIELD, val)
	return quote
		if self.background_type == BACKGROUND_TYPE_RADIAL_GRADIENT then
			self.background.pattern.gradient.circles.[FIELD] = val
		end
	end
end
terra Layer:set_background_gradient_cx1(cx1: num) [set(self, 'cx1', cx1)] end
terra Layer:set_background_gradient_cy1(cy1: num) [set(self, 'cy1', cy1)] end
terra Layer:set_background_gradient_cx2(cx2: num) [set(self, 'cx2', cx2)] end
terra Layer:set_background_gradient_cy2(cy2: num) [set(self, 'cy2', cy2)] end
terra Layer:set_background_gradient_r1 (r1 : num) [set(self, 'r1' , r1 )] end
terra Layer:set_background_gradient_r2 (r2 : num) [set(self, 'r2' , r2 )] end

terra Layer:get_background_gradient_color_stops_count()
	var b = self.background
	return iif((b.type and BACKGROUND_TYPE_GRADIENT) ~= 0,
		b.pattern.gradient.color_stops.len, 0)
end
terra Layer:clear_background_gradient_color_stops()
	var b = self.background
	if (b.type and BACKGROUND_TYPE_GRADIENT) ~= 0 then
		b.pattern.gradient.color_stops.len = 0
	end
end
terra Layer:get_background_gradient_color_stops_color(i: int)
	var b = self.background
	if (b.type and BACKGROUND_TYPE_GRADIENT) ~= 0 then
		var cs = b.pattern.gradient.color_stops:at(i, nil)
		return iif(cs ~= nil, cs.color.uint, 0)
	else
		return 0
	end
end
terra Layer:get_background_gradient_color_stops_offset(i: int)
	var b = self.background
	if (b.type and BACKGROUND_TYPE_GRADIENT) ~= 0 then
		var cs = b.pattern.gradient.color_stops:at(i, nil)
		return iif(cs ~= nil, cs.offset, 0)
	else
		return 0
	end
end
terra Layer:set_background_gradient_color_stops_color(i: int, color: uint32)
	var b = self.background
	if (b.type and BACKGROUND_TYPE_GRADIENT) ~= 0 then
		b.pattern.gradient.color_stops:getat(i, [ColorStop.empty]).color.uint = color
	end
end
terra Layer:set_background_gradient_color_stops_offset(i: int, offset: num)
	var b = self.background
	if (b.type and BACKGROUND_TYPE_GRADIENT) ~= 0 then
		b.pattern.gradient.color_stops:getat(i, [ColorStop.empty]).offset = offset
	end
end

terra Layer:get_background_image()
	var b = self.background
	return iif(b.type == BACKGROUND_TYPE_IMAGE, &b.pattern.bitmap, nil)
end

terra Layer:set_background_image(v: &Bitmap)
	var b = self.background
	if b.type == BACKGROUND_TYPE_IMAGE then
		b.pattern.bitmap = @v
	end
end

local get = function(self, FIELD)
	return `iif(self.background_type > BACKGROUND_TYPE_COLOR,
		self.background.pattern.[FIELD], 0)
end
terra Layer:get_background_x      () return [get(self, 'x')] end
terra Layer:get_background_y      () return [get(self, 'y')] end
terra Layer:get_background_extend () return [get(self, 'extend')] end

local set = function(self, FIELD, val)
	return quote
		if self.background_type > BACKGROUND_TYPE_COLOR then
			self.background.pattern.[FIELD] = val
		end
	end
end
terra Layer:set_background_x      (v: num)  [set(self, 'x', v)] end
terra Layer:set_background_y      (v: num)  [set(self, 'y', v)] end
terra Layer:set_background_extend (v: enum) [set(self, 'extend', v)] end

local get = function(self, FIELD)
	return `iif(self.background_type > BACKGROUND_TYPE_COLOR,
		self.lib.transforms:at(self.background.pattern.transform_id).[FIELD], 0)
end
terra Layer:get_background_rotation    () return [get(self, 'rotation'   )] end
terra Layer:get_background_rotation_cx () return [get(self, 'rotation_cx')] end
terra Layer:get_background_rotation_cy () return [get(self, 'rotation_cy')] end
terra Layer:get_background_scale       () return [get(self, 'scale'      )] end
terra Layer:get_background_scale_cx    () return [get(self, 'scale_cx'   )] end
terra Layer:get_background_scale_cy    () return [get(self, 'scale_cy'   )] end

local set = function(self, FIELD, val)
	return quote
		if self.background_type > BACKGROUND_TYPE_COLOR then
			var freelist = self.lib.transforms
			var t = freelist:at(self.transform_id)
			if self.transform_id == 0 then
				var t, id = freelist:alloc()
				t:init()
				self.transform_id = id
			end
			t.[FIELD] = val
		end
	end
end
terra Layer:set_background_rotation    (v: num) [set(self, 'rotation', v)] end
terra Layer:set_background_rotation_cx (v: num) [set(self, 'rotation_cx', v)] end
terra Layer:set_background_rotation_cy (v: num) [set(self, 'rotation_cy', v)] end
terra Layer:set_background_scale       (v: num) [set(self, 'scale', v)] end
terra Layer:set_background_scale_cx    (v: num) [set(self, 'scale_cx', v)] end
terra Layer:set_background_scale_cy    (v: num) [set(self, 'scale_cy', v)] end

do end --shadows

terra Layer:get_shadow_x      () return self.shadow.x end
terra Layer:get_shadow_y      () return self.shadow.x end
terra Layer:get_shadow_color  () return self.shadow.color end
terra Layer:get_shadow_blur   () return self.shadow.blur end
terra Layer:get_shadow_passes () return self.shadow.passes end

terra Layer:set_shadow_x      (v: num)    self:new_shadow().x          = v end
terra Layer:set_shadow_y      (v: num)    self:new_shadow().y          = v end
terra Layer:set_shadow_color  (v: uint32) self:new_shadow().color.uint = v end
terra Layer:set_shadow_blur   (v: uint8)  self:new_shadow().blur       = v; self.shadow:invalidate() end
terra Layer:set_shadow_passes (v: uint8)  self:new_shadow().passes     = v; self.shadow:invalidate() end

do end --text

terra Layer:get_text_utf32() return self.text.layout.text.elements end
terra Layer:get_text_utf32_len() return self.text.layout.text.len end

terra Layer:set_text_utf32(s: &codepoint, len: int)
	var t = self:new_text()
	t.layout.text.len = 0
	t.layout.text:add(s, min(t.layout.maxlen, len))
	self:unshape()
end

terra Layer:set_text_utf8(s: rawstring, len: int)
	var t = self:new_text()
	if len < 0 then len = strnlen(s, t.layout.maxlen) end
	utf8.decode.toarr(s, len, &t.layout.text, t.layout.maxlen, utf8.REPLACE, utf8.INVALID)
	self:unshape()
end

terra Layer:get_text_maxlen() return self.text.layout.maxlen end
terra Layer:set_text_maxlen(maxlen: int) self:new_text().layout.maxlen = maxlen end

--text spans

terra Layer:get_text_span_count() return self.text.layout.spans.len end
terra Layer:clear_text_spans()
	if self.text.layout.spans.len > 0 then
		self:new_text().layout.spans.len = 0
		self:unshape()
	end
end

terra Layer:span(i: int)
	return self.text.layout.spans:at(i, &self.lib.default_text_span)
end

terra Layer:new_span(i: int)
	var a = &self:new_text().layout.spans
	var t = a:at(i, nil)
	if t == nil then
		t = a:set(i, self.lib.default_text_span, self.lib.default_text_span)
		self:unshape()
	end
	return t
end

terra Layer:get_text_span_feature_count(i: int)
	var span = self.text.layout.spans:at(i, nil)
	return iif(span ~= nil, span.features.len, 0)
end
terra Layer:clear_text_span_features(i: int)
	var span = self.text.layout.spans:at(i, nil)
	if span ~= nil then
		span.features.len = 0
		self:unshape()
	end
end
terra Layer:get_text_span_feature(span_i: int, feat_i: int, buf: &char, len: int)
	var feat = self:span(span_i).features:at(feat_i, nil)
	if feat ~= nil then
		hb_feature_to_string(feat, buf, len)
		return true
	end
	return false
end
local default_feat = `hb_feature_t {0, 0, 0, 0}
terra Layer:set_text_span_feature(span_i: int, feat_i: int, s: rawstring, len: int)
	var feat = self:new_span(span_i).features:set(feat_i, default_feat, default_feat)
	if hb_feature_from_string(s, len, feat) ~= 0 then
		self:unshape()
		return true
	else
		return false
	end
end

terra Layer:get_text_span_offset            (i: int) return self:span(i).offset            end
terra Layer:get_text_span_font_size         (i: int) return self:span(i).font_size         end
terra Layer:get_text_span_dir               (i: int) return self:span(i).dir               end
terra Layer:get_text_span_line_spacing      (i: int) return self:span(i).line_spacing      end
terra Layer:get_text_span_hardline_spacing  (i: int) return self:span(i).hardline_spacing  end
terra Layer:get_text_span_paragraph_spacing (i: int) return self:span(i).paragraph_spacing end
terra Layer:get_text_span_nowrap            (i: int) return self:span(i).nowrap            end
terra Layer:get_text_span_color             (i: int) return self:span(i).color.uint        end
terra Layer:get_text_span_opacity           (i: int) return self:span(i).opacity           end
terra Layer:get_text_span_operator          (i: int) return self:span(i).operator          end

terra Layer:set_text_span_offset            (i: int, v: int)            self:new_span(i).offset = v            ; self:unshape() end
terra Layer:set_text_span_font_size         (i: int, v: num)            self:new_span(i).font_size = v         ; self:unshape() end
terra Layer:set_text_span_dir               (i: int, v: FriBidiParType) self:new_span(i).dir = v               ; self:unshape() end
terra Layer:set_text_span_line_spacing      (i: int, v: num)            self:new_span(i).line_spacing = v      ; self:unwrap() end
terra Layer:set_text_span_hardline_spacing  (i: int, v: num)            self:new_span(i).hardline_spacing = v  ; self:unwrap() end
terra Layer:set_text_span_paragraph_spacing (i: int, v: num)            self:new_span(i).paragraph_spacing = v ; self:unwrap() end
terra Layer:set_text_span_nowrap            (i: int, v: bool)           self:new_span(i).nowrap = v            ; self:unwrap() end
terra Layer:set_text_span_color             (i: int, v: uint32)         self:new_span(i).color.uint = v end
terra Layer:set_text_span_opacity           (i: int, v: double)         self:new_span(i).opacity = v    end
terra Layer:set_text_span_operator          (i: int, v: int)            self:new_span(i).operator = v   end

local script_buf = global(char[5])
terra Layer:get_text_span_script(i: int)
	hb_tag_to_string(self:span(i).script, [rawstring](&script_buf))
	return [rawstring](&script_buf)
end
terra Layer:set_text_span_script(i: int, s: rawstring)
	var script = hb_script_from_string(s, -1)
	if self:span(i).script ~= script then
		self:new_span(i).script = script
		self:unshape()
	end
end

terra Layer:get_text_span_lang(i: int)
	return hb_language_to_string(self:span(i).lang)
end
terra Layer:set_text_span_lang(i: int, s: rawstring)
	var lang = hb_language_from_string(s, -1)
	if self:span(i).lang ~= lang then
		self:new_span(i).lang = lang
		self:unshape()
	end
end

terra Layer:get_text_align_x() return self.text.align_x end
terra Layer:get_text_align_y() return self.text.align_y end

terra Layer:set_text_align_x(v: enum) self:new_text().align_x = v end
terra Layer:set_text_align_y(v: enum) self:new_text().align_y = v end

terra Layer:get_text_caret_width()       return self.text.caret_width end
terra Layer:get_text_caret_color()       return self.text.caret_color.uint end
terra Layer:get_text_caret_insert_mode() return self.text.caret_insert_mode end
terra Layer:get_text_selectable()        return self.text.selectable end

terra Layer:set_text_caret_width(v: num)        self:new_text().caret_width = v end
terra Layer:set_text_caret_color(v: uint32)     self:new_text().caret_color.uint = v end
terra Layer:set_text_caret_insert_mode(v: bool) self:new_text().caret_insert_mode = v end
terra Layer:set_text_selectable(v: bool)        self:new_text().selectable = v end

terra Layer:get_text_span_font_id(i: int) return self:span(i).font_id end

terra Layer:set_text_span_font_id(span_i: int, font_id: int)
	var font = self.lib.text_renderer.fonts:at(font_id, nil)
	font_id = iif(font ~= nil, font_id, -1)
	var span = self:span(span_i)
	var old_font_id = span.font_id
	if font_id == old_font_id then return end
	var old_font = self.lib.text_renderer.fonts:at(old_font_id, nil)
	if old_font ~= nil then old_font:unref() end
	if font ~= nil then font:ref() end
	self:new_span(span_i).font_id = font_id
	self:unshape()
end

--publish & bulid

function build(self)
	local public = publish'layerlib'

	public(memtotal)
	public(memreport)

	public:getenums(layerlib)

	public(layerlib.new, 'layerlib')

	public(Lib, {

		free_and_dealloc='free',

		font=1,

		window=1,

		dump_stats=1,

		get_font_size_resolution       =1,
		get_subpixel_x_resolution      =1,
		get_word_subpixel_x_resolution =1,
		get_glyph_cache_size           =1,
		get_glyph_run_cache_size       =1,

		set_font_size_resolution       =1,
		set_subpixel_x_resolution      =1,
		set_word_subpixel_x_resolution =1,
		set_glyph_cache_size           =1,
		set_glyph_run_cache_size       =1,

	}, true)

	public(Window, {
		free_and_dealloc='free',
		layer=1,
		get_view=1,
		new_layer=1,
		sync=1,
		draw=1,
	}, true)

	public(Layer, {

		free='free_and_deallocate',

		get_child_count=1,
		get_parent=1,
		child=1,
		get_id=1,
		get_index=1,
		new_child=1,
		move=1,

		--position in hierarchy

		get_parent=1,
		get_index=1,
		layer=1,
		get_layer_count=1,
		layer_insert=1,
		layer_remove=1,
		layer_move=1,
		move=1,

		--size and position

		get_x=1,
		get_y=1,
		get_w=1,
		get_h=1,
		set_x=1,
		set_y=1,
		set_w=1,
		set_h=1,

		get_cx=1,
		get_cy=1,
		get_cw=1,
		get_ch=1,
		set_cx=1,
		set_cy=1,
		set_cw=1,
		set_ch=1,

		get_min_cw=1,
		get_min_ch=1,
		set_min_cw=1,
		set_min_ch=1,

		get_padding_left=1,
		get_padding_top=1,
		get_padding_right=1,
		get_padding_bottom=1,

		set_padding_left=1,
		set_padding_top=1,
		set_padding_right=1,
		set_padding_bottom=1,

		to_parent=1, from_parent=1,
		to_window=1, from_window=1,

		--drawing

		get_visible      =1,
		set_visible      =1,

		get_clip_content =1,
		set_clip_content =1,

		get_snap_x       =1,
		set_snap_x       =1,
		get_snap_y       =1,
		set_snap_y       =1,

		get_opacity      =1,
		set_opacity      =1,

		--borders

		get_border_left   =1,
		get_border_right  =1,
		get_border_top    =1,
		get_border_bottom =1,
		set_border_left   =1,
		set_border_right  =1,
		set_border_top    =1,
		set_border_bottom =1,

		get_corner_radius_top_left     =1,
		get_corner_radius_top_right    =1,
		get_corner_radius_bottom_left  =1,
		get_corner_radius_bottom_right =1,
		get_corner_radius_kappa        =1,
		set_corner_radius_top_left     =1,
		set_corner_radius_top_right    =1,
		set_corner_radius_bottom_left  =1,
		set_corner_radius_bottom_right =1,
		set_corner_radius_kappa        =1,

		get_border_color_left   =1,
		get_border_color_right  =1,
		get_border_color_top    =1,
		get_border_color_bottom =1,
		set_border_color_left   =1,
		set_border_color_right  =1,
		set_border_color_top    =1,
		set_border_color_bottom =1,

		get_border_dash_count=1,
		clear_border_dashes=1,
		get_border_dash=1,
		set_border_dash=1,
		get_border_dash_offset=1,
		set_border_dash_offset=1,

		set_border_line_to=1,

		--backgrounds

		get_background_type=1,
		set_background_type=1,

		get_background_color=1,
		set_background_color=1,

		get_background_gradient_x1=1,
		get_background_gradient_y1=1,
		get_background_gradient_x2=1,
		get_background_gradient_y2=1,

		set_background_gradient_x1=1,
		set_background_gradient_y1=1,
		set_background_gradient_x2=1,
		set_background_gradient_y2=1,

		get_background_gradient_cx1=1,
		get_background_gradient_cy1=1,
		get_background_gradient_cx2=1,
		get_background_gradient_cy2=1,
		get_background_gradient_r1 =1,
		get_background_gradient_r2 =1,

		set_background_gradient_cx1=1,
		set_background_gradient_cy1=1,
		set_background_gradient_cx2=1,
		set_background_gradient_cy2=1,
		set_background_gradient_r1 =1,
		set_background_gradient_r2 =1,

		get_background_gradient_color_stops_count=1,
		clear_background_gradient_color_stops=1,
		get_background_gradient_color_stops_color=1,
		set_background_gradient_color_stops_color=1,
		get_background_gradient_color_stops_offset=1,
		set_background_gradient_color_stops_offset=1,

		get_background_image=1,
		set_background_image=1,

		get_background_hittable    =1,
		get_background_clip_border_offset=1,
		get_background_operator    =1,
		get_background_x           =1,
		get_background_y           =1,
		get_background_rotation    =1,
		get_background_rotation_cx =1,
		get_background_rotation_cy =1,
		get_background_scale       =1,
		get_background_scale_cx    =1,
		get_background_scale_cy    =1,
		get_background_extend      =1,

		set_background_hittable    =1,
		set_background_clip_border_offset=1,
		set_background_operator    =1,
		set_background_x           =1,
		set_background_y           =1,
		set_background_rotation    =1,
		set_background_rotation_cx =1,
		set_background_rotation_cy =1,
		set_background_scale       =1,
		set_background_scale_cx    =1,
		set_background_scale_cy    =1,
		set_background_extend      =1,

		--shadows

		get_shadow_x      =1,
		get_shadow_y      =1,
		get_shadow_color  =1,
		get_shadow_blur   =1,
		get_shadow_passes =1,

		set_shadow_x      =1,
		set_shadow_y      =1,
		set_shadow_color  =1,
		set_shadow_blur   =1,
		set_shadow_passes =1,

		--text

		get_text_utf32=1,
		get_text_utf32_len=1,
		set_text_utf32=1,
		set_text_utf8=1,

		get_text_maxlen=1,
		set_text_maxlen=1,

		get_text_span_count=1,
		clear_text_spans=1,

		get_text_span_feature_count=1,
		clear_text_span_features=1,
		get_text_span_feature=1,
		set_text_span_feature=1,

		get_text_span_offset            =1,
		get_text_span_font_id           =1,
		get_text_span_font_size         =1,
		get_text_span_script            =1,
		get_text_span_lang              =1,
		get_text_span_dir               =1,
		get_text_span_line_spacing      =1,
		get_text_span_hardline_spacing  =1,
		get_text_span_paragraph_spacing =1,
		get_text_span_nowrap            =1,
		get_text_span_color             =1,
		get_text_span_opacity           =1,
		get_text_span_operator          =1,

		set_text_span_offset            =1,
		set_text_span_font_id           =1,
		set_text_span_font_size         =1,
		set_text_span_script            =1,
		set_text_span_lang              =1,
		set_text_span_dir               =1,
		set_text_span_line_spacing      =1,
		set_text_span_hardline_spacing  =1,
		set_text_span_paragraph_spacing =1,
		set_text_span_nowrap            =1,
		set_text_span_color             =1,
		set_text_span_opacity           =1,
		set_text_span_operator          =1,

		get_text_align_x=1,
		get_text_align_y=1,

		set_text_align_x=1,
		set_text_align_y=1,

		get_text_caret_width=1,
		get_text_caret_color=1,
		get_text_caret_insert_mode=1,
		get_text_selectable=1,

		set_text_caret_width=1,
		set_text_caret_color=1,
		set_text_caret_insert_mode=1,
		set_text_selectable=1,

		--layouts

	}, true)

	public:build{
		linkto = {'cairo', 'freetype', 'harfbuzz', 'fribidi', 'unibreak', 'boxblur', 'xxhash'},
	}
end

if not ... then
	print'Compiling...'
	build()
	print(sizeof(Layer), 'sizeof(Layer)')
	print(sizeof(Layer) + sizeof(Transform) + sizeof(Border)
		+ sizeof(Background) + sizeof(Shadow) + sizeof(Text)
		+ max(sizeof(FlexLayout), sizeof(GridLayout)), 'sizeof(FatLayer)')
end
