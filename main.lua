require "asteroidFactory"
require "utils"

local asteroids = {}
local playerShip = {
	model = love.graphics.newMesh( { { -10, 10, 0, 0, 1, 1, 1, 1 }, { 10, 10, 0, 0, 1, 1, 1, 1 },  { 0, -20, 0, 0, 1, 1, 1, 1 } }, "fan", "dynamic" ),
	position = { 0, 0 },
	posVel = { 0, 0 },
	speed = 300,
	rotation = 0
}

function love.load()

	debug = false

	if debug then
		love.frame = 0
		love.profiler = require( "profile" )
		love.profiler.start()
	end

	asteroids[#asteroids + 1] = createAsteroid()

	love.graphics.setWireframe( true )

end

function love.update( dt )

	if debug then
		love.frame = love.frame + 1

		if love.frame % 100 == 0 then
			love.report = love.profiler.report( 20 )
			love.profiler.reset()
		end
	end

	for i = 1, #asteroids do
		
		asteroids[i].position[1] = asteroids[i].position[1] + asteroids[i].posVel[1] * dt
		asteroids[i].position[2] = asteroids[i].position[2] + asteroids[i].posVel[2] * dt
		asteroids[i].rotation = asteroids[i].rotation + asteroids[i].rotVel * dt

	end

	playerShip.posVel[1] = playerShip.posVel[1] * 0.99
	playerShip.posVel[2] = playerShip.posVel[2] * 0.99

	if love.keyboard.isDown( "up" ) then
		local vel = {  0, -1 }

		rotate( vel, playerShip.rotation )
		
		playerShip.posVel[1] = playerShip.posVel[1] + vel[1]
		playerShip.posVel[2] = playerShip.posVel[2] + vel[2]

		normalize( playerShip.posVel )

	end

	if love.keyboard.isDown( "left" ) then
		playerShip.rotation = playerShip.rotation - math.rad( 180 * dt )
	end
	if love.keyboard.isDown( "right" ) then
		playerShip.rotation = playerShip.rotation + math.rad( 180 * dt )
	end

	playerShip.position[1] = playerShip.position[1] + playerShip.posVel[1] * playerShip.speed * dt
	playerShip.position[2] = playerShip.position[2] + playerShip.posVel[2] * playerShip.speed * dt

end


function love.draw()

	for i = 1, #asteroids do
		local a = asteroids[i]
		love.graphics.draw( a.model, a.position[1], a.position[2], a.rotation )
	end

	love.graphics.draw( playerShip.model, playerShip.position[1], playerShip.position[2], playerShip.rotation )

	love.graphics.line( playerShip.position[1], playerShip.position[2], playerShip.position[1] + playerShip.posVel[1], playerShip.position[2] + playerShip.posVel[2] )

	if debug then
		love.graphics.push()
		love.graphics.setWireframe( false )
		love.graphics.print( love.report or "Please wait...", 0, 0 )
		love.graphics.pop()
	end

end

------------------------------------------------------------
--                   C A L L B A C K S                    --
------------------------------------------------------------

function love.keypressed( key, scancode, isrepeat )
	if key == "escape" then
	   love.event.quit()
	end

	if key == "return" then
		asteroids[#asteroids + 1] = createAsteroid()
	end
 end