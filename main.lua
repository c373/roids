require "callbacks"
require "ecs"

local dx, dy = 0, 0

function love.load()

	ecs:init()

	for i = 0, 9 do
		ecs:newEntity()
		ecs:addComponent( i, "position", { 100 + 25 * i, 100 } )
		ecs:addComponent( i, "model", { -10, -10, 10, -10, 0, 10 } )
	end

	local id = ecs:newEntity()
	ecs:addComponent( id, "position", { 500, 500 } )
	ecs:addComponent( id, "model", { -10, -10, -10, 10, 10, 10, 10, -10 } )

	ecs:addComponent( 0, "playerInput", true )

end

function love.update()

	dx, dy = 0, 0

	if love.keyboard.isDown( "a" ) then
		dx = -1
	elseif love.keyboard.isDown( "d" ) then
		dx = 1
	end

	if love.keyboard.isDown( "w" ) then
		dy = -1
	elseif love.keyboard.isDown( "s" ) then
		dy = 1
	end

	local id
	repeat

		id = ecs:next( "position", "playerInput" )

		print( id )

		if id == -1 then break end

		local pos = ecs:getComponent( id, "position" )

		pos[1] = pos[1] + dx
		pos[2] = pos[2] + dy

	until( id == -1 )

end


function love.draw()
	
	local id
	repeat

		id = ecs:next( "position", "model" )

		if id == -1 then break end

		love.graphics.push()

		local pos = ecs:getComponent( id, "position" )
		love.graphics.translate( pos[1], pos[2] )
		love.graphics.polygon( "line", ecs:getComponent( id, "model" ) )

		love.graphics.pop()

	until( id == -1 )

end