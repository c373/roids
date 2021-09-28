require "callbacks"
require "asteroids"

function createAsteroid()

	asteroid = love.graphics.newMesh(
		newAsteroid( { min = 15, max = 30 } ),
		"fan",
		"dynamic"
	)

end

function love.load()

	love.frame = 0
	love.profiler = require( "profile" )
	love.profiler.start()

	love.graphics.setWireframe( true )

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

	love.graphics.draw( asteroid, 400, 300 )

	love.graphics.setWireframe( false )

	--love.graphics.print( love.report or "Please wait...", 0, 0 )

end