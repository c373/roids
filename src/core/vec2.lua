vec2 = { x = 0, y = 0 }

function vec2:new( x, y )
	o = o or {}
	setmetatable( o, self )
	self.__index = self
	self.x = x
	self.y = y
	return o
end
