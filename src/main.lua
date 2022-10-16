require "asteroid"
require "ship"
require "bullet"
local models = require "models"
require "utils"

--------------------------------------------------------------------------------
--																			  --
--									GLOBALS									  --
--																			  --
--------------------------------------------------------------------------------

local asteroids = {}
local bullets = {}
local player = ship:new( love.graphics.newMesh(models.player, "fan", "dynamic"), true )

local COLORS = {
	BLACK = { 0.125, 0.153, 0.153, 1 },
	WHITE = { 0.824, 0.839, 0.847, 1 }
}

--------------------------------------------------------------------------------
--																			  --
--									INIT									  --
--																			  --
--------------------------------------------------------------------------------

function love.load()

	showDebugInfo = false
	printProfiler = false

	screenwrap = love.graphics.newShader( "shaders/screenwrap.fs" )
	outline = love.graphics.newShader( "shaders/outline.fs" )

	love.graphics.setDefaultFilter( "nearest", "nearest", 1 )

	-- playable world size
	worldWidth, worldHeight = love.window.getMode()

	-- total renderable canvas size (backbuffer)
	bufferPadding = worldHeight * 0.25
	bufferWidth = worldWidth + bufferPadding * 2
	bufferHeight = worldHeight + bufferPadding * 2

	-- real world limits
	worldLimits = {
		LEFT = bufferPadding,
		TOP = bufferPadding,
		RIGHT = worldWidth + bufferPadding,
		BOTTOM = worldHeight + bufferPadding
	}

	drawBufferMain = love.graphics.newCanvas( bufferWidth, bufferHeight )
	drawBufferSec = love.graphics.newCanvas( bufferWidth, bufferHeight )

	-- set necesary parameters for the screenwrap shader
	-- send the size of the world as a uv relative to the total buffer size for sampling
	screenwrap:send( "width", worldWidth / bufferWidth )
	screenwrap:send( "height", worldHeight / bufferHeight )

	-- currently the wrap shader is being applied before the final crop to the visible playing area
	screenwrap:send( "offsetWidth", bufferPadding / bufferWidth )
	screenwrap:send( "offsetHeight", bufferPadding / bufferHeight )
	screenwrap:send( "dblOffsetWidth", ( bufferPadding / bufferWidth ) * 2 )
	screenwrap:send( "dblOffsetHeight", ( bufferPadding / bufferHeight ) * 2 )

	-- quad that represents the viewport of the main playable area
	viewport = love.graphics.newQuad(
		bufferPadding,
		bufferPadding,
		worldWidth,
		worldHeight,
		bufferWidth,
		bufferHeight
	)

	-- determine the final scale the viewport should be drawn at so that the
	-- longest dimension of the world is drawn edge to edge on the window
	if worldWidth / love.graphics.getWidth() > worldHeight / love.graphics.getHeight() then
		viewportScale = love.graphics.getWidth() / worldWidth
	else
		viewportScale = love.graphics.getHeight() / worldHeight
	end

	-- determine the final required offset to position the viewport on the
	-- center of the screen (will zero out unless the world is smaller than the
	-- window size)
	viewportPosX = ( love.graphics.getWidth() - worldWidth * viewportScale ) * 0.5
	viewportPosY = ( love.graphics.getHeight() - worldHeight * viewportScale ) * 0.5

	-- center the player ship
	-- player.position[1] = bufferPadding + ( worldWidth * 0.5 )
	-- player.position[2] = bufferPadding + ( worldHeight * 0.5 )
	player.position[1] = bufferWidth * 0.5
	player.position[2] = bufferHeight * 0.5


	-- DEBUG
	love.frame = 0
	love.profiler = require( "lib.profile" )
	love.profiler.start()

	if bufferWidth / love.graphics.getWidth() > bufferHeight / love.graphics.getHeight() then
		debugScale = love.graphics.getWidth() / bufferWidth
	else
		debugScale = love.graphics.getHeight() / bufferHeight
	end

	debugPosX = ( love.graphics.getWidth() - bufferWidth * debugScale ) * 0.5
	debugPosY = ( love.graphics.getHeight() - bufferHeight * debugScale ) * 0.5

end

--------------------------------------------------------------------------------
--																			  --
--									UPDATE									  --
--																			  --
--------------------------------------------------------------------------------

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
		wrapPosition(
			asteroids[i].position,
			bufferPadding,
			worldWidth,
			bufferPadding,
			worldHeight
		)
	end

	for i = #bullets, 1, -1 do
		if bullets[i].alive then
			bullets[i]:update( dt )
			wrapPosition(
				bullets[i].position,
				bufferPadding,
				worldWidth,
				bufferPadding,
				worldHeight
			)
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

	player:update( dt )
	wrapPosition( player.position, bufferPadding, worldWidth, bufferPadding, worldHeight )

end

--------------------------------------------------------------------------------
--																			  --
--									DRAW									  --
--																			  --
--------------------------------------------------------------------------------

function love.draw()
	love.graphics.clear( COLORS.BLACK )

	-- FIRST PASS:
	-- Sets up to draw to the first back buffer
	-- Clears the whole buffer to zero alpha (transparent)
	-- Draws all the objects as normal with white color
	love.graphics.setCanvas( drawBufferMain )
	love.graphics.clear( 1, 1, 1, 0 )
	love.graphics.setColor( COLORS.WHITE )

	for i = 1, #asteroids do
		local a = asteroids[i]
		love.graphics.draw( a.model, a.position[1], a.position[2], a.rotation )
	end

	-- draw all bullets
	for i = 1, #bullets do
		if bullets[i].alive then
			local b = bullets[i]
			love.graphics.draw( b.model, b.position[1], b.position[2], b.rotation )
		end
	end

	-- main ship model
	love.graphics.draw( player.model, player.position[1], player.position[2], player.rotation )

	-- DEBUG
	if showDebugInfo then
		love.graphics.circle( "line", player.position[1], player.position[2], 1 )
		love.graphics.circle( "line", player.position[1], player.position[2], 20 )

		love.graphics.setColor( 1, 1, 1, 1 )
		-- draw limits
		love.graphics.rectangle("line", 1, 1, bufferPadding, bufferHeight - 2 )
		love.graphics.rectangle("line", 1, 1, bufferWidth - 2, bufferPadding )
		love.graphics.rectangle("line", bufferWidth - 1, bufferHeight - 1, -bufferPadding, -bufferHeight + 2 )
		love.graphics.rectangle("line", bufferWidth - 1, bufferHeight - 1, -bufferWidth - 2, -bufferPadding )
		-- love.graphics.rectangle("line", 1, 1, bufferWidth - 2, bufferPadding - 2 )
		-- love.graphics.rectangle("line", worldLimits.RIGHT, 1, bufferPadding - 2, bufferHeight - 2 )
		-- love.graphics.rectangle("line", 1, worldLimits.BOTTOM, bufferWidth - 2, bufferPadding - 2 )
		love.graphics.setColor( COLORS.WHITE )

		love.graphics.setCanvas()
		love.graphics.setWireframe( false )
		love.graphics.setShader( screenwrap )

		love.graphics.draw( drawBufferMain, debugPosX, debugPosY, 0, debugScale )

		if printProfiler then
			love.graphics.print( love.report or "Please wait...", 0, 0 )
			love.graphics.print( "#bullets:"..#bullets.."\n#asteroids: "..#asteroids.."\nx: "..player.position[1].."\ny: "..player.position[2].."\nr: "..player.rotation, 0, 450 )
		end

		love.graphics.setWireframe( true )
		return
	else
		love.graphics.setWireframe( false )
	end

	--  SECOND PASS:
	-- Sets up to draw to a second back buffer
	-- Clears the whole buffer to zero alpha (transparent)
	-- Sets the active shader to the outline shader
	-- Draws the first buffer applying the shader
	love.graphics.setCanvas( drawBufferSec )
	love.graphics.clear( 1, 1, 1, 0 )
	love.graphics.setShader( outline )
	love.graphics.draw( drawBufferMain )


	-- THIRD (FINAL) PASS:
	-- Sets the canvas to the screen
	-- Sets the active shader to the screenwrap shader
	-- Draws the second buffer to the screen with proper viewport and offsets
	love.graphics.setCanvas()
	love.graphics.setShader( screenwrap )
	-- draw the second buffer, after all other passes, to the screen
	-- only the portion contained in the viewport quad
	-- at viewportPosX, viewportPosY and scaled to viewportScale
	love.graphics.draw( drawBufferSec, viewport, 0, 0, 0, viewportScale )

end

--------------------------------------------------------------------------------
--																			  --
--								   CALLBACKS								  --
--																			  --
--------------------------------------------------------------------------------

function love.keypressed( key, scancode, isrepeat )

	if key == "escape" then
		love.event.quit()
	end

	if key == "return" then
		asteroids[#asteroids + 1] = asteroid:new( math.random( 0, love.graphics.getWidth() ), math.random( 0, love.graphics.getHeight() ) )
	end

	if key == "j" then
		bullets[#bullets + 1] = bullet:new( love.graphics.newMesh(models.bullet, "fan", "dynamic"), player.position, player.rotation, player.velocity )
	end

	if key == "h" then
		if calcInstantDeath(#asteroids) then
			-- Kill player (instant death)
			print("dead")
		end
		player.position = {
			randomPos(
				worldLimits.LEFT,
				worldLimits.TOP,
				worldLimits.RIGHT,
				worldLimits.BOTTOM
			)
		}
	end

	-- DEBUG
	if key == "q" then
		if showDebugInfo then
			showDebugInfo = false
		else
			showDebugInfo = true
		end
	end

	if key == "p" then
		if showDebugInfo then
			if printProfiler then
				printProfiler = false
			else
				printProfiler = true
			end
		end
	end

end
