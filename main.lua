require "asteroidFactory"
require "bulletFactory"
require "utils"

local asteroids = {}

local bullets = {}

local playerShip = {
	model = love.graphics.newMesh( { { -10, 10, 0, 0, 1, 1, 1, 1 }, { 10, 10, 0, 0, 1, 1, 1, 1 },  { 0, -20, 0, 0, 1, 1, 1, 1 } }, "fan", "dynamic" ),
	position = { 0, 0 },
	posVel = { 0, 0 },
	speed = 10,
	rotation = 0,
	rotVel = math.rad( 450 )
}

local boost = 2

function thurst( accelSpeed )

	local vel = {  0, -1 * accelSpeed }

	rotate( vel, playerShip.rotation )
		
	playerShip.posVel[1] = playerShip.posVel[1] + vel[1]
	playerShip.posVel[2] = playerShip.posVel[2] + vel[2]

end

function love.load()

	debugInfo = false

	if debugInfo then
		love.frame = 0
		love.profiler = require( "profile" )
		love.profiler.start()
	end

	asteroids[#asteroids + 1] = createAsteroid()

	love.graphics.setWireframe( true )

end

function love.update( dt )

	if debugInfo then
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

	for i = 1, #bullets do
		bullets[i]:update( dt )
	end

	playerShip.posVel[1] = playerShip.posVel[1] * 0.99
	playerShip.posVel[2] = playerShip.posVel[2] * 0.99

	if love.keyboard.isDown( "up" ) then
		
		thurst( 1 )

	end

	if love.keyboard.isDown( "left" ) then
		playerShip.rotation = playerShip.rotation - playerShip.rotVel * dt
	end
	if love.keyboard.isDown( "right" ) then
		playerShip.rotation = playerShip.rotation + playerShip.rotVel * dt
	end

	playerShip.position[1] = playerShip.position[1] + playerShip.posVel[1] * playerShip.speed * dt
	playerShip.position[2] = playerShip.position[2] + playerShip.posVel[2] * playerShip.speed * dt

	--wrap playerShip.position
	if playerShip.position[1] > love.graphics.getWidth() then
		playerShip.position[1] = 0
	elseif playerShip.position[1] < 0 then
		playerShip.position[1] = love.graphics.getWidth()
	end

	if playerShip.position[2] > love.graphics.getHeight() then
		playerShip.position[2] = 0
	elseif playerShip.position[2] < 0 then
		playerShip.position[2] = love.graphics.getHeight()
	end

	if love.keyboard.isDown( "space" ) then
		--bullets[#bullets + 1] = createBullet( playerShip.position, playerShip.rotation )
	end

	if love.keyboard.isDown( "x" ) then
		thurst( 2 )
	end

end


function love.draw()

	love.graphics.clear( 0.08, 0.06, 0.08, 1 )

	for i = 1, #asteroids do
		local a = asteroids[i]
		love.graphics.draw( a.model, a.position[1], a.position[2], a.rotation )
	end

	for i = 1, #bullets do
local b = bullets[i]
		love.graphics.draw( b.model, b.position[1], b.position[2], b.rotation )
	end

	--main ship model
	love.graphics.draw( playerShip.model, playerShip.position[1], playerShip.position[2], playerShip.rotation )

	--draw 4 additional ships to smoothly render wrap transitions
	love.graphics.draw( playerShip.model, playerShip.position[1] - love.graphics.getWidth(), playerShip.position[2], playerShip.rotation )
	love.graphics.draw( playerShip.model, playerShip.position[1] + love.graphics.getWidth(), playerShip.position[2], playerShip.rotation )
	love.graphics.draw( playerShip.model, playerShip.position[1], playerShip.position[2] - love.graphics.getHeight(), playerShip.rotation )
	love.graphics.draw( playerShip.model, playerShip.position[1], playerShip.position[2] + love.graphics.getHeight(), playerShip.rotation )

	if debugInfo then
		love.graphics.line( playerShip.position[1], playerShip.position[2], playerShip.position[1] + playerShip.posVel[1], playerShip.position[2] + playerShip.posVel[2] )

		love.graphics.setWireframe( false )
		love.graphics.print( love.report or "Please wait...", 0, 0 )
		love.graphics.setWireframe( true )
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

	if key == "space" then
		bullets[#bullets + 1] = createBullet( playerShip.position, playerShip.rotation )
	end
 end
