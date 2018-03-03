Album = Object:extend()
require "picture"
require "title"

function Album:new()

	self.pcurrent = Picture()
	self.pnext = Picture()
	self.title = Title()

end

function Album:set(dir)

	-- Find pictures in directory
	self.list = {}
	local files = love.filesystem.getDirectoryItems(dir)
	for k, file in ipairs(files) do
		if file:match(".[Jj][Pp][Gg]$") then -- Only jpeg
			table.insert(self.list, dir .. "/" .. file)
		end
	end

	-- Shuffle pictures list
	shuffle(self.list)
	
	self.max_picture = math.min(config.picture_by_album, #self.list)

	self.title:setLabel(dir:match( "([^/]+)$" ))
	
	-- Load first pictures
	self.pcurrent:load(self.list[1])
	self.pnext:load(self.list[2])
	self.index = 2
	self.elapsed = 0
	
	-- Wait first pictures
	self.pcurrent:wait()
	self.pnext:wait()
end

function Album:isFinished()
	return self.index > self.max_picture and self.pcurrent:isFinished()
end

function Album:update(dt)

	-- Update picture
	if self.elapsed > 2 then
		if self.pcurrent:isFinished() then

			-- Load next picture
			self.index = self.index + 1
			if self.index > self.max_picture then
				self.pcurrent:load(nil)
			else
				self.pcurrent:load(self.list[self.index])
			end
	
			self.pcurrent, self.pnext = self.pnext, self.pcurrent -- Swap picture
			self.pcurrent:update(dt)
		elseif self.pcurrent:isFadeOut() then
			self.pnext:update(dt)
			self.pcurrent:update(dt)
		else
			self.pcurrent:update(dt)
		end
	else
		self.elapsed = self.elapsed + dt
	end
	
	-- Update title
	if not self.title:isFinished() then
		self.title:update(dt)
	end
end

function Album:draw()

	if self.pcurrent:isFadeOut() then
		self.pnext:draw()
		self.pcurrent:draw()
	else
		self.pcurrent:draw()
	end
	
	if not self.title:isFinished() then
		self.title:draw()
	end
end

