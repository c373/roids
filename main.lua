require "callbacks"
local tiny = require( "tiny" )



local dx, dy = 0, 0
local angle = 0

local drawingSystem = tiny.processingSystem()

function drawingSystem:process( e )

	love.graphics.push()

	love.graphics.translate( e.position[1], e.position[2] )
	love.graphics.polygon( "line", e.model )

	love.graphics.pop()

end

function rotate( x, y, a )

	local c = math.cos( a )
	local s = math.sin( a )

	return c*x - s*y, s*x + c*y

end

function love.load()

	love.frame = 0
	love.profiler = require( "profile" )
	love.profiler.start()

	drawingSystem.filter = tiny.requireAll( "position", "model" )

	entities = {}

	for i = 1, 900 do

		table.insert(
			entities,
			{
				position = { 0 + i * 25, 0 },
				model = { 0, 0, 10, 10, 10, 0 }
			}
		)

	end

	print( #entities )

	world = tiny.world( drawingSystem, entities )

end

function love.update( dt )

	love.frame = love.frame + 1

	if love.frame % 100 == 0 then
		love.report = love.profiler.report( 20 )
		love.profiler.reset()
	end

	dx, dy = 0, 0

	if love.keyboard.isDown( "a" ) then
		angle = angle - 0.05
	elseif love.keyboard.isDown( "d" ) then
		angle = angle + 0.05
	end

	if love.keyboard.isDown( "w" ) then
		dy = -300 * dt
	elseif love.keyboard.isDown( "s" ) then
		dy = 300 * dt
	end

	--[[
	local id
	repeat

		id = ecs:next( "position", "playerInput" )

		if id == -1 then break end

		local x, y = rotate( dx, dy, angle )
		local pos = ecs:getComponent( id, "position" )

		pos[1] = pos[1] + x
		pos[2] = pos[2] + y

		ecs:setComponent( id, "rotation", angle )

	until( id == -1 )]]--

end


function love.draw()

	love.graphics.print( love.report or "Please wait...", 0, 0 )
	
	for i = 1, #entities do
		drawingSystem:process( entities[i] )
	end

end