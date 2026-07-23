BRICKS_SERVER.DEVCONFIG.INVENTORY = BRICKS_SERVER.DEVCONFIG.INVENTORY or {}
BRICKS_SERVER.DEVCONFIG.INVENTORY.EntTypes = BRICKS_SERVER.DEVCONFIG.INVENTORY.EntTypes or {}

local itemMeta = {
	Register = function( self )
        BRICKS_SERVER.DEVCONFIG.INVENTORY.EntTypes[self.Class] = self
	end
}

itemMeta.__index = itemMeta

function BRICKS_SERVER.Func.CreateItemType( class )
	local item = {
		Class = class
	}
	
	setmetatable( item, itemMeta )
	
	return item
end

for k, v in pairs( file.Find( "bricks_server/itemtypes/*.lua", "LUA" ) ) do
    AddCSLuaFile( "bricks_server/itemtypes/" .. v )
    include( "bricks_server/itemtypes/" .. v )
end