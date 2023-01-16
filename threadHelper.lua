function newThread( file, ... )
	local thread = love.thread.newThread(file)
	local input  = love.thread.newChannel()
	local output = love.thread.newChannel()

	thread:start(input, output, ...)
	return thread, input, output
end

function newThreadGroup( count, file, ... )
	local threads  = {}
	local channels = {}
	for i=1, count do
		local thread = love.thread.newThread(file)
		local input  = love.thread.newChannel()
		local output = love.thread.newChannel()

		table.insert(threads, thread)
		table.insert(channels, {input, output})

		thread:start(input, output, ...)
	end

	return threads, channels
end
