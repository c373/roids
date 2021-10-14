require "utils"

ship = {
	model = nil,
	player = false,
	position = { 0, 0 },
	direction = { 0, -1 },
	velocity = { 0, 0 },
	speed = 500,
	rotation = 0,
	rotationSpeed = 6.28
}

function ship:new( model, player, position, rotation, vel )

	local s = {}
	self.__index = self
	setmetatable( s, ship )

	s.model = model or models.playerShip
	s.player = player or false
	s.position = position or { 0, 0 }
	s.rotation = rotation or 0
	s.direction = { 0, -1 }
	s.velocity = vel or { 0, 0 }
	s.speed = self.speed
	s.rotationSpeed = self.rotationSpeed

	return s

end

function ship:update( dt )

	self.position[1] = self.position[1] + self.velocity[1] * self.speed * dt
	self.position[2] = self.position[2] + self.velocity[2] * self.speed * dt

	if self.player then
		--decay ship velocity
		self.velocity[1] = self.velocity[1] - ( self.velocity[1] * dt * 0.5 )
		self.velocity[2] = self.velocity[2] - ( self.velocity[2] * dt * 0.5 )
	end

end

function ship:accel( dt )

	rotate( self.direction, self.rotation )
	self.velocity[1] = self.velocity[1] + self.direction[1] * dt
	self.velocity[2] = self.velocity[2] + self.direction[2] * dt
	self.direction[1], self.direction[2] = 0, -2

end

function ship:rotate( direction, dt )

	if direction == "right" then
		self.rotation = self.rotation + self.rotationSpeed * dt
	elseif direction == "left" then
		self.rotation = self.rotation - self.rotationSpeed * dt
	end

	if self.rotation > 6.28 then
		self.rotation = 6.28 - self.rotation
	elseif self.rotation < 0 then
		self.rotation = self.rotation + 6.28
	end
end
