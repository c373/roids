function rotate( vector, a )

	local c = math.cos( a )
	local s = math.sin( a )

	local x, y = c*vector[1] - s*vector[2], s*vector[1] + c*vector[2]

	vector[1] = x
	vector[2] = y

	return { vector[1], vector[2] }

end

function wrapPosition( vector, xMIN, xMAX, yMIN, yMAX )

	if vector[1] < xMIN then
		vector[1] = xMAX
	elseif vector[1] > xMAX then
		vector[1] = xMIN
	end

	if vector[2] < yMIN then
		vector[2] = yMAX
	elseif vector[2] > yMAX then
		vector[2] = yMIN
	end

end

function vertexListToVertexColorList( vertices )

	local vertexColorList = {}

	for i = 1, #vertices, 2 do
		table.insert( vertexColorList, { vertices[i], vertices[i + 1], 0, 0, 1, 1, 1, 1 } )
	end

	return vertexColorList

end
