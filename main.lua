require "callbacks"
require "ecs"

local dx, dy = 0, 0
local angle = 0

function rotate( x, y, a )

	local c = math.cos( a )
	local s = math.sin( a )

	return c*x - s*y, s*x + c*y

end

function love.load()

	love.frame = 0
	love.profiler = require( "profile" )
	love.profiler.start()

	ecs:init()

	for i = 0, 900 do
		ecs:newEntity()
		ecs:addComponent( i, "position", { 100 + 25 * i, 100 } )
		ecs:addComponent( i, "model", { -10, -10, 10, -10, 0, 10 } )
		ecs:addComponent( i, "rotation", 0 )
	end

	local id = ecs:newEntity()
	ecs:addComponent( id, "position", { 500, 500 } )
	ecs:addComponent( id, "rotation", 0 )
	ecs:addComponent( id, "model", { -10, 10, 10, 10, 0, -10 } )
	ecs:addComponent( id, "playerInput", true )

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

	local id
	repeat

		id = ecs:next( "position", "playerInput" )

		if id == -1 then break end

		local x, y = rotate( dx, dy, angle )
		local pos = ecs:getComponent( id, "position" )

		pos[1] = pos[1] + x
		pos[2] = pos[2] + y

		ecs:setComponent( id, "rotation", angle )

	until( id == -1 )

end


function love.draw()

	love.graphics.print( love.report or "Please wait...", 0, 0 )
	
	local id
	repeat

		id = ecs:next( "position", "model" )

		if id == -1 then break end

		love.graphics.push()

		local pos = ecs:getComponent( id, "position" )
		love.graphics.translate( pos[1], pos[2] )

		if ecs:checkComponent( id, "playerInput" ) then
			love.graphics.print( angle, -30, -30 )
		end

		love.graphics.rotate( ecs:getComponent( id, "rotation" ) )
		love.graphics.polygon( "line", ecs:getComponent( id, "model" ) )

		love.graphics.pop()

	until( id == -1 )

end