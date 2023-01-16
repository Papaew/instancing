local ffi = require('ffi')
local active = true
----------------------------------
require('love.image')
require("settings")
----------------------------------
require("spatialhash")
----------------------------------
local input, output, chunkdata, posdata, physdata, coldata, delimeter = ...
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

function push( i, dx,dy )
	positions[i].x = positions[i].x + dx
	positions[i].y = positions[i].y + dy
end

-- wait for the current thread index
local index = input:demand()

local half   = chunkcount * delimeter
local start  = half * index
local finish = start + half - 1

while active do
	active = input:demand()

	for ci=start, finish do
		shash_process(chunks[ci].hash, positions)

		for u=0, chunks[ci].hash.entCount-1 do
			local i = chunks[ci].hash.pool[u]

			local found = shash_query(chunks[ci].hash, positions[i].x, positions[i].y, qr)
			for f=0, found-1 do
				local j = chunks[ci].hash.queryIds[f]
				if j ~= i then
					local dx = positions[i].x - positions[j].x
					local dy = positions[i].y - positions[j].y

					local cd = dx*dx + dy*dy
					local r = physics[i].radius + physics[j].radius

					if cd <= r*r then
						cd = math.sqrt(cd)
						local cr = r - cd

						-- Collisions without taking into account the mass of objects
						dx,dy = dx / cd * 0.5, dy / cd * 0.5
						push(i,  dx*cr,  dy*cr)
						push(j, -dx*cr, -dy*cr)

						-- Collisions taking into account the mass of objects
						--[[dx,dy = dx/cd, dy/cd
						local mm = (physics[i].mass + physics[j].mass)
						local m1 = physics[j].mass / mm
						local m2 = physics[i].mass / mm

						push(i,  dx*cr*m1,  dy*cr*m1)
						push(j, -dx*cr*m2, -dy*cr*m2)--]]

						-- Color change in collision 
						-- setColor(i, 1, 0.9, 0.01)
						-- setColor(j, 1, 0.9, 0.01)
					end
				end
			end
		end
	end
	
	output:push(true)
end