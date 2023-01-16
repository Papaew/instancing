local ffi = require 'ffi'
local random = math.random

local function clamp( value, min, max )
	return math.min(math.max(value, min), max) 
end

-- Creates a world with the specified number of chunks
function newWorld( wwidth, wheight, cwidth, cheight, cellsize )
	local count = wwidth*wheight
	local bdata = love.data.newByteData( count * ffi.sizeof(ct_chunk) )
	local chunks = ffi.cast('struct chunk*', bdata:getFFIPointer())

	for i=0, count-1 do
		local cx = i % wwidth
		local cy = math.floor(i / wwidth)

		chunks[i].x = cx *  cwidth * cellsize
		chunks[i].y = cy * cheight * cellsize

		chunks[i].width  =  cwidth * cellsize
		chunks[i].height = cheight * cellsize

		chunks[i].color.r = clamp(random() + 0.3, 0, 1)
		chunks[i].color.g = clamp(random() + 0.3, 0, 1)
		chunks[i].color.b = clamp(random() + 0.3, 0, 1)
		chunks[i].color.a = 1

		chunks[i].hash.cellSize = cellsize
	end

	return bdata, chunks
end

-- debug only
function chunk_draw( c )
	g.setColor(c.color.r, c.color.g, c.color.b, 0.2)
	g.rectangle('fill', c.x, c.y, c.width, c.height)
	g.setColor(1,1,1)
	g.print(c.hash.entCount, c.x, c.y)
end