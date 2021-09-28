require "callbacks"
require "asteroids"

function createAsteroid()

	--[[asteroid = love.graphics.newMesh(
		newAsteroid( { min = 15, max = 30 } ),
		"fan",
		"dynamic"
	)]]--

	asteroid = newAsteroid( { min = 15, max = 30 } )

	for i = 1, #asteroid do
		if ( i - 1 ) % 2 == 0 then
			asteroid[i] = asteroid[i] + love.graphics.getWidth() * 0.5
		else
			asteroid[i] = asteroid[i] + love.graphics.getHeight() * 0.5
		end
	end

end

function love.load()

	love.frame = 0
	love.profiler = require( "profile" )
	love.profiler.start()

	createAsteroid()

end

function love.update( dt )

	love.frame = love.frame + 1

	if love.frame % 100 == 0 then
		love.report = love.profiler.report( 20 )
		love.profiler.reset()
	end

end


function love.draw()

	love.graphics.setWireframe( true )

	love.graphics.polygon( "line", asteroid )

	love.graphics.setWireframe( false )

	--love.graphics.print( love.report or "Please wait...", 0, 0 )

end