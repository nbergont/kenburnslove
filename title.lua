require "fade"
Title = Object:extend()

local title_duration = 6
local title_transition = 2
local title_wratio = 0.8
local title_font = love.graphics.newFont("Hughs.otf", 200)

function Title:new()
	self.label = ""
	self.fade = Fade(2, 5, 1)
	self.shader = love.graphics.newShader("blur.glsl")
	self.canvas1 = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
	self.canvas2 = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
	self.is_render = false
	
end


local function center_print(label, font, size_ratio, x, y, w, h)

	local wlabel = font:getWidth(label)
	local hlabel = font:getHeight()
	
	-- Find best fullscreen ratio
	local ratio = (w/wlabel)*size_ratio
	
	-- Center title
	local cx = (w-wlabel*ratio)/2
	local cy = (h-hlabel*ratio)/2

	love.graphics.print(label, x+cx, y+cy, 0, ratio, ratio)
end

function Title:render()

	local sub_title = self.label:match("%((.+)%)")
	local main_title = self.label:gsub("%s+%((.+)%)", "")
	
	-- Render black title to canvas (for blur effect)
	love.graphics.setCanvas(self.canvas1)
	love.graphics.clear()
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.setFont(title_font)
	
	center_print(main_title, title_font, 0.8, 0, 0, love.graphics.getWidth(), love.graphics.getHeight()*0.8)
	if sub_title then
		center_print(sub_title, title_font, 0.6, 0, love.graphics.getHeight()/2, love.graphics.getWidth(), love.graphics.getHeight()/2)
	end
	-- Blur effect on canvas
	love.graphics.setCanvas(self.canvas2)
	love.graphics.clear()
	self.shader:send("blurRadius", love.graphics.getWidth()*0.001)
	love.graphics.setShader(self.shader)
	love.graphics.draw(self.canvas1)
	love.graphics.setShader()
	
	-- draw normal title
	love.graphics.setColor(255, 255, 255, 255)
	center_print(main_title, title_font, 0.8, 0, 0, love.graphics.getWidth(), love.graphics.getHeight()*0.8)
	if sub_title then
		center_print(sub_title, title_font, 0.6, 0, love.graphics.getHeight()/2, love.graphics.getWidth(), love.graphics.getHeight()/2)
	end
	love.graphics.setCanvas()
	
	self.is_render = true
end

function Title:setLabel(label)
	self.label = label
	self.is_render = false
	self.fade:reset()
	self:render()
end

function Title:isFinished()
	return self.fade:isFinished()
end

function Title:isFadeOut()
	return self.fade:isFadeOut()
end

function Title:update(dt)
	self.fade:update(dt)
   
end

function Title:draw()
	if not self.is_render then
		self:render()
	end

	love.graphics.setColor(255, 255, 255, 255 * self.fade.alpha)
	love.graphics.draw(self.canvas2)
end