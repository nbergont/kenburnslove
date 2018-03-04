Object = require "classic"
require "album"

is_raspberry_pi = love.system.getOS() == "Linux" and io.popen('uname -n','r'):read('*l') == "pilove"

config = {
	display_picture = 6,
	fade_picture = 2,
	picture_by_album = 15,
	picture_max_zoom = 1.4,
	
	display_title = 5,
	fadein_title = 2,
	fadeout_title = 1,
	
	vignette_shader = true
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
	--itime = 0
	
	if config.vignette_shader then
		global_shader = love.graphics.newShader("vignette.glsl")
	end

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
	--itime = itime + dt
end

function love.draw()
	
	if global_shader then
		--global_shader:send("iTime", itime)
		love.graphics.setShader(global_shader)
	end
	album:draw()
	love.graphics.setShader()

end

function love.keypressed(key)
   if key == "escape" then
      love.event.quit()
   end
end

function love.errhand(msg)
	love.event.quit(1)
end
