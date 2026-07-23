if CLIENT then return end

zclib = zclib or {}
zclib.Player = zclib.Player or {}

// How often are clients allowed to send net messages to the server
zclib_NW_TIMEOUT = 0.1

function zclib.Player.Timeout(id,ply)
    if not IsValid(ply) then
        zclib.Print("[ DEBUG ] TimeoutID: " .. tostring(id))
        zclib.Print("[ DEBUG ] Player not valid Timeout: " .. tostring(ply))
        return true
    end

    local Timeout = false

    if ply.zclib_NWTimeout == nil then
        ply.zclib_NWTimeout = {}
    end

    if id == nil then
        id = "default"
    end

    if ply.zclib_NWTimeout[id] and ply.zclib_NWTimeout[id] > CurTime() then
        Timeout = true
        //zclib.Print("[ DEBUG ] TimeoutID: " .. tostring(id))
        //zclib.Print("[ DEBUG ] Player Timeout: " .. tostring(ply))
    end

    ply.zclib_NWTimeout[id] = CurTime() + zclib_NW_TIMEOUT

    return Timeout
end

util.AddNetworkString("zclib_Player_Initialize")
net.Receive("zclib_Player_Initialize", function(len, ply)

    if ply.zclib_HasInitialized then
        return
    else
        ply.zclib_HasInitialized = true
    end

    zclib.Debug_Net("zclib_Player_Initialize",len)

    if IsValid(ply) then

		zclib.Player.Add(ply)

        if zclib.config.Inventory.PlayerInv then

            // Check all the tracked entities and send the player their inventory
            for k, v in pairs(zclib.EntityTracker.GetList()) do
                if IsValid(v) and v.zclib_inv then
                    zclib.Inventory.SynchForPlayer(v, ply)
                end
            end
        end

        hook.Run("zclib_PlayerJoined",ply)
    end
end)

////////////////////////////////////////////
//////////// Player Status Changed /////////
////////////////////////////////////////////
local DeleteEnts = {}
function zclib.Player.CleanUp_Add(class)
    DeleteEnts[class] = true
end
function zclib.Player.CleanUp(steamID)

    hook.Run("zclib_PrePlayerCleanUp",steamID)

    //for k, v in pairs(zclib.EntityTracker.GetList()) do
	for k, v in pairs(ents.GetAll()) do
        if IsValid(v) and DeleteEnts[v:GetClass()] and zclib.Player.GetOwnerID(v) == steamID then
            SafeRemoveEntity(v)
        end
    end
end

function zclib.Player.Disconnect(steamid)
    zclib.Player.CleanUp(steamid)
    hook.Run("zclib_PlayerDisconnect",steamid)
end
gameevent.Listen("player_disconnect")
zclib.Hook.Add("player_disconnect", "player_disconnect", function(data)
    local steamid

    if data.bot == 1 then
        steamid = data.userid
    else
        steamid = data.networkid
    end

    zclib.Player.List[steamid] = nil

    zclib.Player.Disconnect(steamid)
end)

zclib.Hook.Add("PlayerChangedTeam", "PlayerChangedTeam", function(ply, before, after)
    if zclib.config.CleanUp.SkipOnTeamChange[before] == nil and zclib.config.CleanUp.SkipOnTeamChange[after] == nil then
        zclib.Player.CleanUp(zclib.Player.GetID(ply))
    end
end)


concommand.Add("zclib_AddBotsToList", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        for k,v in pairs(player.GetAll()) do
            if IsValid(v) and v:IsBot() then
                zclib.Player.Add(v)
            end
        end
    end
end)
