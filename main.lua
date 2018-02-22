Object = require "classic"
require "album"

function shuffle(tbl)
  local size = #tbl
  for i = size, 1, -1 do
    local rand = love.math.random(size)
    tbl[i], tbl[rand] = tbl[rand], tbl[i]
  end
end

function love.load(arg)
	-- Hide cursor
	love.mouse.setVisible(false)
	
	local album_dir = "pictures"
	album_list = {}
	local files = love.filesystem.getDirectoryItems(album_dir)
	for k, file in ipairs(files) do
		if love.filesystem.isDirectory(album_dir .. "/" .. file) then
			table.insert(album_list, album_dir .. "/" .. file)
		end
		
	end
	
	shuffle(album_list)
	
	
	album = Album()
	album:set(album_list[1])
	index = 1
	
	elapsed = 0
end

function love.update(dt)
	-- Attente de 0.5s entre chaque album
	if elapsed > 0.5 then
		album:update(dt)
		
		if album:isFinished() then
			index = index + 1
			elapsed = 0
			if index > #album_list then
				shuffle(album_list)
				index = 1 
			end
			album:set(album_list[index])
		end
	else
		elapsed = elapsed + dt
	end
	
end

function love.draw()
	album:draw()

	--love.graphics.setColor(255, 255, 255, 255)
	--love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end

function love.keypressed(key)
   if key == "escape" then
      love.event.quit()
   end
end
