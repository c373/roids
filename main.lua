require "asteroid"
require "bullet"
require "utils"

local asteroids = {}

local bullets = {}

local playerShip = {
	model = love.graphics.newMesh(
		{ 
			{ -10, 10, 0, 0, 1, 1, 1, 1 },
			{ 10, 10, 0, 0, 1, 1, 1, 1 }, 
			{ 0, -20, 0, 0, 1, 1, 1, 1 }
		},
		"fan",
		"dynamic"
	),
	position = { 0, 0 },
	posVel = { 0, 0 },
	speed = 500,
	rotation = 0,
	rotSpeed = math.rad( 360 )
}

function thrust( dt )

	local newVel = { 0, -2 }
	rotate( newVel, playerShip.rotation )
	playerShip.posVel[1] = playerShip.posVel[1] + newVel[1] * dt
	playerShip.posVel[2] = playerShip.posVel[2] + newVel[2] * dt

end

function love.load()

	debugInfo = false

	if debugInfo then
		love.frame = 0
		love.profiler = require( "profile" )
		love.profiler.start()
	end

	asteroids[#asteroids + 1] = asteroid:new( 0, 0 )

	love.graphics.setDefaultFilter( "nearest", "nearest", 1 )

	worldWidth = 1024
	worldHeight = 576
	
	buffer = love.graphics.newCanvas( worldWidth + 200, worldHeight + 200 )
	buffer:setWrap( "repeat", "repeat" )
	--bufferQ = love.graphics.newQuad( 100, 100, worldWidth, worldHeight, worldWidth + 200, worldHeight + 200 )
	bufferQ = love.graphics.newQuad( 0, 0, love.graphics.getWidth(), love.graphics.getHeight(), worldWidth + 200, worldHeight + 200 )

	scale = love.graphics.getWidth() / worldWidth
	scale = love.graphics.getHeight() / worldHeight
	scale = 1
	screenx = ( love.graphics.getWidth() - ( worldWidth * scale ) ) / 2
	screeny = ( love.graphics.getHeight() - ( worldHeight * scale ) ) / 2

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

	for i = #asteroids, 1, -1 do
		asteroids[i]:update( dt )
		if asteroids[i].position[1] < -asteroids[i].bounds or asteroids[i].position[2] < -asteroids[i].bounds or asteroids[i].position[1] > love.graphics.getWidth() + asteroids[i].bounds or asteroids[i].position[2] > love.graphics.getHeight() + asteroids[i].bounds then
			table.remove( asteroids, i )
		end
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

	if playerShip.position[1] < 100 then
		playerShip.position[1] = worldWidth + 100
	elseif playerShip.position[1] > worldWidth + 100 then
		playerShip.position[1] = 100
	end
	if playerShip.position[2] < 100 then
		playerShip.position[2] = worldHeight + 100
	elseif playerShip.position[2] > worldHeight + 100 then
		playerShip.position[2] = 100
	end

end

------------------------------------------------------------
--                       D R A W                          --
------------------------------------------------------------

function love.draw()

	love.graphics.setCanvas( buffer )

	love.graphics.setWireframe( true )

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
	
	love.graphics.setCanvas()

	love.graphics.setWireframe( false )

	--love.graphics.draw( buffer, bufferQ, screenx, screeny, 0, scale )
	love.graphics.draw( buffer, bufferQ, 0, 0, 0, scale )

	if debugInfo then
		love.graphics.line( playerShip.position[1], playerShip.position[2], playerShip.position[1] + playerShip.posVel[1], playerShip.position[2] + playerShip.posVel[2] )
		love.graphics.print( love.report or "Please wait...", 0, 0 )
		love.graphics.print( "velx:"..playerShip.posVel[1].."\nvely:"..playerShip.posVel[2].."\n#bullets:"..#bullets.."\n#asteroids: "..#asteroids.."\nx: "..playerShip.position[1].."\ny: "..playerShip.position[2], 0, 450 )
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
		asteroids[#asteroids + 1] = asteroid:new( 0, 0 )
	end

	if key == "j" then
		bullets[#bullets + 1] = bullet:new( playerShip.position, playerShip.rotation, playerShip.posVel )
	end
	
 end
