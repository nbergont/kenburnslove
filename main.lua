Object = require "classic"
require "album"

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

local hwrng_device = io.open('/dev/hwrng', 'rb') -- RPI reel random device

function hwrng_read()
	if hwrng_device then
		local hr = hwrng_device:read(3)
		local v3 = hr:byte(1) + hr:byte(2)*256 + hr:byte(3)*65536
		return v3/16777215
	end
	-- Fall back
	return love.math.random()
end

function hwrandom(size)
	if size then
		return math.ceil(hwrng_read()*size)
	end
	return hwrng_read()
end


function shuffle(tbl)
  local size = #tbl
  for i = size, 1, -1 do
    local rand = hwrandom(size)
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
	drop_frame = false
	--itime = 0
	
	if config.vignette_shader then
		global_shader = love.graphics.newShader("vignette.glsl")
	end

end

function love.update(dt)

	if not drop_frame then
		album:update(dt)
	end
	drop_frame = false
	
	if album:isFinished() then
		index = index + 1
		elapsed = 0
		if index > #album_list then
			shuffle(album_list)
			index = 1
		end
		album:set(album_list[index])
		drop_frame = true
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
	if hwrng_device then
		hwrng_device:close()
	end
	love.event.quit(1)
end
