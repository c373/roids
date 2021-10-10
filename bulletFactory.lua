bullet = {
	model = {},
	position = nil,
	posVel = { 0, 0 },
	speed = 10,
	rotation = 0
}

function bullet:createBullet( position, rotation, vel )

	local b = {}

	setmetatable( b, self )

	self.__index = self

	self.model = love.graphics.newMesh( { { -2, -2, 0, 0, 1, 1, 1, 1 }, { 2, -2, 0, 0, 1, 1, 1, 1 },  { 2, 2, 0, 0, 1, 1, 1, 1 }, { -2, 2, 0, 0, 1, 1, 1, 1 } }, "fan", "dynamic" )

	self.position = { position[1], position[2] }

	local offset = { 0, -10 }

	rotate( offset, rotation )

	self.position[1] = self.position[1] + offset[1]
	self.position[2] = self.position[2] + offset[2]

	local bVel = { 0, -1 }

	rotate( bVel, rotation )

	self.posVel = bVel
	self.rotation = rotation

	return b

end

function bullet:update( dt )

	self.position[1] = self.position[1] + self.posVel[1] * self.speed * dt
	self.position[2] = self.position[2] + self.posVel[2] * self.speed * dt
	
end