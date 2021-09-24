require "callbacks"
require "ecs"

local dx, dy = 0, 0

function love.load()

	ecs:init()

	for i = 1, 10 do
		ecs:newEntity()
		ecs:addComponent( i - 1, "position", { 100 + 25 * i, 100 } )
		ecs:addComponent( i - 1, "model", { -10, -10, 10, -10, 0, 10 } )
	end

	print(#ecs.entities)

	local bool = ecs:checkComponents( 0, "position", "model" )
	print( bool )

	local test1 = { 10, 10 }
	local test2 = { -10, 10 }

	print( test1[1]..test1[2] )

	returnt( test1 )[1] = test2[1]

	print( test1[1]..test1[2] )

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

	local pos = ecs:getComponent( 0, "position" )

	pos[1] = pos[1] + dx
	pos[2] = pos[2] + dy

end

function returnt( t )
	return t
end


function love.draw()
	
	for k, v in ipairs( ecs.entities ) do
		
		local pos = ecs:getComponent( k - 1, "position" )
		love.graphics.push()
		love.graphics.translate( pos[1], pos[2] )
		love.graphics.polygon( "line", ecs:getComponent( k - 1, "model" ) )
		love.graphics.pop()

	end

end