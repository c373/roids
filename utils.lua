function rotate( vector, a )

	local c = math.cos( a )
	local s = math.sin( a )

	local x, y = c*vector[1] - s*vector[2], s*vector[1] + c*vector[2]

	vector[1] = x
	vector[2] = y

	return { vector[1], vector[2] }

end

function rotatePolygon( polygon, a )
	local poly = {}
	local c = math.cos( a )
	local s = math.sin( a )
	local x, y = 0, 0
	for i = 1, #polygon - 1, 2 do
		x = c * polygon[i] - s * polygon[i+1]
		y = s * polygon[i] + c * polygon[i+1]
		poly[#poly+1] = x
		poly[#poly+1] = y
	end
	return poly
end

function rotatePolygonMod( polygon, a )
	local c = math.cos( a )
	local s = math.sin( a )
	local x, y = 0, 0
	for i = 1, #polygon - 1, 2 do
		x = c * polygon[i] - s * polygon[i+1]
		y = s * polygon[i] + c * polygon[i+1]
		polygon[i] = x
		polygon[i+1] = y
	end
end

function translatePolygon( polygon, v )
	local poly = {}
	for i = 1, #polygon -1, 2 do
		poly[#poly+1] = polygon[i] + v[1]
		poly[#poly+1] = polygon[i+1] + v[2]
	end
	return poly
end

function translatePolygonMod( polygon, v )
	for i = 1, #polygon -1, 2 do
		polygon[i] = polygon[i] + v[1]
		polygon[i+1] = polygon[i+1] + v[2]
	end
end

function lerp( a, b, t )

	return a + ( b  - a ) * t
end

function normalized( vector )

	local mag = math.sqrt( ( vector[1] * vector[1] ) + ( vector[2] * vector[2] ) )
	
	if mag == 0 then
		return { 0, 0 }
	end

	return { vector[1] / mag, vector[2] / mag }

end

function wrapPosition( vector, xMIN, xMAX, yMIN, yMAX )

	if vector[1] < xMIN then
		vector[1] = vector[1] + xMAX - xMIN
	elseif vector[1] > xMAX then
		vector[1] = vector[1] - xMAX + xMIN
	end

	if vector[2] < yMIN then
		vector[2] = vector[2] + yMAX - yMIN
	elseif vector[2] > yMAX then
		vector[2] = vector[2] - yMAX + yMIN
	end

end

function vertexListToVertexColorList( vertices )

	local vertexColorList = {}

	for i = 1, #vertices, 2 do
		table.insert( vertexColorList, { vertices[i], vertices[i + 1], 0, 0, 1, 1, 1, 1 } )
	end

	return vertexColorList

end

function createPickablePolygon(points)
	-- Takes in a table with a sequence of ints for the (x, y) of each point of the polygon.
	-- Example: {x1, y1, x2, y2, x3, y3, ...}
	-- Note: no need to repeat the first point at the end of the table, the testing function
	-- already handles that.
	local poly = { }
	local lastX = points[#points-1]
	local lastY = points[#points]
	for index = 1, #points-1, 2 do
		local px = points[index]
		local py = points[index+1]
		-- Only store non-horizontal edges.
		if py ~= lastY then
			local index = #poly
			poly[index+1] = px
			poly[index+2] = py
			poly[index+3] = (lastX - px) / (lastY - py)
		end
		lastX = px
		lastY = py
	end
	return poly
end


function isPointInPolygon(x, y, poly)
	-- Takes in the x and y of the point in question, and a 'poly' table created by
	-- createPickablePolygon(). Returns true if the point is within the polygon, otherwise false.
	-- Note: the coordinates of the test point and the polygon points are all assumed to be in
	-- the same space.
	
	-- Original algorithm by W. Randolph Franklin (WRF):
	-- https://wrf.ecse.rpi.edu//Research/Short_Notes/pnpoly.html
	
	local lastPX = poly[#poly-2]
	local lastPY = poly[#poly-1]
	local inside = false
	for index = 1, #poly, 3 do
		local px = poly[index]
		local py = poly[index+1]
		local deltaX_div_deltaY = poly[index+2]
		-- 'deltaX_div_deltaY' is a precomputed optimization. The original line is:
		-- if ((py > y) ~= (lastPY > y)) and (x < (y - py) * (lastX - px) / (lastY - py) + px) then        
		if ((py > y) ~= (lastPY > y)) and (x < (y - py) * deltaX_div_deltaY + px) then
			inside = not inside
		end
		lastPX = px
		lastPY = py
	end
	return inside
end
