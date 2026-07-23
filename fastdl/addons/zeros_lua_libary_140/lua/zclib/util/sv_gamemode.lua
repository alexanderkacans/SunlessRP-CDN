if CLIENT then return end
zclib = zclib or {}
zclib.Gamemode = zclib.Gamemode or {}

// Lets call this so other scripts who use this hook can run their code on the bought entity
function zclib.Gamemode.SimulateBuy(ply,ent,name,price)
	if not IsValid(ent) then return end
	if not IsValid(ply) then return end

	local ActiveHooks = hook.GetTable()

	// Simulate Buy hook for DarkRP
	if ActiveHooks["playerBoughtCustomEntity"] then
		local tblEnt = {
			price = price,
			name = name or "",
			ent = ent:GetClass(),
			cmd = ent:GetClass(),
		}
		hook.Run("playerBoughtCustomEntity", ply, tblEnt, ent, price)

	// Simulate Buy hook for Basewars
	elseif ActiveHooks["BaseWars_PlayerBuyEntity"] then
		hook.Run("BaseWars_PlayerBuyEntity", ply, ent)
	end
end

local entTable = {}

// If a entity witht he specified class gets bought in the gamemode then we assign the owner
function zclib.Gamemode.AssignOwnerOnBuy(class)
	entTable[class] = true
end

zclib.Hook.Add("playerBoughtCustomEntity", "DarkRP_SetOwnerOnEntBuy", function(ply, enttbl, ent, price)
	if entTable[ent:GetClass()] then
		zclib.Player.SetOwner(ent, ply)
	end
end)

zclib.Hook.Add("BaseWars_PlayerBuyEntity", "Basewars_SetOwnerOnEntBuy", function(ply, ent)
	if entTable[ent:GetClass()] then
		zclib.Player.SetOwner(ent, ply)
	end
end)

// This automaticly blacklists the entities from the pocket swep
timer.Simple(3,function()
	if entTable and GAMEMODE and GAMEMODE.Config and GAMEMODE.Config.PocketBlacklist then
		for k,v in pairs(entTable) do
			GAMEMODE.Config.PocketBlacklist[k] = true
		end
	end
end)


/*
	Tells us if darkrp exists and hungermod is enabled
*/
function zclib.Gamemode.Hungermod(ply)
	if DarkRP and DarkRP.disabledDefaults and DarkRP.disabledDefaults[ "modules" ][ "hungermod" ] == false and IsValid(ply) and ply.getDarkRPVar and ply:getDarkRPVar("Energy") then
		return true
	else
		return false
	end
end
