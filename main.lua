require "callbacks"

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

	entities = {}

	for i = 0, 10 do
		 for j = 0, 10 do
			table.insert(
				entities,
				{
					position = { j * 75, i * 75  },
					model = love.graphics.newMesh(
						{
							{ 0, 0, 0, 0, 1, 0, 0, 1 },
							{ 50, 0, 0, 0, 1, 1, 0, 1},
							{ 50, 50, 0, 0, 0, 1, 1, 1},
							{ 0, 50, 0, 0, 0, 0, 1, 1}
						},
						"fan",
						"dynamic"
					)
				}
			)
		 end
	end

	print( #entities )

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

end


function love.draw()
	
	for i = 1, #entities do
		love.graphics.draw( entities[i].model, entities[i].position[1], entities[i].position[2] )
	end

	love.graphics.print( love.report or "Please wait...", 0, 0 )

end