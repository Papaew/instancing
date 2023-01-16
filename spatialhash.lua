
local ffi = require "ffi"
local bit = require 'bit'
local floor = math.floor
local maxNumObjects = 10000
local tableSize = 5*maxNumObjects

local code = [[
struct shash {
	int cellSize;
	int entCount;
	int pool[%d];
	int cellStart[%d];
	int cellEntries[%d];
	int queryIds[%d];
}]]
ffi.cdef(string.format(code, maxNumObjects, tableSize+1, maxNumObjects, 500))
local ct_shash = ffi.typeof("struct shash")

--[[function shash_new( cell_size )
	local bdata = love.data.newByteData( ffi.sizeof(ct_shash) )
	local shash = ffi.cast("struct shash*", bdata:getFFIPointer())
	shash.cellSize = cell_size

	return bdata, shash
end
--]]
local function hashCoords( x,y )
	local h = bit.bxor((x * 73856093), (y * 83492791))
	return h % tableSize
end

function shash_clear( h )
	-- determine cell sizes
	h.entCount = 0
	ffi.fill(h.pool, ffi.sizeof(h.pool))
	ffi.fill(h.cellStart, ffi.sizeof(h.cellStart))
	ffi.fill(h.cellEntries, ffi.sizeof(h.cellEntries))
end

function shash_add( h, id, x,y )
	if h.entCount < maxNumObjects then
		local index = hashCoords(floor(x/h.cellSize), floor(y/h.cellSize))
		h.cellStart[index] = h.cellStart[index] + 1
		h.pool[h.entCount] = id
		h.entCount = math.min(h.entCount + 1, maxNumObjects-1)
	end
end

function shash_process( h, cells )
	-- determine cells starts
	local start = 0
	for i=0, tableSize-1 do
		start = start + h.cellStart[i]
		h.cellStart[i] = start
	end
	h.cellStart[tableSize] = start

	-- fill in objects ids
	for i=0, h.entCount-1 do
		local id = h.pool[i]
		local x = floor(cells[id].x/h.cellSize)
		local y = floor(cells[id].y/h.cellSize)
		local index = hashCoords(x,y)

		h.cellStart[index] = h.cellStart[index] - 1
		h.cellEntries[h.cellStart[index]] = id
	end
end

function shash_query( h, x,y, maxDist )
	ffi.fill(h.queryIds, ffi.sizeof(h.queryIds))

	local x1,y1 = floor((x-maxDist)/h.cellSize), floor((y-maxDist)/h.cellSize)
	local x2,y2 = floor((x+maxDist)/h.cellSize), floor((y+maxDist)/h.cellSize)
	local querySize = 0

	for xi=x1, x2 do
	for yi=y1, y2 do
		local index = hashCoords(xi,yi)
		local start = h.cellStart[index]
		local finish = h.cellStart[index + 1]

		for i=start, finish-1 do
			h.queryIds[querySize] = h.cellEntries[i]
			querySize = querySize+1
		end
	end
	end

	return querySize
end
