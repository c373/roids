function love.keypressed( key, scancode, isrepeat )

	if key == "escape" then
		love.event.quit()
	end

	if key == "return" then
		createAsteroid()
	end

	if key == "v" then
		printInfo( asteroid )
	end
	
end