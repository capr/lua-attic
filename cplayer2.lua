
--runtime for IMGUI and 2D procedural graphics
--Written by Cosmin Apreutesei. Public Domain.

local nw = require'nw'
local imgui = require'imgui_nw_cairo'

local app = nw:app()

local x, y, w, h = app:active_display():desktop_rect()
x = x + 900
y = y + 200
local win = app:window{x = x, y = y, w = w / 2, h = h/2, title = 'Demo',
	visible = false, autoquit = true}

local player = imgui:bind(win)

function win:imgui_render()
	player:render(self.cr)
end

function player:run()
	win:show()
	app:run()
end

if not ... then
	function player:render()
		self:textbox(0, 0, self.cw, self.ch, 'Hello World!')
	end
	player:run()
end

return player
