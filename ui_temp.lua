
	local n = #self
	local horizontal = self.flex_flow == 'h'
	local justify = self.justify_content
	local align_items = self.align_items
	local align_lines = self.align_content

	--the algorithm assumes horizontal main-axis so we use these indirections
	--to make it work for vertical main-axis without duplicating code.
	local X, Y, W, H, CW, CH
	local LEFT, RIGHT, CENTER
	local TOP, BOTTOM, MIDDLE
	if horizontal then
		X, Y, W, H, CW, CH = 'x', 'y', 'w', 'h', 'cw', 'ch'
		LEFT, RIGHT, CENTER = 'left', 'right', 'center'
		TOP, BOTTOM, MIDDLE = 'top', 'bottom', 'middle'
	else
		X, Y, W, H, CW, CH = 'y', 'x', 'h', 'w', 'ch', 'cw'
		LEFT, RIGHT, CENTER = 'top', 'bottom', 'middle'
		TOP, BOTTOM, MIDDLE = 'left', 'right', 'center'
	end

	local container_w = self[CW]
	local container_h = self[CH]

	--flex the children if not wrapping.
	if not self.wrap and align_items == 'stretch' then
		for _,layer in ipairs(self) do
			if layer.visible then
				--layer.flex_w
			end
		end
	end

	--first pass thorugh all items: perform line wrapping but only for
	--computing vertical content metrics so we can align the lines.
	local line_count = 0
	local content_h = 0
	local line1_baseline = 0
	do
		local max_line_w = self.flex_wrap and container_w or 1/0
		local line_w = 0
		local line_h = 0
		for i = 1, n do
			local layer = self[i]
			layer:sync()
			if layer.visible then
				local item_w = layer[W]
				local item_h = layer[H]
				if line_w + item_w > max_line_w then
					line_count = line_count + 1
					content_h = content_h + line_h
					line_w = 0
					line_h = 0
				end
				line_w = line_w + item_w
				line_h = math.max(line_h, item_h)
				if line_count == 0 then
					line1_baseline = math.max(line1_baseline, layer.baseline)
				end
			end
		end
		line_count = line_count + 1
		content_h = content_h + line_h
	end

	--enlarge the container if necessary to contain all the lines.
	container_h = math.max(container_h, content_h)

	--compute vertical alignment metrics.
	local content_y = 0
	local line_spacing = 0
	local fixed_line_h
	do
		if align_lines == 'flex_end' or align_lines == BOTTOM then
			content_y = container_h - content_h
		elseif align_lines == 'center' or align_lines == MIDDLE then
			content_y = (container_h - content_h) / 2
		elseif align_lines == 'space_between' then
			line_spacing = (container_h - content_h) / (line_count - 1)
		elseif align_lines == 'space_around' then
			line_spacing = (container_h - content_h) / (line_count + 1)
			content_y = line_spacing
		elseif align_lines == 'stretch' then
			content_h = container_h
			fixed_line_h = container_h / line_count
		end
	end

	--third pass through all items: perform line wrapping once again, this
	--time laying out all the items. for each line, we do two passes,
	--one for computing line horizontal metrics, one for actual positioning.
	local line_i = 1
	local line_w = 0
	local line_h = 0
	local line_y = content_y
	for i = 1, n + 1 do
		local wrap, next_line_w0, next_line_h0
		if i <= n then
			local layer = self[i]
			if layer.visible then
				local item_w = layer[W]
				local item_h = layer[H]
				if line_w + item_w > container_w then
					next_line_w0 = item_w
					next_line_h0 = item_h
					wrap = true
				else
					line_w = line_w + item_w
					line_h = math.max(line_h, item_h)
				end
			end
		else
			wrap = true
		end
		if wrap then
			line_h = fixed_line_h or line_h
			local item_count = i - line_i
			local line_x = 0
			local item_spacing = 0
			if justify == 'flex_end' or justify == RIGHT then
				line_x = container_w - line_w
			elseif justify == 'center' or justify == MIDDLE then
				line_x = (container_w - line_w) / 2
			elseif justify == 'space_between' then
				item_spacing = (container_w - line_w) / (item_count - 1)
			elseif justify == 'space_around' then
				item_spacing = (container_w - line_w) / (item_count + 1)
				line_x = item_spacing
			end
			for i = line_i, i-1 do
				local layer = self[i]
				if layer.visible then
					local align = layer.flex_align or align_items
					if align == 'stretch' then
						layer[Y] = line_y
						layer[H] = line_h
					elseif align == 'flex_start' or align == TOP then
						layer[Y] = line_y
					elseif align == 'flex_end' or align == BOTTOM then
						layer[Y] = line_y + line_h - layer[H]
					elseif align == 'center' or align == MIDDLE then
						layer[Y] = line_y + round(line_h - layer[H]) / 2
					elseif horizontal and align == 'baseline' then
						layer.y = line_y + line1_baseline - layer.baseline
					end
					layer[X] = line_x
					line_x = line_x + layer[W] + item_spacing
				end
			end
			line_i = i
			line_y = line_y + line_h + line_spacing
			line_w = next_line_w0
			line_h = next_line_h0
		end
	end
