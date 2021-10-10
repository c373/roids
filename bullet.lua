bullet = {}

bullet.model = love.graphics.newMesh(
	{
		{ -2, -2, 0, 0, 1, 1, 1, 1 },
		{ 2, -2, 0, 0, 1, 1, 1, 1 }, 
		{ 2, 2, 0, 0, 1, 1, 1, 1 },
		{ -2, 2, 0, 0, 1, 1, 1, 1 }
	},
	"fan",
	"dynamic"
)

bullet.position = { 0, 0 }
bullet.vel = { 0, -1 }
bullet.speed = 1000
bullet.rotation = 0

function bullet:new( position, rotation, vel )

	local b = {}

	self.__index = self
	setmetatable( b, bullet )

	local offset = { 0, -10 }
	rotate( offset, rotation )

	b.position = { position[1] + offset[1], position[2] + offset[2] }
	b.vel = { 0, -1 }
	rotate( b.vel, rotation )
	b.vel[1] = b.vel[1] + vel[1]
	b.vel[2] = b.vel[2] + vel[2]
	b.rotation = rotation

	return b

end

function bullet:update( dt )

	self.position[1] = self.position[1] + self.vel[1] * self.speed * dt
	sself.position[2] = self.position[2] + self.vel[2] * self.speed * dt

end