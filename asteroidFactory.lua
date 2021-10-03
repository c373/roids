asteroid = {
	model = {},
	position = nil,
	posVel = nil,
	rotation = nil,
	rotVel = nil
}

asteroid.__index = asteroid

function createAsteroid()

	local a = {}

	setmetatable( a, asteroid )

	a.model = love.graphics.newMesh( vertexListToVertexColorList( newAsteroidVertices( { min = 15, max = 30 } ) ), "fan", "dynamic" )
	a.position = { 0, 0 }
	a.posVel = { 200, 200 }
	a.rotation = 0
	a.rotVel = 1
	

	return a
end

function newAsteroidVertices( radiusRange )

	local angleRange = { min = 25, max = 50 }

	local angleEaten = 0

	local vertices = { 0, 0 }
	
	while angleEaten < 360 do

		local radius = love.math.random( radiusRange.min, radiusRange.max )

		local angle = love.math.random( angleRange.min, angleRange.max )

		if angleEaten + angle > 360 then
			angle = 360 - angleEaten
		end

		if 360 - angleEaten + angle < angleRange.min then
			break
		end

		angleEaten = angleEaten + angle

		local vertex = { 0, radius }
		rotate( vertex, math.rad( angleEaten ) )

		table.insert( vertices, vertex[1] )
		table.insert( vertices, vertex[2] )

	end

	vertices[#vertices + 1] = vertices[3]
	vertices[#vertices + 1] = vertices[4]

	return vertices

end