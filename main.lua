require "asteroidFactory"
require "bullet"
require "utils"

local asteroids = {}

local bullets = {}

local playerShip = {
	model = love.graphics.newMesh( { { -10, 10, 0, 0, 1, 1, 1, 1 }, { 10, 10, 0, 0, 1, 1, 1, 1 },  { 0, -20, 0, 0, 1, 1, 1, 1 } }, "fan", "dynamic" ),
	position = { 0, 0 },
	posVel = { 0, 0 },
	speed = 500,
	rotation = 0,
	rotSpeed = math.rad( 540 )
}

function thrust( dt )

	local newVel = { 0, -2 }
	rotate( newVel, playerShip.rotation )
	playerShip.posVel[1] = playerShip.posVel[1] + ( newVel[1] * dt )
	playerShip.posVel[2] = playerShip.posVel[2] + ( newVel[2] * dt )


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

------------------------------------------------------------
--                     U P D A T E                        --
------------------------------------------------------------

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

	for i = #bullets, 1, -1 do
		bullets[i]:update( dt )
	end

	if love.keyboard.isDown( "k" ) then
		thrust( dt )
	end

	if love.keyboard.isDown( "d" ) then
		playerShip.rotation = playerShip.rotation - playerShip.rotSpeed * dt
	end
	if love.keyboard.isDown( "f" ) then
		playerShip.rotation = playerShip.rotation + playerShip.rotSpeed * dt
	end

	playerShip.position[1] = playerShip.position[1] + playerShip.posVel[1] * playerShip.speed * dt
	playerShip.position[2] = playerShip.position[2] + playerShip.posVel[2] * playerShip.speed * dt

	--decay playerShip velocity
	playerShip.posVel[1] = playerShip.posVel[1] - ( playerShip.posVel[1] * dt * 0.5 )
	playerShip.posVel[2] = playerShip.posVel[2] - ( playerShip.posVel[2] * dt * 0.5 )

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

end

------------------------------------------------------------
--                       D R A W                          --
------------------------------------------------------------

function love.draw()

	love.graphics.clear( 0.08, 0.06, 0.08, 1 )

	love.graphics.setWireframe( false )
	love.graphics.print( "velx:"..playerShip.posVel[1].."vely:"..playerShip.posVel[2].."#bullets:"..#bullets )
	love.graphics.setWireframe( true )

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

	--draw 8 additional ships to smoothly render wrap transitions
	love.graphics.draw( playerShip.model, playerShip.position[1] - love.graphics.getWidth(), playerShip.position[2], playerShip.rotation )
	love.graphics.draw( playerShip.model, playerShip.position[1] + love.graphics.getWidth(), playerShip.position[2], playerShip.rotation )
	love.graphics.draw( playerShip.model, playerShip.position[1], playerShip.position[2] - love.graphics.getHeight(), playerShip.rotation )
	love.graphics.draw( playerShip.model, playerShip.position[1], playerShip.position[2] + love.graphics.getHeight(), playerShip.rotation )

	--corners
	love.graphics.draw( playerShip.model, playerShip.position[1] - love.graphics.getWidth(), playerShip.position[2] - love.graphics.getHeight(), playerShip.rotation )
	love.graphics.draw( playerShip.model, playerShip.position[1] + love.graphics.getWidth(), playerShip.position[2] + love.graphics.getHeight(), playerShip.rotation )
	love.graphics.draw( playerShip.model, playerShip.position[1] + love.graphics.getWidth(), playerShip.position[2] - love.graphics.getHeight(), playerShip.rotation )
	love.graphics.draw( playerShip.model, playerShip.position[1] - love.graphics.getWidth(), playerShip.position[2] + love.graphics.getHeight(), playerShip.rotation )
	
	if debugInfo then
		love.graphics.line( playerShip.position[1], playerShip.position[2], playerShip.position[1] + playerShip.posVel[1], playerShip.position[2] + playerShip.posVel[2] )

		love.graphics.setWireframe( false )
		love.graphics.print( love.report or "Please wait...", 0, 0 )
		love.graphics.setWireframe( true )
	end

end

------------------------------------------------------------
--                  C A L L B A C K S                     --
------------------------------------------------------------

function love.keypressed( key, scancode, isrepeat )

	if key == "escape" then
	   love.event.quit()
	end

	if key == "return" then
		asteroids[#asteroids + 1] = createAsteroid()
	end

	if key == "j" then
		bullets[#bullets + 1] = bullet:new( playerShip.position, playerShip.rotation, playerShip.posVel )
	end
	
 end
