bullet = {
	model = {},
	position = nil,
	posVel = { 0, 0 },
	speed = 1000,
	rotation = 0
}

bullet.__index = bullet

function createBullet( position, rotation )

	local b = {}

	setmetatable( b, bullet )

	b.model = love.graphics.newMesh( { { -2, -2, 0, 0, 1, 1, 1, 1 }, { 2, -2, 0, 0, 1, 1, 1, 1 },  { 2, 2, 0, 0, 1, 1, 1, 1 }, { -2, 2, 0, 0, 1, 1, 1, 1 } }, "fan", "dynamic" )

	b.position = { position[1], position[2] }

	local bVel = { 0, -1 }

	rotate( bVel, rotation )

	b.posVel = bVel
	b.rotation = rotation

	return b

end

function bullet:update( dt )

	self.position[1] = self.position[1] + self.posVel[1] * self.speed * dt
	self.position[2] = self.position[2] + self.posVel[2] * self.speed * dt
	
end