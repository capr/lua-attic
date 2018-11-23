--[[
layer.align = 'center middle'
layer.halign = nil --horizontal override
layer.valign = nil --vertical override

layer:stored_property'align'
layer:nochange_barrier'align'
function layer:after_set_align(s)
	local t = self.ui:_align(s)
	self._align_h = t[1]
	self._align_v = t[2]
end
layer:instance_only'align'

layer:stored_property'halign'
function layer:set_halign(h)
	self._halign = h and self.ui:check(haligns[h], 'invalid halign: "%s"', h)
end
layer:instance_only'halign'

layer:stored_property'valign'
function layer:set_valign(v)
	self._valign = v and self.ui:check(valigns[v], 'invalid valign: "%s"', v)
end
layer:instance_only'valign'

function layer:aligns()
	return
		self._halign or self._align_h,
		self._valign or self._align_v
end

function layer:sync_aligns()
	local ha, va = self:aligns()
	local va = va == 'middle' and 'center' or va
	if self.parent then
		self.x, self.y = box2d.align(self.w, self.h, ha, va,
			self.parent:client_rect())
	end
end
]]

--[[
function layer.sync_layout:textwrap()
	local segs = self:sync_text_segments()
	if segs then
		self.cw = clamp(self.max_cw, self.min_cw, 1e6) - self.pw
		self.ch = clamp(self.max_ch, self.min_ch, 1e6) - self.ph
		self:sync_text_layout()
		local _, _, w, h = segs:bounding_box()
		self.cw = math.max(w, self.min_cw - self.pw)
		self.ch = math.max(h, self.min_ch - self.ph)
		local ha, va = self:text_aligns()
		if ha == 'right' then
			segs.lines.x = -segs.lines.w + self.cw
		elseif ha == 'center' then
			segs.lines.x = (-segs.lines.w + self.cw) / 2
		end
		if va == 'bottom' then
			segs.lines.y = -segs.lines.h + self.ch
		elseif va == 'middle' then
			segs.lines.y = (-segs.lines.h + self.ch) / 2
		end
	else
		self.cw = 0
		self.ch = 0
	end
end
]]

