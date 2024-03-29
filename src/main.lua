require "asteroid"
require "ship"
require "bullet"
require "models"
require "utils"

local asteroids = {}

local bullets = {}

local player = ship:new( models.playerShip, true, { 0, 0 }, 0, { 0, 0 } )

function love.load()

	showDebugInfo = false

	screenwrap = love.graphics.newShader( "screenwrap.fs" )
	outline = love.graphics.newShader( "outline.fs" )

	if showDebugInfo then
		love.frame = 0
		love.profiler = require( "profile" )
		love.profiler.start()
	end

	love.graphics.setDefaultFilter( "nearest", "nearest", 1 )
	clearColor = { 0.125, 0.153, 0.153, 1 }
	white = { 0.824, 0.839, 0.847, 1 }

	--playable world size
	worldWidth, worldHeight = love.window.getMode()

	--total renderable canvas size (backbuffer)
	wrapOffset = worldHeight * 0.25
	bufferWidth = worldWidth + wrapOffset * 2
	bufferHeight = worldHeight + wrapOffset * 2
	buffer = love.graphics.newCanvas( bufferWidth, bufferHeight )
	buffer_2 = love.graphics.newCanvas( bufferWidth, bufferHeight )

	-- send the size of the world as a uv relative to the total buffer size for sampling
	screenwrap:send( "width", worldWidth / bufferWidth )
	screenwrap:send( "height", worldHeight / bufferHeight )
	-- currently the wrap shader is being applied before the final crop to the visible playing area
	screenwrap:send( "offsetWidth", wrapOffset / bufferWidth )
	screenwrap:send( "offsetHeight", wrapOffset / bufferHeight )
	screenwrap:send( "dblOffsetWidth", ( wrapOffset / bufferWidth ) * 2 )
	screenwrap:send( "dblOffsetHeight", ( wrapOffset / bufferHeight ) * 2 )

	--quad that represents the viewport of the main playable area
	viewport = love.graphics.newQuad( wrapOffset, wrapOffset, worldWidth, worldHeight, bufferWidth, bufferHeight )

	if worldWidth / love.graphics.getWidth() > worldHeight / love.graphics.getHeight() then
		finalScale = love.graphics.getWidth() / worldWidth
	else
		finalScale = love.graphics.getHeight() / worldHeight
	end

	finalX = ( love.graphics.getWidth() - worldWidth * finalScale ) * 0.5
	finalY = ( love.graphics.getHeight() - worldHeight * finalScale ) * 0.5

	--center the player ship
	player.position[1] = wrapOffset + ( worldWidth * 0.5 )
	player.position[2] = wrapOffset + ( worldHeight * 0.5 )

end

------------------------------------------------------------
--	U P D A T E
------------------------------------------------------------

function love.update( dt )

	if showDebugInfo then
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

	-- handle player input
	if love.keyboard.isDown( "k" ) then
		player:accel( dt )
	end

	precise = love.keyboard.isDown( "lshift" ) or love.keyboard.isDown( "rshift" )

	if love.keyboard.isDown( "d" ) then
		player:rotate( "left", precise, dt )
	end

	if love.keyboard.isDown( "f" ) then
		player:rotate( "right", precise, dt )
	end

	if love.keyboard.isDown( "r" ) then
		hit = false
	end

	if love.keyboard.isDown( "return" ) then
		--		asteroids[#asteroids + 1] = asteroid:new( math.random( 0, love.graphics.getWidth() ), math.random( 0, love.graphics.getHeight() ) )
	end

	player:update( dt )
	wrapPosition( player.position, wrapOffset, worldWidth + wrapOffset, wrapOffset, worldHeight + wrapOffset )

end

------------------------------------------------------------
--	D R A W
------------------------------------------------------------

function love.draw()

	love.graphics.clear( clearColor )

	love.graphics.setCanvas( buffer )
	love.graphics.clear( 1, 1, 1, 0 )
	love.graphics.setColor( white )

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
			love.graphics.draw( b.model, b.position[1], b.position[2], b.rotation )
		end
	end

	--main ship model
	love.graphics.draw( player.model, player.position[1], player.position[2], player.rotation )


	love.graphics.setCanvas( buffer_2 )
	love.graphics.clear( 1, 1, 1, 0 )
	-- first pass for the outline
	love.graphics.setShader( outline )
	love.graphics.draw( buffer )

	love.graphics.setCanvas()

	-- second pass for the screenwrap
	love.graphics.setShader( screenwrap )
	love.graphics.draw( buffer_2, viewport, finalX, finalY, 0, finalScale )

	if showDebugInfo then
		love.graphics.push()
		love.graphics.translate( -wrapOffset, -wrapOffset )
		love.graphics.circle( "line", player.position[1], player.position[2], 1 )
		love.graphics.circle( "line", player.position[1], player.position[2], 20 )
		love.graphics.pop()
	end

	if showDebugInfo then
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
