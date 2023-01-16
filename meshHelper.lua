local g = love.graphics
local ffi = require 'ffi'
local cos, sin, rad = math.cos, math.sin, math.rad

function makecircle(cx,cy, radius, segments, cr,cg,cb)
	local vertices = {}
	local step = 360/segments
	for i=0, segments-1 do
		local x = cos(rad(i*step))
		local y = sin(rad(i*step))
		local nx = cos(rad(i*step+step))
		local ny = sin(rad(i*step+step))

		table.insert(vertices, {cx+x*radius, cy+y*radius, cr,cg,cb})
		table.insert(vertices, {cx, cy, cr,cg,cb})
		table.insert(vertices, {cx+nx*radius, cy+ny*radius, cr,cg,cb})
	end

	return vertices
end

-- This function creates a mesh that is used as a buffer of the desired C type
function buffer( count, ctype, vformat )
	local data = love.data.newByteData( count * ffi.sizeof(ctype) )
	local mesh = g.newMesh(vformat, count, nil, 'stream')
	local ptr = ffi.cast(ctype..'*', data:getFFIPointer())
	mesh:setVertices(data, 1)

	return mesh, data, ptr
end

-- This function creates a texture that is used as a buffer of the desired C type
function tbuffer( w,h, ctype, format )
	local data = love.image.newImageData( w, h, format )
	local ptr = ffi.cast(ctype..'*', data:getFFIPointer())
	local attr = g.newImage(data)

	return attr, data, ptr
end