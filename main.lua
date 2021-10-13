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

	worldWidth = 1280
	worldHeight = 800
	canvasWidth = worldWidth + 200
	canvasHeight = worldHeight + 200
	
	buffer = love.graphics.newCanvas( canvasWidth, canvasHeight )
	buffer_x = ( love.graphics.getWidth() - worldWidth - 200 ) * 0.5
	buffer_y = ( love.graphics.getHeight() - worldHeight - 200 ) * 0.5

	viewport = love.graphics.newQuad( 100, 100, worldWidth + 100, worldHeight + 100, canvasWidth, canvasHeight )

	wrapZones = {
		topLeft = love.graphics.newQuad( 0, 0, 100, 100, canvasWidth, canvasHeight ),
		top = love.graphics.newQuad( 100, 0, worldWidth, 100, canvasWidth, canvasHeight ),
		topRight = love.graphics.newQuad( worldWidth + 100, 0, 100, 100, canvasWidth, canvasHeight ),
		left = love.graphics.newQuad( 0, 100, 100, worldHeight, canvasWidth, canvasHeight ),
		right = love.graphics.newQuad( worldWidth + 100, 100, 100, worldHeight, canvasWidth, canvasHeight ),
		bottomLeft = love.graphics.newQuad( 0, worldHeight + 100, 100, 100, canvasWidth, canvasHeight ),
		bottom = love.graphics.newQuad( 100, worldHeight + 100, worldWidth, 100, canvasWidth, canvasHeight ),
		bottomRight = love.graphics.newQuad( worldWidth + 100, worldHeight + 100, 100, 100, canvasWidth, canvasHeight )
	}

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
		wrapPosition( asteroids[i].position, 100, worldWidth + 100, 100, worldHeight + 100 )
	end

	for i = #bullets, 1, -1 do
		bullets[i]:update( dt )
		wrapPosition( bullets[i].position, 100, worldWidth + 100, 100, worldHeight + 100 )
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

	wrapPosition( playerShip.position, 100, worldWidth + 100, 100, worldHeight + 100 )

end

------------------------------------------------------------
--                       D R A W                          --
------------------------------------------------------------

function love.draw()

	love.graphics.clear( 0.08, 0.06, 0.08, 1 )

	love.graphics.setCanvas( buffer )

	love.graphics.clear( 1, 1, 1, 0 )

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
	
	love.graphics.setCanvas()

	love.graphics.setWireframe( false )

	--draw main canvas
	love.graphics.draw( buffer, buffer_x, buffer_y, 0, scale )

	--draw the 8 wrapzones
	love.graphics.draw( buffer, wrapZones.topLeft, buffer_x + worldWidth, buffer_y + worldHeight ) --topLeft
	love.graphics.draw( buffer, wrapZones.top, buffer_x + 100, buffer_y + worldHeight ) --top
	love.graphics.draw( buffer, wrapZones.topRight, buffer_x + 100, buffer_y + worldHeight ) --topRight
	love.graphics.draw( buffer, wrapZones.left, buffer_x + worldWidth, buffer_y + 100 ) --left
	love.graphics.draw( buffer, wrapZones.right, buffer_x + 100, buffer_y + 100 ) --right
	love.graphics.draw( buffer, wrapZones.bottomLeft, buffer_x + worldWidth, buffer_y + 100 ) --bottomLeft
	love.graphics.draw( buffer, wrapZones.bottom, buffer_x + 100, buffer_y + 100 ) --bottom
	love.graphics.draw( buffer, wrapZones.bottomRight, buffer_x + 100, buffer_y + 100 ) --bottomRight

	love.graphics.rectangle( "line", buffer_x + 100, buffer_y + 100, buffer:getWidth() - 200, buffer:getHeight() - 200 )
	love.graphics.rectangle( "line", buffer_x, buffer_y, buffer:getWidth(), buffer:getHeight() )

	if debugInfo then
		love.graphics.line( playerShip.position[1] + buffer_x, playerShip.position[2] + buffer_y, playerShip.position[1] + buffer_x + playerShip.posVel[1], playerShip.position[2] + buffer_y + playerShip.posVel[2] )
		love.graphics.print( love.report or "Please wait...", 0, 0 )
		love.graphics.print( "#bullets:"..#bullets.."\n#asteroids: "..#asteroids.."\nx: "..playerShip.position[1].."\ny: "..playerShip.position[2], 0, 450 )
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
