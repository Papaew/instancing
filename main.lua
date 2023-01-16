local g = love.graphics
local lm = love.mouse
local lk = love.keyboard
local ffi = require 'ffi'
local cos, sin, rad, sqrt, random, floor = math.cos, math.sin, math.rad, math.sqrt, math.random, math.floor
g.setDefaultFilter('linear', 'nearest')
---------------------------------------------------------------------------------------------------------------
local Camera = require('camera')
require('settings')
require('threadHelper')
require('meshHelper')
require('chunk')
---------------------------------------------------------------------------------------------------------------
local Camera = require('camera')
local shader = g.newShader('instancing.glsl')
shader:send('size', {512, 512})
---------------------------------------------------------------------------------------------------------------
local vertices = makecircle(0,0, circleRadius, circleSegments)
local mesh = g.newMesh(vertices, 'triangles', 'static')
---------------------------------------------------------------------------------------------------------------
local physdata = love.data.newByteData( max_obj * ffi.sizeof(ct_physics) )
local physics = ffi.cast('struct physics*', physdata:getFFIPointer())
---------------------------------------------------------------------------------------------------------------
local posattr, posdata, positions = tbuffer( 512, 512, 'struct position', "rgba32f" )
local colattr, coldata, colors = tbuffer( 512, 512, 'struct pixel_rgba32f', "rgba32f" )
---------------------------------------------------------------------------------------------------------------

function love.keypressed( key, scancode, isrepeat )
	if key == 'escape' then love.event.quit() end
end

function love.mousemoved( x,y, dx,dy, istouch )
	x,y = camera:getScreenPos( x,y )
	if lm.isDown(3) then
		camera:move( dx,dy )
	end
end

function love.wheelmoved( x,y )
	camera:zoom(y)
end

function love.mousepressed( x,y, key, istouch, presses )
	x,y = camera:getScreenPos( x,y )
end

local function setColor( i, r,g,b )
	colors[i].r = r
	colors[i].g = g
	colors[i].b = b
	colors[i].a = a or 1
end

function addEntities( count, x,y, spread )
	count = math.min(max_obj - obj_count, count)
	for j=0, count-1 do
		local i = obj_count
		local x = x + random(-spread, spread)
		local y = y + random(-spread, spread)
		local px = (random()*2-1)*5
		local py = (random()*2-1)*5

		positions[i].x = x
		positions[i].y = y
		positions[i].ox = x
		positions[i].oy = y

		physics[i].mass = random(1, 100)
		physics[i].radius = circleRadius
		physics[i].angle = 0
		physics[i].oangle = rad((random()*2-1)*random(1,5))

		setColor(i, random(), random(), random(), 1)

		obj_count = obj_count + 1
	end
end

function delEntity( i )
	local last = math.max(obj_count-1, 0)

	ffi.copy(positions[i], positions[last], ffi.sizeof(ct_position))
	ffi.copy(physics[i], physics[last], ffi.sizeof(ct_physics))
	ffi.copy(colors[i], colors[last], ffi.sizeof(ct_pixel_rgba32f))

	obj_count = last
end

function love.load()
	math.randomseed(os.time())
	g.setBackgroundColor(70/255, 75/255, 108/255)
	g.setLineStyle('smooth')

	camera = Camera.new()

	-- addEntities( 50000, 1000, 1000, 50000 )

	-- chunks
	chunkdata, chunks = newWorld(cw,ch, chunkw,chunkw, cellsize)

	-- physics
	thread, input, output = newThread('integrator.lua', chunkdata, posdata, physdata, coldata, obj_count)
	input:push(obj_count)

	-- collision
	threadcount = 9
	threads, channels = newThreadGroup(threadcount, 'collisions.lua', chunkdata, posdata, physdata, coldata, 1/threadcount)
	for i=1, threadcount do
		channels[i][1]:push(i-1)
	end
end

function love.update(dt)
	mx,my = camera:getScreenPos( lm.getPosition() )

	local v = output:pop()
	if v then
		for i=1, threadcount do
			channels[i][1]:push(true)
		end
	end

	-- check if all threads are done their job
	local finished = true
	for i=1, threadcount do
		finished = finished and channels[i][2]:peek()
	end

	-- if so, update current positions
	if finished then
		positions[0].x = mx
		positions[0].y = my

		posattr:replacePixels(posdata)
		shader:send('positions', posattr)

		colattr:replacePixels(coldata)
		shader:send('colors', colattr)

		for i=1, threadcount do
			channels[i][2]:clear()
		end

		input:push(obj_count)

		if lm.isDown(1) then
			addEntities( 50, mx,my, 2000 )
		elseif lm.isDown(2) then
			for i=1, 50 do
				delEntity(1)
			end
		end
	end
end

function love.draw()
	camera:set()

		g.setColor(1,1,1)
		g.setShader(shader)
			g.drawInstanced(mesh, obj_count)
		g.setShader()

	camera:set()

	g.setColor(1,1,1)
	g.print('FPS:'.. love.timer.getFPS(), g.getWidth()-60)
	g.print('object count: '..obj_count)
end