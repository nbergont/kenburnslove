require "fade"
Picture = Object:extend()

local function easeInOutQuad(t)
	if t<.5 then return 2*t*t else return -1+(4-2*t)*t end
end

local function easeInOutCubic(t)
	if t<.5 then return 4*t*t*t else return (t-1)*(2*t-2)*(2*t-2)+1 end
end

local function easeInOutQuart(t)
	if t<.5 then return 8*t*t*t*t else return 1-8*(t-1)*(t-1)*(t-1)*(t-1) end
end

local function interpolate(p, x1, x2)
	return p * (x2 - x1) + x1
end

local function generate(x1, x2)
	if x1 < x2 then
		return love.math.random() * (x2 - x1) + x1
	else
		return love.math.random() * (x1 - x2) + x2
	end
end

local threadCode = [[
require("love.image")
local filename, channel = ...
local img = love.image.newImageData(filename)
-- TODO : resize image before send to GPU 
channel:push(img)
]]
	
function Picture:new()
	
	self.img = nil

	self.elapsed = 0 
	self.fade = Fade(config.fade_picture, config.display_picture, config.fade_picture)
	
    -- Thread variables
	self.thread = love.thread.newThread(threadCode)
	self.channel = love.thread.newChannel()
	
end

function Picture:load(filename)
    -- Free image memory (for raspberry)
	self.img = nil
	collectgarbage("step", 5)
	
	self.fade:reset()
	
	-- Start load image thread
	if filename then
		self.thread:start(filename, self.channel)
	end
end

function Picture:randomize()
	
	local wratio = love.graphics.getWidth()/self.img:getWidth()
	local hratio = love.graphics.getHeight()/self.img:getHeight()
	
	if self.img:getWidth() < self.img:getHeight() then -- Portrait

		-- Z
		self.sz = hratio*config.picture_max_zoom*1.4
		self.dz = self.sz
		self.z = self.sz
		
		-- Fixed center X
		self.sx = -(self.img:getWidth()*wratio - self.img:getWidth()*self.sz)/2
		self.dx = self.sx
		self.x = self.sx
		
		-- Y
		self.sy = generate(0, self.img:getHeight()*(self.sz - hratio))
		self.dy = generate(0, self.img:getHeight()*(self.dz - hratio))
		self.y = self.sy
	
	else -- Landscape

		-- Z
		self.sz = generate(wratio, wratio*config.picture_max_zoom)
		self.dz = generate(wratio, wratio*config.picture_max_zoom)
		self.z = self.sz
	
		-- X
		self.sx = generate(0, self.img:getWidth()*(self.sz - wratio))
		self.dx = generate(0, self.img:getWidth()*(self.dz - wratio))
		self.x = self.sx
		
		-- Y
		self.sy = generate(0, self.img:getHeight()*(self.sz - wratio))
		self.dy = generate(0, self.img:getHeight()*(self.dz - wratio))
		self.y = self.sy

	end
    
	self.fade:reset()
end

function Picture:isFadeOut()
	return self.fade:isFadeOut()
end

function Picture:isFinished()
	return self.fade:isFinished()
end

function Picture:wait()
	self.thread:wait()
end

function Picture:update(dt)
	
    -- Get thread error
    local merror = self.thread:getError()
    assert( not merror, merror )

    -- Query picture from thread
	local idata = self.channel:pop()
	if idata then
		self.img = love.graphics.newImage(idata) -- To GPU !
		self:randomize()
	end

	if self.img then
	
		self.fade:update(dt)
		local p = self.fade:progress()
		
		-- Update picture coordinate
		self.x = interpolate(p, self.sx, self.dx)
		self.y = interpolate(p, self.sy, self.dy)
		self.z = interpolate(p, self.sz, self.dz)

	end
end

function Picture:draw()
	if self.img then
		love.graphics.setColor(255, 255, 255, 255 * self.fade.alpha)
		love.graphics.draw(self.img, -self.x, -self.y, 0, self.z, self.z)
	end
end