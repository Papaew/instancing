function love.filesystem.appendRecuirePath( paths )
	local p = { love.filesystem.getRequirePath() }
	if type(paths) == "table" then
		for i, path in pairs(paths) do
			table.insert(p, path.."/?.lua;"..path.."/?/init.lua")
		end
	else
		table.insert(p, paths)
	end
	love.filesystem.setRequirePath( table.concat(p, ";") )
end

function love.filesystem.appendCRecuirePath( paths )
	local p = { love.filesystem.getCRequirePath() }
	if type(paths) == "table" then
		for i, path in pairs(paths) do
			table.insert(p, path.."/??")
		end
	else
		table.insert(p, paths)
	end
	love.filesystem.setCRequirePath( table.concat(p, ";") )
end

love.filesystem.appendCRecuirePath { 'libraries/bin' }
love.filesystem.appendRecuirePath {
	'libraries',
	'modules',
	'src',
}

function love.conf(t)
	t.identity = nil
	t.appendidentity = true
	t.version = "11.4"
	t.console = true
	t.accelerometerjoystick = false
	t.externalstorage = false
	t.gammacorrect = false

	t.audio.mic = false
	t.audio.mixwithsystem = false

	t.window.title = "Window Title"
	t.window.icon = nil
	t.window.width = 256
	t.window.height = 144
	t.window.borderless = false
	t.window.resizable = false
	t.window.minwidth = 1920
	t.window.minheight = 1080
	t.window.fullscreen = false
	t.window.fullscreentype = "desktop"
	t.window.usedpiscale = false
	t.window.vsync = 0
	t.window.msaa = 0
	t.window.depth = nil
	t.window.stencil = false
	t.window.display = 1
	t.window.highdpi = false
	t.window.x = nil
	t.window.y = nil

	t.modules.audio = true
	t.modules.data = true
	t.modules.event = true
	t.modules.font = true
	t.modules.graphics = true
	t.modules.image = true
	t.modules.joystick = true
	t.modules.keyboard = true
	t.modules.math = true
	t.modules.mouse = true
	t.modules.physics = true
	t.modules.sound = true
	t.modules.system = true
	t.modules.thread = true
	t.modules.timer = true
	t.modules.touch = true
	t.modules.video = true
	t.modules.window = true

	-- io.stdout:setvbuf("no")
end