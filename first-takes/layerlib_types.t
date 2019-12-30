
setfenv(1, require'layerlib_env')

require'cairolib'
require'trlib_paint_cairo'
tr = require'trlib'
require'bitmaplib'
require'boxblurlib'
require'utf8lib'

color = cairo_argb32_color_t
matrix = cairo_matrix_t
pattern = cairo_pattern_t
context = cairo_t
surface = cairo_surface_t
create_surface = cairo_image_surface_create_for_bitmap

ALIGN_DEFAULT       = 0                --only for align_x/y
ALIGN_AUTO          = tr.ALIGN_AUTO    --only for text_align_x
ALIGN_LEFT          = tr.ALIGN_LEFT
ALIGN_RIGHT         = tr.ALIGN_RIGHT
ALIGN_CENTER        = tr.ALIGN_CENTER
ALIGN_TOP           = tr.ALIGN_TOP     --same as ALIGN_LEFT!
ALIGN_BOTTOM        = tr.ALIGN_BOTTOM  --same as ALIGN_RIGHT!
ALIGN_STRETCH       = tr.ALIGN_MAX + 1
ALIGN_START         = tr.ALIGN_MAX + 2 --left for LTR text, right for RTL
ALIGN_END           = tr.ALIGN_MAX + 3 --right for LTR text, left for RTL
ALIGN_SPACE_EVENLY  = tr.ALIGN_MAX + 4
ALIGN_SPACE_AROUND  = tr.ALIGN_MAX + 5
ALIGN_SPACE_BETWEEN = tr.ALIGN_MAX + 6
ALIGN_BASELINE      = tr.ALIGN_MAX + 7

local function map_enum(src_prefix, dst_prefix)
	for k,v in pairs(C) do
		local op = k:match('^'..src_prefix..'(.*)')
		if op then layerlib[dst_prefix..op] = v end
	end
end
map_enum('CAIRO_OPERATOR_', 'OPERATOR_')
map_enum('CAIRO_EXTEND_', 'BACKGROUND_EXTEND_')

Bitmap = bitmap.Bitmap

terra Bitmap:surface()
	return create_surface(self)
end

struct BoolBitmap {
	rows: int;
	cols: int;
	bits: arr(bool);
}

terra BoolBitmap:init()
	self.rows = 0
	self.cols = 0
	self.bits:init()
end

terra BoolBitmap:free()
	self.bits:free()
end

struct Lib;
struct Window;
struct Layer;

struct Transform {
	rotation: num;
	rotation_cx: num;
	rotation_cy: num;
	scale: num;
	scale_cx: num;
	scale_cy: num;
}

terra Transform:init()
	fill(self)
	self.scale = 1
end

terra Transform:apply(m: &matrix)
	if self.rotation ~= 0 then
		m:rotate_around(self.rotation_cx, self.rotation_cy, rad(self.rotation))
	end
	if self.scale ~= 1 then
		m:scale_around(self.scale_cx, self.scale_cy, self.scale, self.scale)
	end
end

BorderLineToFunc = {&Layer, &context, num, num, num} -> {}
BorderLineToFunc.__typename_ffi = 'BorderLineToFunc'

struct Border (gettersandsetters) {
	left   : num;
	right  : num;
	top    : num;
	bottom : num;

	corner_radius_top_left     : num;
	corner_radius_top_right    : num;
	corner_radius_bottom_left  : num;
	corner_radius_bottom_right : num;
	--draw rounded corners with a modified bezier for smoother line-to-arc
	--transitions. kappa=1 uses circle arcs instead.
	corner_radius_kappa: num;

	color_left   : color;
	color_right  : color;
	color_top    : color;
	color_bottom : color;

	dash: arr(double);
	dash_offset: int;

	offset: num;

	line_to: BorderLineToFunc;
}

terra Border:init()
	fill(self)
	self.corner_radius_kappa = 1.2
	self.offset = -1 --inner border
end

terra Border:free()
	self.dash:free()
end

struct ColorStop {
	offset: num;
	color: color;
}

ColorStop.empty = `ColorStop{0, 0}

struct LinearGradientPoints {
	x1: num; y1: num;
	x2: num; y2: num;
}

struct RadialGradientCircles {
	cx1: num; cy1: num; r1: num;
	cx2: num; cy2: num; r2: num;
}

BACKGROUND_TYPE_NONE            = 0
BACKGROUND_TYPE_COLOR           = 1
BACKGROUND_TYPE_LINEAR_GRADIENT = 2
BACKGROUND_TYPE_RADIAL_GRADIENT = 3
BACKGROUND_TYPE_GRADIENT        = 3 --mask for LINEAR|RADIAL
BACKGROUND_TYPE_IMAGE           = 4

struct BackgroundGradient {
	color_stops: arr(ColorStop);
	union {
		points: LinearGradientPoints;
		circles: RadialGradientCircles;
	}
}

terra BackgroundGradient:free()
	self.color_stops:free()
end

struct BackgroundPattern {
	x: num;
	y: num;
	union {
		gradient: BackgroundGradient;
		bitmap: Bitmap;
	};
	pattern: &pattern;
	transform_id: int;
	extend: enum; --BACKGROUND_EXTEND_*
}

terra BackgroundPattern.methods.free :: {&BackgroundPattern, enum, &Lib} -> {}

struct Background (gettersandsetters) {
	type: enum; --BACKGROUND_TYPE_*
	hittable: bool;
	operator: enum; --OPERATOR_*
	-- overlapping between background clipping edge and border stroke.
	-- -1..1 goes from inside to outside of border edge.
	clip_border_offset: num;
	union {
		color: color;
		pattern: BackgroundPattern;
	};
}

terra Background.methods.init :: {&Background} -> {}
terra Background.methods.free :: {&Background, &Lib} -> {}

struct ShadowState {
	blur: Blur;
	blurred_surface: &surface;
	x: num; y: num;
}

struct Shadow {
	x: num;
	y: num;
	color: color;
	blur: uint8;
	passes: uint8;
	_state: ShadowState;
}

terra Shadow.methods.init :: {&Shadow, &Layer} -> {}
terra Shadow.methods.free :: {&Shadow} -> {}

struct Text {
	layout: tr.Layout;
	align_x: enum; --ALIGN_*
	align_y: enum; --ALIGN_*
	shaped: bool;
	wrapped: bool;
	caret_width: num;
	caret_color: color;
	caret_insert_mode: bool;
	selectable: bool;
	selection: tr.Selection;
}

terra Text.methods.init :: {&Text, &tr.Renderer} -> {}
terra Text.methods.free :: {&Text} -> {}

struct LayoutSolver {
	type       : enum; --LAYOUT_*
	axis_order : enum; --AXIS_ORDER_*
	init       : {&Layer} -> {};
	free       : {&Layer} -> {};
	sync       : {&Layer} -> {};
	sync_min_w : {&Layer, bool} -> num;
	sync_min_h : {&Layer, bool} -> num;
	sync_x     : {&Layer, bool} -> bool;
	sync_y     : {&Layer, bool} -> bool;
	sync_top   : {&Layer, num, num} -> bool;
}

FLEX_FLOW_X = 0
FLEX_FLOW_Y = 1

struct FlexLayout {
	--common to flex & grid
	align_items_x: enum;  --ALIGN_*
	align_items_y: enum;  --ALIGN_*
 	item_align_x: enum;   --ALIGN_*
	item_align_y: enum;   --ALIGN_*

	flow: enum; --FLEX_FLOW_*
	wrap: bool;
}

terra FlexLayout:init()
	fill(self)
	self.align_items_x = ALIGN_STRETCH
	self.align_items_y = ALIGN_STRETCH
 	self.item_align_x  = ALIGN_STRETCH
	self.item_align_y  = ALIGN_STRETCH
	self.wrap = false
end

struct GridLayoutCol {
	x: num;
	w: num;
	fr: num;
	align_x: enum;
	_min_w: num;
	snap_x: bool;
	inlayout: bool;
}

struct GridLayout {
	--common to flex & grid
	align_items_x: enum;  --ALIGN_*
	align_items_y: enum;  --ALIGN_*
 	item_align_x: enum;   --ALIGN_*
	item_align_y: enum;   --ALIGN_*

	cols: arr(num);
	rows: arr(num);
	col_gap: num;
	row_gap: num;
	flow: enum; --GRID_FLOW_* mask
	wrap: int;
	min_lines: int;

	--computed by the auto-positioning algorithm.
	_flip_rows: bool;
	_flip_cols: bool;
	_max_row: int;
	_max_col: int;
	_cols: arr(GridLayoutCol);
	_rows: arr(GridLayoutCol);
}

terra GridLayout:init()
	fill(self)
	self.align_items_x = ALIGN_STRETCH
	self.align_items_y = ALIGN_STRETCH
 	self.item_align_x  = ALIGN_STRETCH
	self.item_align_y  = ALIGN_STRETCH
end

terra GridLayout:free()
	self.cols:free()
	self.rows:free()
	self._cols:free()
	self._rows:free()
end

struct Lib (gettersandsetters) {
	text_renderer: tr.Renderer;
	grid_occupied: BoolBitmap;

	windows     : freelist(Window);
	transforms  : arrayfreelist(Transform);
	borders     : arrayfreelist(Border);
	backgrounds : arrayfreelist(Background, nil, &Lib);
	shadows     : arrayfreelist(Shadow);
	texts       : arrayfreelist(Text);
	flexs       : arrayfreelist(FlexLayout);
	grids       : arrayfreelist(GridLayout);

	default_text_span: tr.Span;
}

struct Window (gettersandsetters) {
	lib: &Lib;
	layers: arrayfreelist(Layer);
}

terra Window.methods.init :: {&Window, &Lib} -> {}
terra Window.methods.free :: {&Window} -> {}

CLIP_CONTENT_NOCLIP        = 0
CLIP_CONTENT_TO_PADDING    = 1
CLIP_CONTENT_TO_BACKGROUND = 1

struct Layer (gettersandsetters) {

	lib: &Lib;
	window: &Window;
	parent_id: int;
	child_ids: arr(int);

	x: num;
	y: num;
	_w: num;
	_h: num;

	visible         : bool;
	clip_content    : enum; --CLIP_CONTENT_*
	snap_x          : bool;
	snap_y          : bool;

	opacity: num;

	padding_left   : num;
	padding_right  : num;
	padding_top    : num;
	padding_bottom : num;

	transform_id  : int;
	border_id     : int;
	background_id : int;
	shadow_id     : int;
	text_id       : int;

	--layouting ---------------------------------------------------------------

	layout_solver: &LayoutSolver;

	--flex layouts
	union {
		flex_id: int;
		grid_id: int;
	}

	--child of flex layouts
	_min_w: num;
	_min_h: num;
	min_cw: num;
	min_ch: num;
	align_x: enum; --ALIGN_*
	align_y: enum; --ALIGN_*

	--child of flex layout
	fr: num;
	break_before: bool;
	break_after : bool;

	--child of grid layout
	grid_row: int;
	grid_col: int;
	grid_row_span: int;
	grid_col_span: int;
	--computed by the auto-positioning algorithm.
	_grid_row: int;
	_grid_col: int;
	_grid_row_span: int;
	_grid_col_span: int;

}

terra Layer.methods.init :: {&Layer, &Window} -> {}
terra Layer.methods.free :: {&Layer} -> {}

local function managed_prop(T, PROP, init, free)
	local PROP_ID = PROP..'_id'
	local FREELIST = PROP..'s'
	init = init or macro(function(self) return quote self:init() end end)
	free = free or macro(function(self) return quote self:free() end end)
	T.methods['get_'..PROP] = macro(function(self)
		return `self.lib.[FREELIST]:at(self.[PROP_ID])
	end)
	T.methods['new_'..PROP] = macro(function(self)
		return quote
			var freelist = &self.lib.[FREELIST]
			var obj = freelist:at(self.[PROP_ID])
			if self.[PROP_ID] == 0 then
				var obj, id = freelist:alloc()
				init(obj, self)
				self.[PROP_ID] = id
			end
			in obj
		end
	end)
	T.methods['free_'..PROP] = macro(function(self)
		return quote
			if self.[PROP_ID] ~= 0 then
				self.lib.[FREELIST]:release(self.[PROP_ID])
				self.[PROP_ID] = 0
			end
		end
	end)
end
managed_prop(Layer, 'transform'  )
managed_prop(Layer, 'border'     )
managed_prop(Layer, 'background' )
managed_prop(Layer, 'shadow', macro(function(self, layer)
	return quote self:init(&layer) end
end))
managed_prop(Layer, 'text', macro(function(self, layer)
	return quote self:init(&layer.lib.text_renderer) end
end))
managed_prop(Layer, 'flex'       )
managed_prop(Layer, 'grid'       )

--utils ----------------------------------------------------------------------

terra snapx(x: num, enable: bool)
	return iif(enable, floor(x + .5), x)
end

terra snap_xw(x: num, w: num, enable: bool)
	if not enable then return x, w end
	var x1 = floor(x + .5)
	var x2 = floor(x + w + .5)
	return x1, x2 - x1
end

--offset a rectangle by d (outward if d is positive)
terra box2d_offset(d: num, x: num, y: num, w: num, h: num)
	return x - d, y - d, w + 2*d, h + 2*d
end

return layerlib
