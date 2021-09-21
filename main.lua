require "callbacks"
require "ecs"

function love.load()

	ecs:init()

	for i = 1, 1 do
		ecs:newEntity()
	end

	print(#ecs.entities)

	ecs:addComponent( 0, "position", { x = 100, y = 100 } )

	print(tostring( ecs:getComponent( 0, "position" )["x"] ))

	ecs:removeComponent( 0, "position" )

	--print(tostring( ecs:getComponent( 0, "position" )["x"] ))

	ecs:removeEntity( 0 )

	print(#ecs.entities)

	local id = ecs:newEntity()
	local id2 = ecs:newEntity()

	print(#ecs.entities)

end

function love.update()
end

function love.draw()
end