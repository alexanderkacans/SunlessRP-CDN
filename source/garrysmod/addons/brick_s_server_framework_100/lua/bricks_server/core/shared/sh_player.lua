BRICKS_SERVER.PLAYERMETA = {}
BRICKS_SERVER.PLAYERMETA.__index = BRICKS_SERVER.PLAYERMETA

local playerMeta = FindMetaTable( "Player" )

function playerMeta:BRS()
	if( SERVER ) then
		if( not self ) then return false end

		if( not self.BRS_PLAYERMETA ) then
			self.BRS_PLAYERMETA = {
				Player = self
			}

			setmetatable( self.BRS_PLAYERMETA, BRICKS_SERVER.PLAYERMETA )
		end

		return self.BRS_PLAYERMETA
	else
		return BRICKS_SERVER.LOCALPLYMETA
	end
end

-- GENERAL FUNCTIONS --
function BRICKS_SERVER.PLAYERMETA:GetUserID()
	return self.UserID or 0
end