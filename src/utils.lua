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

function normalize( vector )

	local mag = math.sqrt( ( vector[1] * vector[1] ) + ( vector[2] * vector[2] ) )

	if mag == 0 then
		return { 0, 0 }
	end

	vector[1] = vector[1] / mag
	vector[2] = vector[2] / mag

	return vector

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

function triangluatedVerticesToVertexColor( triangulated )

	local vertexColorList = {}

	for i = 1, #triangulated, 1 do
		for j = 1, #triangulated[i], 2 do
			table.insert( vertexColorList, { triangulated[i][j], triangulated[i][j+1], 0, 0, 1, 1, 1, 1 } )
		end
	end

	return vertexColorList

end

function vertexListToVertexColorList( vertices )

	local vertexColorList = {}

	for i = 1, #vertices, 2 do
		table.insert( vertexColorList, { vertices[i], vertices[i + 1], 0, 0, 1, 1, 1, 1 } )
	end

	return vertexColorList

end

function printTable( aTable )
	for index, data in ipairs( aTable ) do
		print( index )
		for key, value in pairs( data ) do
			print( '\t', key, value )
		end
	end
end
