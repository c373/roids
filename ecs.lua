-----------------------------------------------------------
--                         E C S                         --
-----------------------------------------------------------

--table containing all the possible component types
componentType = {
	[2] = "position",
	"rotation",
	"direction",
	"speed",
	"model"
}

internType = {
	position = 2,
	rotation = 3,
	direction = 4,
	speed = 5,
	model = 6
}

--main object to implement the ecs design pattern
ecs = {
	intialized = false,
	entitySize = -1,
	entityCount = 0,
	entities = {}, --contains ordered by index the component flag tables for all entities
	emptyIDs = {},
	components = {},
	nextIndex = -1
}

ecs.__index = ecs

function ecs:init()

	local count = 0

	for k in ipairs( componentType ) do
		count = count + 1
	end

	self.entitySize = count + 1
	self.intialized = true

	nextIndex = 1

end

function ecs:isInit()
	assert( self.intialized, "ecs not initialized" )
end

function ecs:isEntity( id )
	assert( self.entities[id + 1], "invalid id" )
	assert( self.entities[id + 1][1], "entity is inactive" )
end

function ecs:isType( type )
	assert( internType[type], "invalid type" )
end

function ecs:resolveType( type )
	return internType[ type ]
end

--for each new entity allocate memory for all component types in the component table and add a new table to entities to flag the type of components it contains
function ecs:newEntity()

	ecs:isInit()

	if #self.emptyIDs >= 1 then

		local id = table.remove( self.emptyIDs )

		for i = 2, self.entitySize, 1 do

			self.entities[id + 1][i] = false

		end

		self.entities[id + 1][1] = true

	else

		self.entityCount = self.entityCount + 1

		self.entities[#self.entities + 1] = {}

		for i = 2, self.entitySize + 1 do

			self.entities[#self.entities][i] = false
			self.components[#self.components + 1] = {}

		end

		self.entities[#self.entities][1] = true

		return self.entityCount - 1

	end

end

function ecs:removeEntity( id )

	ecs:isEntity( id )

	self.emptyIDs[#self.emptyIDs + 1] = id

	for i = 1, self.entitySize do
		self.entities[id + 1][i] = false
	end

end

function ecs:addComponent( id, type, data )
	
	ecs:isEntity( id )
	ecs:isType( type )
	assert( data, "no data input" )

	local t = ecs:resolveType( type )

	self.entities[id + 1][t] = true
	self.components[id*self.entitySize + t] = data

end

function ecs:removeComponent( id, type )

	ecs:isEntity( id )
	ecs:isType( type )

	local t = ecs:resolveType( type )

	self.entities[id + 1][t] = false

end

function ecs:getComponent( id, type )

	ecs:isType( type )

	local t = ecs:resolveType( type )

	assert( self.entities[id + 1][t], "component is inactive" )

	return self.components[id*self.entitySize + t]

end

function ecs:checkComponent( id, type )

	ecs:isType( type )

	local t = ecs:resolveType( type )

	return self.entities[id + 1][t]

end

function ecs:checkComponents( id, ... )

	ecs:isEntity( id )

	local match = true

	for i = 1, select( "#", ... ) do

		if ecs:checkComponent( id, select( i, ... ) ) == false then
			match = false
		end

	end

	return match

end

function ecs:Next( ... )

	

end