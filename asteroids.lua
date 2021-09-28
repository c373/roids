function rotate( x, y, a )

	local c = math.cos( a )
	local s = math.sin( a )

	return c*x - s*y, s*x + c*y

end

function vertexListToVertexColorList( vertices )

	local vertexColorList = {}

	for i = 1, #vertices, 2 do
		table.insert( vertexColorList, { vertices[i], vertices[i + 1], 0, 0, 1, 1, 1, 1 } )
	end

	return vertexColorList

end

function newAsteroid( radiusRange )

	local angleRange = { min = 25, max = 50 }

	local angleEaten = 0

	local vertices = { 0, 0 }
	
	while angleEaten < 360 do

		local radius = love.math.random( radiusRange.min, radiusRange.max )
		--local radius = 100

		local angle = love.math.random( angleRange.min, angleRange.max )
		--local angle = 30

		if angleEaten + angle > 360 then
			angle = 360 - angleEaten
		end

		if 360 - angleEaten + angle < angleRange.min then
			break
		end

		angleEaten = angleEaten + angle

		local x, y = rotate( 0, radius, math.rad( angleEaten ) )

		table.insert( vertices, x )
		table.insert( vertices, y )

	end

	table.insert( vertices, vertices[3] )
	table.insert( vertices, vertices[4] )  

	return vertexListToVertexColorList( vertices )

end