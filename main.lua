require "asteroid"
require "ship"
require "bullet"
require "models"
require "utils"

local asteroids = {}

local bullets = {}

local player = ship:new( models.playerShip, true, { 0, 0 }, 0, { 0, 0 } )

function love.load()

	debugInfo = true

	if debugInfo then
		love.frame = 0
		love.profiler = require( "profile" )
		love.profiler.start()
	end

	asteroids[#asteroids + 1] = asteroid:new( math.random( 0, love.graphics.getWidth() ), math.random( 0, love.graphics.getHeight() ) )

	hit = false

	love.graphics.setDefaultFilter( "nearest", "nearest", 1 )
	
	--playable world size
	worldWidth = 960
	worldHeight = 540

	--total renderable canvas size
	wrapBufferOffset = 100
	bufferWidth = worldWidth + wrapBufferOffset * 2
	bufferHeight = worldHeight + wrapBufferOffset * 2
	buffer = love.graphics.newCanvas( bufferWidth, bufferHeight )

	wrapZones = {
		topLeft = love.graphics.newQuad( 0, 0, wrapBufferOffset, wrapBufferOffset, bufferWidth, bufferHeight ),
		top = love.graphics.newQuad( wrapBufferOffset, 0, worldWidth, wrapBufferOffset, bufferWidth, bufferHeight ),
		topRight = love.graphics.newQuad( worldWidth + wrapBufferOffset, 0, wrapBufferOffset, wrapBufferOffset, bufferWidth, bufferHeight ),
		left = love.graphics.newQuad( 0, wrapBufferOffset, wrapBufferOffset, worldHeight, bufferWidth, bufferHeight ),
		right = love.graphics.newQuad( worldWidth + wrapBufferOffset, wrapBufferOffset, wrapBufferOffset, worldHeight, bufferWidth, bufferHeight ),
		bottomLeft = love.graphics.newQuad( 0, worldHeight + wrapBufferOffset, wrapBufferOffset, wrapBufferOffset, bufferWidth, bufferHeight ),
		bottom = love.graphics.newQuad( wrapBufferOffset, worldHeight + wrapBufferOffset, worldWidth, wrapBufferOffset, bufferWidth, bufferHeight ),
		bottomRight = love.graphics.newQuad( worldWidth + wrapBufferOffset, worldHeight + wrapBufferOffset, wrapBufferOffset, wrapBufferOffset, bufferWidth, bufferHeight )
	}

	--quad that represents the viewport of the main playable area
	viewport = love.graphics.newQuad( wrapBufferOffset, wrapBufferOffset, worldWidth, worldHeight, bufferWidth, bufferHeight )
	

	if worldWidth / love.graphics.getWidth() > worldHeight / love.graphics.getHeight() then
		finalScale = love.graphics.getWidth() / worldWidth
	else
		finalScale = love.graphics.getHeight() / worldHeight
	end

	--the final buffer that is the world and all wrapped zones drawn
	--this buffer can be used to do final scaling and positioning of the final drawn image
	final = love.graphics.newCanvas( worldWidth, worldHeight )
	
	finalXOffset = ( love.graphics.getWidth() - ( worldWidth * finalScale ) ) * 0.5
	finalYOffset = ( love.graphics.getHeight() - ( worldHeight * finalScale ) ) * 0.5

	player.position[1] = wrapBufferOffset + ( worldWidth * 0.5 )
	player.position[2] = wrapBufferOffset + ( worldHeight * 0.5 )

end

------------------------------------------------------------
--	U P D A T E
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
		wrapPosition( asteroids[i].position, wrapBufferOffset, worldWidth + wrapBufferOffset, wrapBufferOffset, worldHeight + wrapBufferOffset )
	end

	for i = #bullets, 1, -1 do
		if bullets[i].alive then
			bullets[i]:update( dt )
			wrapPosition( bullets[i].position, wrapBufferOffset, worldWidth + wrapBufferOffset, wrapBufferOffset, worldHeight + wrapBufferOffset )
			if isPointInPolygon( bullets[i].position[1] - asteroids[1].position[1], bullets[i].position[2] - asteroids[1].position[2], asteroids[1].collisionBody ) then
				hit = true
			end
		end
	end

	if love.keyboard.isDown( "k" ) then
		player:accel( dt )
	end

	if love.keyboard.isDown( "d" ) then
		player:rotate( "left", dt )
	end

	if love.keyboard.isDown( "f" ) then
		player:rotate( "right", dt )
	end
	
	if love.keyboard.isDown( "r" ) then
		hit = false
	end

	player:update( dt )
	wrapPosition( player.position, wrapBufferOffset, worldWidth + wrapBufferOffset, wrapBufferOffset, worldHeight + wrapBufferOffset )

end

------------------------------------------------------------
--	D R A W
------------------------------------------------------------

function love.draw()

	love.graphics.setCanvas( buffer )

	love.graphics.clear( 1, 1, 1, 0 )

	love.graphics.setWireframe( true )

	if hit then love.graphics.setColor( 1, 0, 0, 1 ) end
	for i = 1, #asteroids do
		local a = asteroids[i]
		love.graphics.draw( a.model, a.position[1], a.position[2], a.rotation )
		love.graphics.setColor( 0, 1, 0, 0.25 )
		love.graphics.draw( a.drawableCollBody, a.position[1], a.position[2] )
	end
	love.graphics.setColor( 1, 1, 1, 1 )

	for i = 1, #bullets do
		if bullets[i].alive then
			local b = bullets[i]
			love.graphics.draw( b.model, b.position[1], b.position[2], b.rotation,	lerp( 1, 0.25, b.time / b.lifespan ) )
		end
	end

	--main ship model
	love.graphics.draw( player.model, player.position[1], player.position[2], player.rotation )
	
	love.graphics.setWireframe( false )

	love.graphics.setCanvas()

	love.graphics.setCanvas( final )

	love.graphics.clear( 0.08, 0.06, 0.08, 1 )

	--draw main canvas
	love.graphics.draw( buffer, viewport, 0, 0 )

	--draw the 8 wrapzones
	love.graphics.draw( buffer, wrapZones.topLeft, worldWidth - wrapBufferOffset, worldHeight - wrapBufferOffset ) --topLeft > bottomRight
	love.graphics.draw( buffer, wrapZones.top, 0, worldHeight - wrapBufferOffset ) --top > bottom
	love.graphics.draw( buffer, wrapZones.topRight, 0, worldHeight - wrapBufferOffset ) --topRight > bottomLeft
	love.graphics.draw( buffer, wrapZones.left, worldWidth - wrapBufferOffset, 0 ) --left > right
	love.graphics.draw( buffer, wrapZones.right, 0, 0 ) --right > left
	love.graphics.draw( buffer, wrapZones.bottomLeft, worldWidth - wrapBufferOffset, 0 ) --bottomLeft > topRight
	love.graphics.draw( buffer, wrapZones.bottom, 0, 0 ) --bottom > top
	love.graphics.draw( buffer, wrapZones.bottomRight, 0, 0 ) --bottomRight > topLeft

	love.graphics.setCanvas()

	love.graphics.draw( final, finalXOffset, finalYOffset, 0, finalScale )

	if debugInfo then
		love.graphics.line( ( player.position[1] - wrapBufferOffset ) * finalScale + finalXOffset, ( player.position[2] - wrapBufferOffset ) * finalScale + finalYOffset, ( player.position[1] + 20 * player.velocity[1] - wrapBufferOffset ) * finalScale + finalXOffset, ( player.position[2] + 20 * player.velocity[2] - wrapBufferOffset ) * finalScale + finalYOffset )
		love.graphics.print( love.report or "Please wait...", 0, 0 )
		love.graphics.print( "#bullets:"..#bullets.."\n#asteroids: "..#asteroids.."\nx: "..player.position[1].."\ny: "..player.position[2].."\nr: "..player.rotation.."\nastx:"..asteroids[1].position[1].."\nasty:"..asteroids[1].position[2], 0, 450 )
	end

end

------------------------------------------------------------
--	C A L L B A C K S
------------------------------------------------------------

function love.keypressed( key, scancode, isrepeat )

	if key == "escape" then
	   love.event.quit()
	end

	if key == "return" then
		asteroids[#asteroids + 1] = asteroid:new( math.random( 0, love.graphics.getWidth() ), math.random( 0, love.graphics.getHeight() ) )
	end

	if key == "j" then
		bullets[#bullets + 1] = bullet:new( models.bullet, player.position, player.rotation, player.velocity )
	end
	
 end
