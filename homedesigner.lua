
require'$'
local p2d = require'path2d'
local testui = require'testui'
local distance2 = require'path2d_point'.distance2
local point_angle = require'path2d_point'.point_angle
local line_hit = require'path2d_line'.hit
local m4 = require'mat4'
local v3 = require'vec3'

local savefile = require'homedesigner_file'
local paths = savefile.paths
local state, cpath, cpoint, spath, spoint, ipoint, apoint

local function hit_points(x, y)
	local x1, y1, d1, i1, j1 = x, y, 1/0
	for i,path in ipairs(paths) do
		for j,p in ipairs(path) do
			if not (i == cpath and j == cpoint) then
				local x0, y0 = p[1], p[2]
				local d = distance2(x, y, x0, y0)
				if d < 20 and d < d1 then
					x1, y1, d1, i1, j1 = x0, y0, d, i, j
				end
			end
		end
	end
	return x1, y1, i1, j1
end

local function snap_to_points(x, y)
	local x, y, i, j = hit_points(x, y)
	if i ~= nil then
		spath, spoint = i, j
	end
	return i ~= nil, x, y
end

local function snap_to_lines(x, y)
	local d1, px1, py1 = 1/0
	ipoint, apoint = nil
	for i,path in ipairs(paths) do
		local p0
		for j,p in ipairs(path) do
			if p0 and not (cpath == i and cpoint == j) then
				local x0, y0 = p0[1], p0[2]
				local x1, y1 = p[1], p[2]
				local d, px, py, t = line_hit(x, y, x0, y0, x1, y1, true)
				if d < 60 and d < d1 and ((t >= 0 and t <= 1) or (i == spath and (j == spoint or j == spoint+1))) then
					d1, px1, py1 = d, px, py
					if t < 0 then
						apoint = {x0, y0}
					elseif t > 1 then
						apoint = {x1, y1}
					end
				end
			end
			p0 = p
		end
	end
	ipoint = px1 and {px1, py1}
	return px1 ~= nil, px1 or x, py1 or y
end

local function snap_to_perpendiculars(x, y)
	return false, x, y
end

local function snap_dim(x, xi)
	local dx1, x1 = 1/0, x
	for i,path in ipairs(paths) do
		for j,p in ipairs(path) do
			if not (i == cpath and j == cpoint) then
				local x0 = p[xi]
				local dx = abs(x - x0)
				if dx < 10 and dx < dx1 then
					x1, dx1 = x0, dx
				end
			end
		end
	end
	return x1
end

local function snap_to_axes(x, y)
	local p = paths[cpath][cpoint-1]
	local x0, y0 = p[1], p[2]
	local a = point_angle(x0, y0, x, y)
	local a = round(abs(a), 3)
	if a == 180 or a == 0 then
		x = snap_dim(x, 1)
		return true, x, y0
	elseif a == 90 then
		y = snap_dim(y, 2)
		return true, x0, y
	end
	return false, x, y
end

function testui:repaint()

	local cr = self.cr
	local down = self.mouse.left

	if state and self.key == 'esc' then
		self.key_captured = true
		if state then
			remove(paths[cpath], cpoint)
			if #paths[cpath] == 1 then
				remove(paths, cpath)
			end
			cpath, cpoint = nil
			spath, spoint, ipoint = nil
			state = nil
		end
	end

	if down then
		if not state or state == 'move' then
			if not state then
				local path = {}
				add(paths, path)
				add(path, {self.mx, self.my})
				cpath = #paths
			end
			state = 'down'
			spath, spoint, ipoint = nil
			local x, y = hit_points(self.mx, self.my)
			add(paths[cpath], {x, y})
		end
	elseif state == 'down' then
		state = 'move'
		cpoint = #paths[cpath]
		spoint = nil
	elseif state == 'move' then
		local x, y = self.mx, self.my
		local snapped, x, y = snap_to_points(x, y)
		local snapped, x, y = snap_to_axes(x, y)
		local snapped, x, y = snap_to_lines(x, y)
		local snapped, x, y = snap_to_perpendiculars(x, y)
		local p = paths[cpath][cpoint]
		p[1] = x
		p[2] = y
	elseif self.mx then
		local x, y = hit_points(self.mx, self.my)

	end

	if self.key == 'F2' then
		local t = {paths = paths}
		pp.save('houseeditor_file.lua', t)
	end

	for i,path in ipairs(paths) do
		cr:new_path()
		for j,p in ipairs(path) do
			local x, y = p[1], p[2]
			if j == 1 then
				cr:move_to(x, y)
			else
				cr:line_to(x, y)
			end
		end
		if cpath ~= i then
			cr:close_path()
		end
		cr:rgb(1, 1, 1)
		cr:stroke()
	end

	for i,path in ipairs(paths) do
		for j,p in ipairs(path) do
			local x, y = p[1], p[2]
			cr:rectangle(x - 2, y - 2, 4, 4)
			cr:rgb(1, 1, 1)
			cr:fill()
		end
	end

	if spath and spoint then
		local p = paths[spath]
		local p = p[spoint]
		local x, y = p[1], p[2]
		cr:rectangle(x - 5, y - 5, 10, 10)
		cr:rgb(1, 1, 0)
		cr:fill()
	end

	if ipoint then
		local p = ipoint
		local x, y = p[1], p[2]
		cr:rectangle(x - 5, y - 5, 10, 10)
		cr:rgb(1, 0, 0)
		cr:fill()
		if apoint then
			cr:move_to(x, y)
			cr:line_to(apoint[1], apoint[2])
			cr:rgb(1, 0, 1)
			cr:stroke()
		end
	end

	local n = 8
	local a = v3.array(n,
		{-1,  1, -1},
		{ 1,  1, -1},
		{ 1, -1, -1},
		{-1, -1, -1},

		{-1,  1,  1},
		{ 1,  1,  1},
		{ 1, -1,  1},
		{-1, -1,  1}
	)

	self.min_w = 100
	self.t = self:slide('t', 't', self.t, -10, 10, .1, 5) or self.t or 5
	self.r = self:slide('r', 'r', self.r, -math.pi/2, math.pi/2, .01, 0) or self.r or 0

	local w, h = self.window:client_size()
	local s = min(w, h)
	local pm = m4.perspective(rad(90), 1, 1, 10)
	local cm = m4():translate(0, 0, self.t):rotate(self.r, 1, 1, 0)
	pm:mul(cm) -- :scale(s, s, 1)
	cr:translate(w/2, h/2)
	for i=0,n-1 do
		local x, y, z = pm:transform_point(a[i]:unpack())
		if z >= 0 and z <= 1 then
			x = x * s
			y = y * s
			cr:rectangle(x - 5, y - 5, 10, 10)
			cr:rgb(1, 1, 0)
			cr:fill()
		end
	end

end

testui:init()
testui.window:restore()
testui:run()
