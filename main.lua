require "asteroid"
require "ship"
require "bullet"
require "models"
require "utils"

local asteroids = {}

local bullets = {}

local player = ship:new( models.playerShip, true, { 0, 0 }, 0, { 0, 0 } )

function love.load()

	--debugInfo = true

	screenwrap = love.graphics.newShader( "screenwrap.fs" )
	love.graphics.setShader( screenwrap )

	if debugInfo then
		love.frame = 0
		love.profiler = require( "profile" )
		love.profiler.start()
	end

	love.graphics.setDefaultFilter( "nearest", "nearest", 1 )

	--playable world size
	worldWidth = 640
	worldHeight = 480

	--total renderable canvas size (backbuffer)
	wrapOffset = 100
	bufferWidth = worldWidth + wrapOffset * 2
	bufferHeight = worldHeight + wrapOffset * 2
	buffer = love.graphics.newCanvas( bufferWidth, bufferHeight )

	--quad that represents the viewport of the main playable area
	viewport = love.graphics.newQuad( wrapOffset, wrapOffset, worldWidth, worldHeight, bufferWidth, bufferHeight )

	normalizedWidth = worldWidth / bufferWidth
	normalizedHeight = worldHeight / bufferHeight

	--screenwrap:send( "width", normalizedWidth )
	--screenwrap:send( "height", normalizedHeight )

	--generate a finalscale with which to draw the final buffer to the screen
	if worldWidth / love.graphics.getWidth() > worldHeight / love.graphics.getHeight() then
		finalScale = love.graphics.getWidth() / worldWidth
	else
		finalScale = love.graphics.getHeight() / worldHeight
	end

	--the final buffer that is the world and all wrapped zones drawn
	--this buffer can be used to do final scaling and positioning of the final drawn image
	final = love.graphics.newCanvas( worldWidth, worldHeight )

	--center the final buffer on the screen
	finalXOffset = ( love.graphics.getWidth() - ( worldWidth * finalScale ) ) * 0.5
	finalYOffset = ( love.graphics.getHeight() - ( worldHeight * finalScale ) ) * 0.5

	--center the player ship
	player.position[1] = wrapOffset + ( worldWidth * 0.5 )
	player.position[2] = wrapOffset + ( worldHeight * 0.5 )

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
		wrapPosition( asteroids[i].position, wrapOffset, worldWidth + wrapOffset, wrapOffset, worldHeight + wrapOffset )
	end

	for i = #bullets, 1, -1 do
		if bullets[i].alive then
			bullets[i]:update( dt )
			wrapPosition( bullets[i].position, wrapOffset, worldWidth + wrapOffset, wrapOffset, worldHeight + wrapOffset )
		end
	end

	if love.keyboard.isDown( "k" ) then
		player:accel( dt )
	end

	if love.keyboard.isDown( "d" ) then
		if love.keyboard.isDown( "s" ) then
			player:rotate( "left", true, dt )
		else
			player:rotate( "left", false, dt )
		end
	end

	if love.keyboard.isDown( "f" ) then
		if love.keyboard.isDown( "s" ) then
			player:rotate( "right", true, dt )
		else
			player:rotate( "right", false, dt )
		end
	end

	if love.keyboard.isDown( "r" ) then
		hit = false
	end

	if love.keyboard.isDown( "return" ) then
		asteroids[#asteroids + 1] = asteroid:new( math.random( 0, love.graphics.getWidth() ), math.random( 0, love.graphics.getHeight() ) )
	end

	player:update( dt )
	wrapPosition( player.position, wrapOffset, worldWidth + wrapOffset, wrapOffset, worldHeight + wrapOffset )

end

------------------------------------------------------------
--	D R A W
------------------------------------------------------------

function love.draw()

	love.graphics.setCanvas( buffer )
	
	love.graphics.clear( 1, 1, 1, 0 )

	--draw all the objects in white

	--draw the asteroids
	if hit then love.graphics.setColor( 1, 0, 0, 1 ) end

	for i = 1, #asteroids do
		local a = asteroids[i]
		love.graphics.draw( a.model, a.position[1], a.position[2], a.rotation )
	end

	--draw all bullets
	for i = 1, #bullets do
		if bullets[i].alive then
			local b = bullets[i]
			love.graphics.draw( b.model, b.position[1], b.position[2], b.rotation,	lerp( 1, 0.25, b.time / b.lifespan ) )
		end
	end

	--main ship model
	love.graphics.draw( player.model, player.position[1], player.position[2], player.rotation )

	--draw all the black objects
	love.graphics.setColor( 0, 0, 0, 1 )

	for i = 1, #asteroids do
		local a = asteroids[i]
		love.graphics.draw( a.model, a.position[1], a.position[2], a.rotation, 0.93 )
	end

	love.graphics.draw( player.model, player.position[1], player.position[2], player.rotation, 0.85 )

	love.graphics.setColor( 1, 1, 1, 1 )

	love.graphics.setCanvas()

	love.graphics.setCanvas( final )

	love.graphics.clear( 0, 0, 0, 1 )

	--draw main canvas
	love.graphics.draw( buffer, viewport, 0, 0 )

	love.graphics.setCanvas()

	love.graphics.draw( final, finalXOffset, finalYOffset, 0, finalScale )

	if debugInfo then
		love.graphics.line( ( player.position[1] - wrapOffset ) * finalScale + finalXOffset, ( player.position[2] - wrapOffset ) * finalScale + finalYOffset, ( player.position[1] + 20 * player.velocity[1] - wrapOffset ) * finalScale + finalXOffset, ( player.position[2] + 20 * player.velocity[2] - wrapOffset ) * finalScale + finalYOffset )
		love.graphics.print( love.report or "Please wait...", 0, 0 )
		love.graphics.print( "#bullets:"..#bullets.."\n#asteroids: "..#asteroids.."\nx: "..player.position[1].."\ny: "..player.position[2].."\nr: "..player.rotation, 0, 450 )
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
