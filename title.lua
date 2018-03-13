require "fade"
Title = Object:extend()

local title_font = love.graphics.newFont("Hughs.otf", 500)

function Title:new()
	self.label = ""
	self.fade = Fade(config.fadein_title, config.display_title, config.fadeout_title)
	self.shader = love.graphics.newShader("blur.glsl")
	self.canvas_blur = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
	self.canvas_title = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
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
	
	local main_title = self.label:gsub("%s+%((.+)%)", "")
	local main_title_ratio = 0.8
	local sub_title = self.label:match("%((.+)%)")
	local sub_title_ratio = 0.6
	
	
	-- Render black title to canvas_blur (for drop shadow effect)
	love.graphics.setCanvas(self.canvas_blur)
	love.graphics.clear()
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.setFont(title_font)
	
	center_print(main_title, title_font, main_title_ratio, 0, 0, love.graphics.getWidth(), love.graphics.getHeight()*0.8)
	if sub_title then
		center_print(sub_title, title_font, sub_title_ratio, 0, love.graphics.getHeight()/2, love.graphics.getWidth(), love.graphics.getHeight()/2)
	end
	
	-- Blur effect on canvas_blur
	love.graphics.setCanvas(self.canvas_title)
	love.graphics.clear()
	love.graphics.setShader(self.shader)
	love.graphics.draw(self.canvas_blur)
	love.graphics.setShader()
	
	-- draw normal title
	love.graphics.setColor(255, 255, 255, 255)
	center_print(main_title, title_font, main_title_ratio, 0, 0, love.graphics.getWidth(), love.graphics.getHeight()*0.8)
	if sub_title then
		center_print(sub_title, title_font, sub_title_ratio, 0, love.graphics.getHeight()/2, love.graphics.getWidth(), love.graphics.getHeight()/2)
	end
	love.graphics.setCanvas()
	
end

function Title:setLabel(label)
	self.label = label
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
	love.graphics.setColor(255, 255, 255, 255 * self.fade.alpha)
	love.graphics.draw(self.canvas_title)
end