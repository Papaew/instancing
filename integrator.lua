local ffi = require('ffi')
local floor = math.floor
local active = true
----------------------------------
require('love.image')
require("settings")
----------------------------------
local damping = 0.001
----------------------------------
local input, output, chunkdata, posdata, physdata, coldata, obj_count = ...
local chunks = ffi.cast("struct chunk*", chunkdata:getFFIPointer())
local positions = ffi.cast('struct position*', posdata:getFFIPointer())
local physics = ffi.cast("struct physics*", physdata:getFFIPointer())
local colors = ffi.cast('struct pixel_rgba32f*', coldata:getFFIPointer())
----------------------------------

local function setColor( i, r,g,b )
	colors[i].r = r
	colors[i].g = g
	colors[i].b = b
	colors[i].a = a or 1
end

local tmpx, tmpy, tmpa = 0,0,0
local cellhalf = cellsize*0.5
while active do
	obj_count = input:demand()

	for ci=0, chunkcount-1 do
		shash_clear(chunks[ci].hash)
	end

	for i=0, obj_count-1 do
		tmpx, tmpy = positions[i].x, positions[i].y
		tmpa = physics[i].angle

		positions[i].x = (2-damping) * positions[i].x - (1-damping) * positions[i].ox
		positions[i].y = (2-damping) * positions[i].y - (1-damping) * positions[i].oy
		physics[i].angle = (2-damping) * physics[i].angle - (1-damping) * physics[i].oangle
		
		positions[i].ox, positions[i].oy = tmpx, tmpy
		physics[i].oangle = tmpa

		-- Defining chunks to which an object belongs
		local x1 = floor((positions[i].x - cellhalf) / cellscale)
		local y1 = floor((positions[i].y - cellhalf) / cellscale)
		local x2 = floor((positions[i].x + cellhalf) / cellscale)
		local y2 = floor((positions[i].y + cellhalf) / cellscale)

		for x=x1, x2 do
		for y=y1, y2 do
			local ci = (y*cw + x) % chunkcount
			shash_add(chunks[ci].hash, i, positions[i].x, positions[i].y)

			-- Set the color of the object to be the same as the color of the chunk
			setColor(i, chunks[ci].color.r, chunks[ci].color.g, chunks[ci].color.b)
		end
		end
	end

	output:push("done!")
end
