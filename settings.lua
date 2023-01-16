---------------------------------------------------------------------
max_obj = 50000
obj_count = 0
---------------------------------------------------------------------
cw,ch = 6,6
chunkcount = cw*ch
chunkw = 100
cellsize = 50
cellscale = cellsize*chunkw
---------------------------------------------------------------------
circleRadius = 30
circleSegments = 15
---------------------------------------------------------------------
qx,qy, qr = 0,0, cellsize
---------------------------------------------------------------------
local ffi = require 'ffi'
require("spatialhash")
-- local bit = require 'bit'
-- bit.bor(r, bit.lshift(g, 8), bit.lshift(b, 16))
---------------------------------------------------------------------
local code = [[
struct position { float x,y, ox,oy; };
struct physics { float mass, radius, angle, oangle; };
struct pixel_rgba32f { float r,g,b,a; };
struct chunk {
	int x,y, w,h, ts;
	int width, height;
	struct { float r,g,b,a; } color;
	struct shash hash;
};
]]
ffi.cdef(code)
---------------------------------------------------------------------
ct_position = ffi.typeof("struct position")
ct_pixel_rgba32f  = ffi.typeof("struct pixel_rgba32f")
ct_physics  = ffi.typeof("struct physics")
ct_chunk  = ffi.typeof("struct chunk")
