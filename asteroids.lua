function newAsteroid( radiusRange )

	local angleRange = { min = 25, max = 50 }

	local angleEaten = 0

	local vertices = { }
	
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

		local x, y = rotate( 0, radius, math.rad( angleEaten ) )

		table.insert( vertices, x )
		table.insert( vertices, y )

	end

	return vertices

end