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

local picture_max_zoom = 1.4 -- Ratio
	
function Picture:new()
	
	self.img = nil

	self.elapsed = 0 
	self.fade = Fade(0, 8, 2)
	
    -- Thread variables
	self.thread = love.thread.newThread(threadCode)
	self.channel = love.thread.newChannel()
	
end

function Picture:load(filename)
    -- Free image memory (for raspberry)
	self.img = nil
	collectgarbage("step", 3)
	
	self.fade:reset()
	
	-- Start load image thread
	if filename then
		self.thread:start(filename, self.channel)
	end
end

function Picture:randomize()

    -- Full screen ratio
    local ratio = math.max(love.graphics.getWidth()/self.img:getWidth(), 
						   love.graphics.getHeight()/self.img:getHeight())
	
    -- Z
	self.sz = generate(ratio, ratio*picture_max_zoom);
	self.dz = generate(ratio, ratio*picture_max_zoom);
	self.z = self.sz
	-- X
	self.sx = generate(0, self.img:getWidth()*(self.sz - ratio))
	self.dx = generate(0, self.img:getWidth()*(self.dz - ratio))
	self.x = self.sx
	-- Y
	self.sy = generate(0, self.img:getHeight()*(self.sz - ratio))
	self.dy = generate(0, self.img:getHeight()*(self.dz - ratio))
	self.y = self.sy

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