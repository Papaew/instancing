local g = love.graphics
local lm = love.mouse
local Camera = {}

function Camera.new( cx,cy )
	local self = {}

	local x,y = cx or 0, cy or 0
	local scale = 1
	local active = false

	function self:set()
		if active then
			active = false
			g.pop()
		else
			g.push("transform")
			g.translate(x,y)
			g.scale(scale)
			active = true
		end
	end

	function self:getScreenPos( mx,my )
		return (mx-x)/scale, (my-y)/scale
	end

	function self:move( dx,dy )
		x = x + dx
		y = y + dy
	end

	function self:zoom( val )
		local factor = 0.8
		if val > 0 then
			factor = 1/factor
			-- if self.scale == self.maxZoom then return end
		else
			-- if self.scale == self.minZoom then return end
		end
		
		-- self.scale = clamp(round(self.scale*factor, 0.001), self.minZoom, self.maxZoom)
		scale = scale*factor

		local dx = (lm.getX()-x) * (factor-1)
		local dy = (lm.getY()-y) * (factor-1)

		x = x - dx
		y = y - dy
	end

	return self
end

return Camera