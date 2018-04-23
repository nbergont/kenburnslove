require "fade"
Picture = Object:extend()

local function interpolate(p, v1, v2)
	return p * (v2 - v1) + v1
end

local function rand_interval(v1, v2)
	return hwrandom() * (v2 - v1) + v1
end

local threadCode = [[
require("love.image")
local filename, channel = ...
local img = love.image.newImageData(filename)
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
	if self.img then
		self.img:release()
	end
	self.img = nil
	--collectgarbage("step", 5)
	
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
		self.sz = rand_interval(hratio, hratio*config.picture_max_zoom*1.4)
		self.dz = rand_interval(hratio, hratio*config.picture_max_zoom*1.4)
		self.z = self.sz
		
		-- Fixed center X
		self.sx = -(self.img:getWidth()*wratio - self.img:getWidth()*self.sz)/2
		self.dx = -(self.img:getWidth()*wratio - self.img:getWidth()*self.dz)/2
		self.x = self.sx
		
		-- Y
		self.sy = rand_interval(0, self.img:getHeight()*(self.sz - hratio))
		self.dy = rand_interval(0, self.img:getHeight()*(self.dz - hratio))
		self.y = self.sy
	
	else -- Landscape

		local ratio = math.max(wratio, hratio)
		-- Z
		self.sz = rand_interval(ratio, ratio*config.picture_max_zoom)
		self.dz = rand_interval(ratio, ratio*config.picture_max_zoom)
		self.z = self.sz
	
		-- X
		self.sx = rand_interval(0, self.img:getWidth()*(self.sz - ratio))
		self.dx = rand_interval(0, self.img:getWidth()*(self.dz - ratio))
		self.x = self.sx
		
		-- Y
		self.sy = rand_interval(0, self.img:getHeight()*(self.sz - ratio))
		self.dy = rand_interval(0, self.img:getHeight()*(self.dz - ratio))
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

	self.fade:update(dt)

	if self.img then
	
		local p = self.fade:progress()
		
		-- Update picture coordinate
		self.x = interpolate(p, self.sx, self.dx)
		self.y = interpolate(p, self.sy, self.dy)
		self.z = interpolate(p, self.sz, self.dz)

	end
end

function Picture:draw()
	if self.img then
		love.graphics.setColor(1, 1, 1, self.fade.alpha)
		love.graphics.draw(self.img, -self.x, -self.y, 0, self.z, self.z)
	end
end
