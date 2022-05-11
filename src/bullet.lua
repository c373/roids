bullet = {
	model = nil, 
	position = { 0, 0 },
	vel = { 0, -1 },
	speed = 750,
	rotation = 0,
	alive = false,
	time = 0,
	lifespan = 0.75
}

function bullet:new( model, position, rotation, vel )

	local b = {}

	self.__index = self
	setmetatable( b, bullet )

	local offset = { 0, -10 }
	rotate( offset, rotation )

	b.model = model
	b.position = { position[1] + offset[1], position[2] + offset[2] }
	b.vel = { 0, -2 }
	rotate( b.vel, rotation )
	local v = { vel[1], vel[2] }
	b.vel[1] = b.vel[1] + vel[1] * 0.5
	b.vel[2] = b.vel[2] + vel[2] * 0.5
	b.rotation = rotation or 0
	b.alive = true
	b.time = 0

	return b

end

function bullet:update( dt )

	self.time = self.time + dt

	if self.time > self.lifespan then
		self.alive = false
	end

	self.position[1] = self.position[1] + self.vel[1] * self.speed * dt
	self.position[2] = self.position[2] + self.vel[2] * self.speed * dt

end
