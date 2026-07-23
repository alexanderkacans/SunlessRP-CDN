zclib = zclib or {}
zclib.Player = zclib.Player or {}

zclib.Player.List = zclib.Player.List or {}

if SERVER then
	util.AddNetworkString("zclib_Player_Send")
	function zclib.Player.Send(plytbl,sendto)

		// Better save then sorry
		local cleantbl = {}
		for k,v in pairs(plytbl) do
			if IsValid(v) then
				table.insert(cleantbl,v)
			end
		end

		local length = table.Count(cleantbl)
		net.Start("zclib_Player_Send")
		net.WriteUInt(length,15)
		for k,v in pairs(cleantbl) do
			net.WriteEntity(v)
		end
		net.Send(sendto)
	end
else
	net.Receive("zclib_Player_Send", function(len)
		zclib.Debug_Net("zclib_Player_Send", len)
		local length = net.ReadUInt(15)
		for i = 1,length do
			local ply = net.ReadEntity()
			if IsValid(ply) then
				zclib.Player.Add(ply)
			end
		end
	end)
end

function zclib.Player.Add(ply)
    zclib.Player.List[zclib.Player.GetID(ply)] = ply
	if SERVER then

		// Tell the other players that this player just joined
		zclib.Player.Send({ply},zclib.Player.GetAll())

		// Tell this player about the other players
		zclib.Player.Send(zclib.Player.GetAll(),ply)
	end
end

function zclib.Player.GetAll()
	local cleantbl = {}
	for k,v in pairs(zclib.Player.List) do
		if IsValid(v) then
			table.insert(cleantbl,v)
		end
	end
	return cleantbl
end

/*
	A timer that auto updates the Playerlist ever 10 minutes
*/
zclib.Timer.Remove("zclib.Player.GetAll")
zclib.Timer.Create("zclib.Player.GetAll",600,0,function()
	for k,v in pairs(player.GetAll()) do
		if IsValid(v) then
			zclib.Player.List[zclib.Player.GetID(v)] = v
		end
	end
end)

// Returns a list of all the players who are close enough to the provided distance
function zclib.Player.GetInSphere(pos,radius)
    local tbl = {}
    for k,v in pairs(zclib.Player.List) do
        if IsValid(v) and zclib.util.InDistance(v:GetPos(), pos, radius) then
            tbl[v] = true
        end
    end
    return tbl
end

// Returns the steam id of the player
function zclib.Player.GetID(ply)
    if ply:IsBot() then
        return ply:UserID()
    else
        return ply:SteamID()
    end
end

// Returns the name of the player
function zclib.Player.GetName(ply)
    if ply:IsBot() then
        return "Bot_" .. ply:UserID()
    else
        return ply:Nick()
    end
end

// Returns the player rank / usergroup
function zclib.Player.GetRank(ply)
	if ply.GetSecondaryUserGroup then
		local rank = ply:GetSecondaryUserGroup()
		if rank == "user" then rank = ply:GetUserGroup() end
		if rank == "" then rank = ply:GetUserGroup() end
		if rank == " " then rank = ply:GetUserGroup() end
		if rank == "  " then rank = ply:GetUserGroup() end
		return rank
	else
		return ply:GetUserGroup()
	end
end

// Checks if the player has one of the specified ranks
function zclib.Player.RankCheck(ply, ranks)
	if not IsValid(ply) or ranks == nil then return false end
	if table.Count(ranks) <= 0 then return true end

	if xAdmin then
		local HasRank = false

		for k, v in pairs(ranks) do
			if ply:IsUserGroup(k) then
				HasRank = true
				break
			end
		end

		return HasRank
	else
		if ranks[ zclib.Player.GetRank(ply) ] == nil then
			return false
		else
			return true
		end
	end
end

function zclib.Player.JobCheck(ply, jobs)
    if not IsValid(ply) or jobs == nil then return false end
    if table.Count(jobs) <= 0 then return true end

    return jobs[zclib.Player.GetJobName(ply)] ~= nil
end

// Returns the players job
function zclib.Player.GetJob(ply)
    if not IsValid(ply) then return -1 end
    return ply:Team()
end

// Returns the players job command
function zclib.Player.GetJobCommand(ply)
    if not IsValid(ply) then return "" end
	local jobtbl = RPExtraTeams[ply:Team()]
	if not jobtbl then return "" end
    return jobtbl.command
end

// Returns the players job name
function zclib.Player.GetJobName(ply)
    if not IsValid(ply) then return "Invalid" end
    return team.GetName(zclib.Player.GetJob(ply))
end

// Gets the position of the players head
function zclib.Player.GetHeadPos(ply)
    local pos = ply:GetPos() + ply:GetUp() * 25
    local attachID = ply:LookupAttachment("eyes")
    if attachID then
        local attach = ply:GetAttachment(attachID)
        if attach then
            pos = attach.Pos
        end
    end
    return pos
end


// This returns true if the player is a admin
function zclib.Player.IsAdmin(ply)
    if IsValid(ply) then

        // xAdmin Support
        if xAdmin then
            return ply:IsAdmin()

        // SAM Support
        elseif sam then
            return ply:IsSuperAdmin()

        // sAdmin support
        elseif sAdmin then
            return ply:IsAdmin()

        elseif ply:IsSuperAdmin() == true then
            return true
        elseif ply.IsAdmin and ply:IsAdmin() == true then
            return true
        else
            if zclib.config.AdminRanks[zclib.Player.GetRank(ply)] then

                return true
            else

                return false
            end
        end
    else
        return false
    end
end

if SERVER then

	// This saves the owners SteamID
	function zclib.Player.SetOwner(ent, ply)

		if (IsValid(ply)) then
			ent:SetNWString("zclib_Owner", ply:SteamID())

			if CPPI then
				ent:CPPISetOwner(ply)
			end

			if gProtect and istable(gProtect) then
				gProtect.SetOwner(ply,ent)
			end
		else
			ent:SetNWString("zclib_Owner", "world")
		end
	end
end

// This returns the entites owner SteamID
function zclib.Player.GetOwnerID(ent)
	return ent:GetNWString("zclib_Owner", "nil")
end

// Checks if both entities have the same owner
function zclib.Player.SharedOwner(ent01,ent02)
	if IsValid(ent01) and IsValid(ent02) then

		if zclib.Player.GetOwnerID(ent01) == zclib.Player.GetOwnerID(ent02) then
			return true
		else
			return false
		end
	else
		return false
	end
end

// This returns the owner
function zclib.Player.GetOwner(ent)
	if IsValid(ent) then

		local id = ent:GetNWString("zclib_Owner", "nil")
		local ply = player.GetBySteamID(id)
		if IsValid(ply) then return ply end

		ply = ent:GetOwner()
		if IsValid(ply) then return ply end


		if gProtect then ply = gProtect.GetOwner(ent) end
		if IsValid(ply) then return ply end

		if ent.CPPIGetOwner then ply = ent:CPPIGetOwner() end
		if IsValid(ply) then return ply end

		return false
	else
		return false
	end
end

// Checks if the player is the owner of the entitiy
function zclib.Player.IsOwner(ply, ent)
	if IsValid(ent) and IsValid(ply) then
		local id = ent:GetNWString("zclib_Owner", "nil")
		local ply_id = ply:SteamID()

		if id == ply_id or id == "world" then

			return true
		else
			return false
		end
	else
		return false
	end
end
