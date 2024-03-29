asteroid = {}

asteroid.model = nil
asteroid.position = { 0, 0 }
asteroid.posVel = { 0, 0 }
asteroid.speed = 0
asteroid.rotation = 0
asteroid.rotVel = 0

function asteroid:new( x, y )

	local a = {}

	self.__index = self
	setmetatable( a, asteroid )

	local vertices = newAsteroidVertices( { min = 15, max = 22.5 } )
	a.model = love.graphics.newMesh( triangluatedVerticesToVertexColor( vertices ), "triangles", "dynamic" )
	a.position = { x, y }
	a.posVel = { math.random( -1, 1 ), math.random( -1, 1 ) }
	a.speed = math.random( 0, 300 )
	a.rotation = math.random( 0, 6.28 )
	a.rotVel = math.random( -3.14, 3.14 )

	return a

end

function asteroid:update( dt )

	self.position[1] = self.position[1] + self.posVel[1] * self.speed * dt
	self.position[2] = self.position[2] + self.posVel[2] * self.speed * dt

	local rotationDelta = self.rotVel * dt
	self.rotation = self.rotation + rotationDelta

end

function newAsteroidVertices( radiusRange )

	local angleRange = { min = 15, max = 60 }

	local angleEaten = 0

	local vertices = {}

	while angleEaten < 360 do

		local radius = love.math.random( radiusRange.min, radiusRange.max )

		local angle = love.math.random( angleRange.min, angleRange.max )

		if angleEaten + angle > 360 then
			angle = 360 - angleEaten
		end

		if 360 - ( angleEaten + angle ) < angleRange.min then
			break
		end

		angleEaten = angleEaten + angle

		local vertex = { 0, radius }
		rotate( vertex, math.rad( angleEaten ) )

		table.insert( vertices, vertex[1] )
		table.insert( vertices, vertex[2] )

	end

	return love.math.triangulate( vertices )

end
