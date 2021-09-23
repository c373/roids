require "callbacks"
require "ecs"

function love.load()

	ecs:init()

	for i = 1, 10 do
		ecs:newEntity()
		ecs:addComponent( i - 1, "position", { x = 100 + 25 * i, y = 100 } )
		ecs:addComponent( i - 1, "model", { -10, -10, 10, -10, 0, 10 } )
	end

	print(#ecs.entities)

end

function love.update()
end

function love.draw()
	
	for k, v in ipairs( ecs.entities ) do
		
		local pos = ecs:getComponent( k - 1, "position" )
		love.graphics.push()
		love.graphics.translate( pos.x, pos.y )
		love.graphics.polygon( "line", ecs:getComponent( k - 1, "model" ) )
		love.graphics.pop()

	end

end