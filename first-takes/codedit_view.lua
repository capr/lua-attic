
--measuring, layouting, rendering and hit testing
--Written By Cosmin Apreutesei. Public Domain.

--features: proportional fonts, auto-wrapping, line margins, scrolling.

--[[

...................................
:client :m1 :m2 :                 :  view rect (*):     x, y, w, h (contains the clipped margins and the scrollbox)
:rect   :   :   :                 :  scrollbox rect:    x + margins_w, y, w - margins_w, h
:       :___:___:______________   :  clip rect:         clip_x, clip_y, clip_w, clip_h (from drawing the scrollbox)
:       |(*)|   |clip       | |   :  client rect:       clip_x + scroll_x, clip_y + scroll_y, client_size()
:       |   |   |rect       | |   :  margin1 rect:      x, client_y, m1:get_width(), client_h
:       |   |   |           |#|   :  margin1 clip rect: m1_x, clip_y, m1_w, clip_h
:       |   |   |           |#|   :
:       |   |   |           |#|   :
:       |   |   |           |#|   :
:       |   |   |           | |   :
:       |___|___|___________|_|   :
:       :   :   |_____####__|     :
:       :   :   :                 :
:       :   :   :                 :
...................................

]]

if not ... then require'codedit_demo'; return end

local glue = require'glue'
local str = require'codedit_str'
local tabs = require'codedit_tabs'
local hl = require'codedit_hl'

local view = {
	--tab expansion
	tabsize = 3,
	tabstop_margin = 1, --min. space in pixels between tab-separated chunks
	--font metrics
	line_h = 16,
	char_w = 8,
	char_baseline = 13,
	--cursor metrics
	cursor_xoffset = -1,     --cursor x offset from a char's left corner
	cursor_xoffset_col1 = 0, --cursor x offset for the first column
	cursor_thickness = 2,
	--scrolling
	cursor_margins = {top = 16, left = 0, right = 0, bottom = 16},
	--rendering
	highlight_cursor_lines = true,
	lang = nil, --optional lexer to use for syntax highlighting
	--reflowing
	line_width = 72,
}

--lifetime

function view:new(buffer)
	self = glue.inherit({
		buffer = buffer,
	}, self)
	--objects to render
	self.selections = {} --{selections = true, ...}
	self.cursors = {} --{cursor = true, ...}
	self.margins = {} --{margin1, ...}
	--state
	self.scroll_x = 0 --client rect position relative to the clip rect
	self.scroll_y = 0
	self.last_valid_line = 0 --for incremental lexing
	return self
end

--adding objects to render

function view:add_selection(sel) self.selections[sel] = true end
function view:add_cursor(cur) self.cursors[cur] = true end
function view:add_margin(margin, pos)
	table.insert(self.margins, pos or #self.margins + 1, margin)
end

--state management

function view:invalidate(line)
	if line then
		self.last_valid_line = math.min(self.last_valid_line, line - 1)
	end
end

local function update_state(dst, src)
	dst.scroll_x = src.scroll_x
	dst.scroll_y = src.scroll_y
end

function view:save_state(state)
	update_state(state, self)
end

function view:load_state(state)
	update_state(self, state)
	self:invalidate()
end

--utils

local function clamp(x, a, b)
	return math.min(math.max(x, a), b)
end

local function point_in_rect(x, y, x1, y1, w1, h1)
	return x >= x1 and x <= x1 + w1 and y >= y1 and y <= y1 + h1
end

--tabstop metrics ------------------------------------------------------------

function view:font_changed()
	--stub
end

--pixel width of n space characters
function view:space_width(n)
	return self:char_advance_x(' ', 1) * n
end

--pixel width of a full tabstop
function view:tabstop_width()
	return self:space_width(self.tabsize)
end

--x coord of the first tabstop to the right of x0
function view:next_tabstop_x(x0)
	local w = self:tabstop_width()
	return math.ceil((x0 + self.tabstop_margin) / w) * w
end

--x coord of the first tabstop to the left of x0
function view:prev_tabstop_x(x0)
	local w = self:tabstop_width()
	return math.floor((x0 - self.tabstop_margin) / w) * w
end

--text positioning -----------------------------------------------------------

--x-advance of the grapheme cluster at s[i]
function view:char_advance_x(s, i)
	return self.char_w
end

--x coord of the grapheme cluster following the one at s[i] which is at x
function view:next_x(x, s, i)
	if str.istab(s, i) then
		return self:next_tabstop_x(x)
	else
		return x + self:char_advance_x(s, i)
	end
end

--x coord of the grapheme cluster at line,i
function view:char_x(line, i)
	assert(i >= 1)
	assert(line >= 1)
	local x = 0
	for i1, s in self.buffer:chars(line) do
		if i == i1 then break end
		x = self:next_x(x, s, i1)
	end
	return x
end

function view:line_y(line)
	assert(line >= 1)
	return self.line_h * (line - 1)
end

function view:char_y(line, i)
	return self:line_y(line)
end

function view:char_coords(line, i)
	local y = self:char_y(line, i)
	local x = self:char_x(line, i)
	return x, y
end

--text hit testing -----------------------------------------------------------

function view:line_at(y)
	return math.max(1, math.floor(y / self.line_h) + 1)
end

function view:char_at_line(line, x, closest)
	local xi, x0, i0 = 0, 0, 1
	for i, s in self.buffer:chars(line) do
		if xi > x then
			if closest then --char starting closest to x
				if x - x0 < xi - x then
					return i0
				else
					return i
				end
			else
				return i0 --char hitting x
			end
		end
		x0 = xi
		xi = self:next_x(xi, s, i)
		i0 = i
	end
	if xi > x then --check eol's x too
		if closest then
			if x - x0 < xi - x and i0 then
				return i0
			end
		else
			return i0 --char hitting x
		end
	end
	return self.buffer:eol(line)
end

function view:char_at(x, y, closest)
	local line = self:line_at(y)
	return line, self:char_at_line(line, x, closest)
end

--cursor positioning & shape -------------------------------------------------

function view:cursor_y(cursor)
	return self:char_y(cursor.line, cursor.i)
end

function view:cursor_xw(cursor)
	if cursor.line > #self.buffer.lines then
		local x = self:space_width(cursor.i - 1)
		local w = self:space_width(1)
		return x, w
	end
	local x = self:char_x(cursor.line, cursor.i)
	local eol = self.buffer:eol(cursor.line)
	local extra_spaces = cursor.i - eol
	if extra_spaces > 0 then
		x = x + self:space_width(extra_spaces)
	end
	local w
	if extra_spaces >= 0 then
		w = self:space_width(1)
	else
		local _, i2 = cursor:next_pos(false, cursor.jump_tabstops)
		local x2 = self:char_coords(cursor.line, i2)
		w = x2 - x
	end
	return x, w
end

function view:cursor_coords(cursor)
	local y = self:cursor_y(cursor)
	local x, w = self:cursor_xw(cursor)
	return x, y, w
end

function view:_cursor_rect_insert_mode(cursor)
	local x, y = self:cursor_coords(cursor)
	local w = cursor.thickness or self.cursor_thickness
	local h = self.line_h
	x = x + (cursor.i == 1 and self.cursor_xoffset_col1 or self.cursor_xoffset)
	return x, y, w, h
end

function view:_cursor_rect_overwrite_mode(cursor)
	local x, y, w = self:cursor_coords(cursor)
	local h = cursor.thickness or self.cursor_thickness
	y = y + self.char_baseline + 1 --1 pixel under the baseline
	return x, y, w, h
end

function view:cursor_rect(cursor)
	if cursor.insert_mode then
		return self:_cursor_rect_insert_mode(cursor)
	else
		return self:_cursor_rect_overwrite_mode(cursor)
	end
end

--cursor hit testing ---------------------------------------------------------

function view:_space_chars(w)
	return math.floor(w / self:space_width(1) + 0.5)
end

function view:cursor_char_at_line(line, x, restrict_eof)
	if line > #self.buffer.lines then --outside buffer
		if not restrict_eof then
			return self:_space_chars(x) + 1
		else
			line = #self.buffer.lines
		end
	end
	local i = self:char_at_line(line, x, true)
	if i == self.buffer:eol(line) then --possibly outside line
		local w = x - self:char_x(line, i) --outside width
		if w > 0 then
			i = i + self:_space_chars(w)
		end
	end
	return i
end

function view:cursor_char_at(x, y, restrict_eof)
	local line = self:line_at(y)
	return line, self:cursor_char_at_line(line, x, restrict_eof)
end

--selection positioning & shape ----------------------------------------------

--rectangle surrounding a block of text
function view:char_rect(line, i1, i2)
	local x1, y = self:char_coords(line, i1)
	local x2, y = self:char_coords(line, i2)
	return x1, y, x2 - x1, self.line_h
end

function view:selection_line_rect(sel, line)
	local i1, i2 = sel:chars(line)
	local x, y, w, h = self:char_rect(line, i1, i2)
	if not sel.block and line < (sel:isforward() and sel.line2 or sel.line1) then
		w = w + self:space_width(0.5) --show eol as half space
	end
	return x, y, w, h, i1, i2
end

--selection hit testing ------------------------------------------------------

function view:selection_hit_test(sel, x, y)
	if not sel.visible or sel:isempty() or not point_in_rect(x, y, self:clip_rect()) then
		return false
	end
	x, y = self:screen_to_client(x, y)
	local line1, line2 = sel:line_range()
	for line = line1, line2 do
		if point_in_rect(x, y, self:selection_line_rect(sel, line)) then
			return true
		end
	end
	return false
end

--text size ------------------------------------------------------------------

function view:line_width(line)
	return self:char_x(line, 1/0)
end

function view:max_line_width()
	local w = 0
	for line = 1, #self.buffer.lines do
		w = math.max(w, self:line_width(line))
	end
	return w
end

--size of the text space (i.e. client rectangle) as limited by the available
--text and any outside-of-text cursors.
function view:client_size()
	local maxline = #self.buffer.lines
	local maxw = self:max_line_width()
	--unrestricted cursors can enlarge the client area
	for cur in pairs(self.cursors) do
		maxline = math.max(maxline, cur.line)
		if not cur.restrict_eol then
			local x, w = self:cursor_xw(cur)
			maxw = math.max(maxw, x + w)
		end
	end
	return maxw, self:line_y(maxline + 1)
end

--margin metrics -------------------------------------------------------------

--width of all margins combined
function view:margins_width()
	local w = 0
	for _,m in ipairs(self.margins) do
		w = w + m:get_width()
	end
	return w
end

--x coord of a margin in screen space
function view:margin_x(target_margin)
	local x = self.x
	for _,margin in ipairs(self.margins) do
		if margin == target_margin then
			return x
		end
		x = x + margin:get_width()
	end
end

--clipping and scrolling -----------------------------------------------------

function view:screen_to_client(x, y)
	x = x - self.clip_x - self.scroll_x
	y = y - self.clip_y - self.scroll_y
	return x, y
end

function view:client_to_screen(x, y)
	x = x + self.clip_x + self.scroll_x
	y = y + self.clip_y + self.scroll_y
	return x, y
end

--clip rect of the client area in screen space, obtained from drawing the scrollbox.
function view:clip_rect()
	return self.clip_x, self.clip_y, self.clip_w, self.clip_h
end

--clip rect of a margin area in screen space
function view:margin_clip_rect(margin)
	local clip_x = self:margin_x(margin)
	local clip_w = margin:get_width()
	return clip_x, self.clip_y, clip_w, self.clip_h
end

--clip rect of a line in screen space
function view:line_clip_rect(line)
	local y = self:line_y(line)
	local _, y = self:client_to_screen(0, y)
	return self.clip_x, y, self.clip_w, self.line_h
end

--clipping in text space

--which lines are partially or entirely visibile
function view:visible_lines()
	local line1 = math.floor(-self.scroll_y / self.line_h) + 1
	local line2 = math.ceil((-self.scroll_y + self.clip_h) / self.line_h)
	line1 = self.buffer:clamp_pos(line1, 1)
	line2 = self.buffer:clamp_pos(line2, 1)
	return line1, line2
end

--point translation from screen space to client (text) space and back

function view:screen_to_margin_client(margin, x, y)
	x = x - self:margin_x(margin)
	y = y - self.clip_y - self.scroll_y
	return x, y
end

function view:margin_client_to_screen(margin, x, y)
	x = x + self:margin_x(margin)
	y = y + self.clip_y + self.scroll_y
	return x, y
end

--hit testing

function view:margin_hit_test(margin, x, y)
	if not point_in_rect(x, y, self:margin_clip_rect(margin)) then
		return false
	end
	x, y = self:screen_to_margin_client(margin, x, y)
	return true, self:char_at(x, y)
end

function view:client_hit_test(x, y)
	return point_in_rect(x, y, self:clip_rect())
end

--scrolling, i.e. adjusting the position of the client rectangle relative to
--the clipping rectangle.

--how many lines are in the clipping rect
function view:pagesize()
	return math.floor(self.clip_h / self.line_h + 0.5)
end

function view:scroll_by(x, y)
	self.scroll_x = self.scroll_x + x
	self.scroll_y = self.scroll_y + y
end

function view:scroll_up()
	self:scroll_by(0, self.line_h)
end

function view:scroll_down()
	self:scroll_by(0, -self.line_h)
end

--scroll to make a specific rectangle visible
function view:make_rect_visible(x, y, w, h)
	self.scroll_x = -clamp(-self.scroll_x, x + w - self.clip_w, x)
	self.scroll_y = -clamp(-self.scroll_y, y + h - self.clip_h, y)
end

--scroll to make the char under cursor visible
function view:cursor_make_visible(cur)
	local x, y, w, h = self:char_rect(cur.line, cur.i, cur.i)
	--enlarge the char rectangle with the cursor margins
	x = x - self.cursor_margins.left
	y = y - self.cursor_margins.top
	w = w + self.cursor_margins.right  + self.cursor_margins.left
	h = h + self.cursor_margins.bottom + self.cursor_margins.top
	self:make_rect_visible(x, y, w, h)
end

--rendering ------------------------------------------------------------------

--rendering stubs: all rendering is based on these functions

function view:draw_char(x, y, s, i, color) error'stub' end
function view:draw_rect(x, y, w, h, color) error'stub' end
function view:clip(x, y, w, h) error'stub' end

function view:draw_string(cx, cy, s, color, i, j)
	cy = cy + self.char_baseline
	local x = 0
	for i in str.chars(s, i) do
		if j and i >= j then
			break
		end
		if not str.iswhitespace(s, i) then
			self:draw_char(cx + x, cy, s, i, color)
		end
		x = x + self:next_x(x, s, i)
	end
end

function view:draw_buffer(cx, cy, line1, i1, line2, i2, color)

	--clamp the text rectangle to the visible rectangle
	local minline, maxline = self:visible_lines()
	line1 = clamp(line1, minline, maxline+1)
	line2 = clamp(line2, minline-1, maxline)

	local _i1, _i2 = i1, i2
	for line = line1, line2 do
		i1, i2 = _i1, _i2
		if line ~= line1 and line ~= line2 then
			i1, i2 = 1, 1/0
		end
		local y = self:line_y(line)
		local x = 0
		for i, s in self.buffer:chars(line) do
			if i >= i1 and i <= i2 then
				if not str.iswhitespace(s, i) then
					self:draw_char(cx + x, cy + y + self.char_baseline, s, i, color)
				end
			end
			x = self:next_x(x, s, i)
		end
	end
end

function view:draw_buffer_highlighted(cx, cy)

	local minline, maxline = self:visible_lines()

	self.tokens, self.last_valid_line, self.start_tokens =
		hl.relex(maxline, self.tokens, self.last_valid_line, self.buffer,
					self.lang, self.start_tokens)

	local last_line, last_p1, last_vcol

	for i, line, p1, p2, style in hl.tokens(self.tokens, 1, 1, self.buffer) do

		if line > maxline then
			break
		end

		if line >= minline then
			if not style:match'whitespace$' then

				if line ~= last_line then
					last_p1, last_vcol = nil
				end

				local s = self.buffer:select(line)
				local vcol = visual_col_bi(s, p1, self.tabsize, last_p1, last_vcol)
				local x, y = self:char_coords(line, vcol)
				self:draw_string(cx + x, cy + y, s, style, p1, p2)

				last_line, last_p1, last_vcol = line, p1, vcol
			end
		end
	end
end

function view:draw_visible_text(cx, cy)
	if self.lang then
		self:draw_buffer_highlighted(cx, cy)
	else
		local color = self.buffer.text_color or 'text'
		self:draw_buffer(cx, cy, 1, 1, 1/0, 1/0, color)
	end
end

function view:draw_selection(sel, cx, cy)
	if not sel.visible then return end
	if sel:isempty() then return end
	local bg_color = sel.background_color or 'selection_background'
	local text_color = sel.text_color or 'selection_text'
	local line1, line2 = sel:line_range()
	for line = line1, line2 do
		local x, y, w, h, i1, i2 = self:selection_line_rect(sel, line)
		self:draw_rect(cx + x, cy + y, w, h, bg_color)
		self:draw_buffer(cx, cy, line, i1, line, i2 - 1, text_color)
	end
end

function view:draw_cursor(cursor, cx, cy)
	if not (cursor.visible and cursor.on) then return end
	local x, y, w, h = self:cursor_rect(cursor)
	local color = cursor.color or 'cursor'
	self:draw_rect(cx + x, cy + y, w, h, color)
end

function view:draw_margin_line(margin, line, cx, cy, cw, ch, highlighted)
	local x, y = self:char_coords(line, 1)
	margin:draw_line(line, cx + x, cy + y, cw, ch, highlighted)
end

function view:draw_margin(margin)
	local clip_x, clip_y, clip_w, clip_h = self:margin_clip_rect(margin)
	self:clip(clip_x, clip_y, clip_w, clip_h)
	--background
	local color = margin.background_color or 'margin_background'
	self:draw_rect(clip_x, clip_y, clip_w, clip_h, color)
	--contents
	local cx, cy = self:margin_client_to_screen(margin, 0, 0)
	local cw = margin:get_width()
	local ch = self.line_h
	local minline, maxline = self:visible_lines()
	for line = minline, maxline do
		self:draw_margin_line(margin, line, cx, cy, cw, ch)
	end
	--highlighted lines
	if self.highlight_cursor_lines then
		for cursor in pairs(self.cursors) do
			self:draw_margin_line(margin, cursor.line, cx, cy, cw, ch, true)
		end
	end
end

function view:draw_line_highlight(line, color)
	local x, y, w, h = self:line_clip_rect(line)
	color = color or self.buffer.line_highlight_color or 'line_highlight'
	self:draw_rect(x, y, w, h, color)
end

function view:draw_client()
	self:clip(self:clip_rect())
	--background
	local color = self.buffer.background_color or 'background'
	self:draw_rect(self.clip_x, self.clip_y, self.clip_w, self.clip_h, color)
	--highlighting the line under cursor
	for cur in pairs(self.cursors) do
		self:draw_line_highlight(cur.line, cur.line_highlight_color)
	end
	--tabstops
	local x0 = 0
	while x0 < self.clip_w do
		x0 = self:next_tabstop_x(x0)
		self:draw_rect(self.clip_x + x0, 0, 1, 1000, 'tabstop')
	end
	--text
	local cx, cy = self:client_to_screen(0, 0)
	self:draw_visible_text(cx, cy)
	--selections
	for sel in pairs(self.selections) do
		self:draw_selection(sel, cx, cy)
	end
	--cursors
	for cur in pairs(self.cursors) do
		self:draw_cursor(cur, cx, cy)
	end
end

--draw a scrollbox widget with the outside rect (x, y, w, h) and the client
--rect (cx, cy, cw, ch). return the new cx, cy, adjusted from user input
--and other scrollbox constraints, followed by the clipping rect.
--the client rect is relative to the clipping rect of the scrollbox (which
--can be different than it's outside rect). this stub implementation is
--equivalent to a scrollbox that takes no user input, has no margins, and has
--invisible scrollbars.
function view:draw_scrollbox(x, y, w, h, cx, cy, cw, ch)
	return cx, cy, x, y, w, h
end

function view:render()

	local client_w, client_h = self:client_size()
	local margins_w = self:margins_width()

	self.scroll_x, self.scroll_y, self.clip_x, self.clip_y, self.clip_w, self.clip_h =
		self:draw_scrollbox(
			self.x + margins_w,
			self.y,
			self.w - margins_w,
			self.h,
			self.scroll_x, self.scroll_y, client_w, client_h)

	for i,margin in ipairs(self.margins) do
		self:draw_margin(margin)
	end
	self:draw_client()
end

return view
