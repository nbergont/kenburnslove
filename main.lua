Object = require "classic"
require "album"

is_raspberry_pi = love.system.getOS() == "Linux" and io.popen('uname -n','r'):read('*l') == "pilove"

config = {
	display_picture = 8,
	fade_picture = 2,
	picture_by_album = 15,
	
	display_title = 5,
	fadein_title = 2,
	fadeout_title = 1
}

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
	
	-- Randomize seed on rpi
	if is_raspberry_pi then
		local rand = io.open('/dev/hwrng', 'rb'):read(4)
		local seed = rand:byte(1) + rand:byte(2)*256 + rand:byte(3)*65536 + rand:byte(4)*16777216
		love.math.setRandomSeed(seed)
	end
	
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
	
	shader = love.graphics.newShader("vignette.glsl")

end

function love.update(dt)
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

end

local canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
	

function love.draw()
	

	album:draw()
	
	love.graphics.setShader(shader)
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.draw(canvas)
	love.graphics.setShader()
	
	
	--love.graphics.setColor(255, 255, 255, 255)
	--love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end

function love.keypressed(key)
   if key == "escape" then
      love.event.quit()
   end
end

-- function love.errhand(msg)
	-- return
-- end
