zclib = zclib or {}
zclib.Entity = zclib.Entity or {}

if SERVER then
	local GettingRemovedList = {}
    function zclib.Entity.GettingRemoved(ent)
        return GettingRemovedList[ent] == true
    end

    // Removes a entity safely without hurting its feelings
	function zclib.Entity.SafeRemove(ent)
        if zclib.Entity.GettingRemoved(ent) then return end

        GettingRemovedList[ent] = true

        // Hide entity
        if ent.SetNoDraw then ent:SetNoDraw(true) end

        SafeRemoveEntityDelayed(ent, 0)
        zclib.EntityTracker.Remove(ent)
    end
else

    // Scales one entity relative to the model bounds of another entity
    function zclib.Entity.RelativeScale(ToScale,ent02,val)
        if not IsValid(ToScale) then return end
        if not IsValid(ent02) then return end
        local pmin,pmax = ent02:GetModelBounds()
        local fmin,fmax = ToScale:GetModelBounds()
        local fscale = (fmin - fmax):Length()
        local pscale = (pmin - pmax):Length()
        local nscale = (1 / fscale) * pscale
        nscale = nscale * val
        ToScale:SetModelScale(nscale)
    end

    // Returns which entity the player is currently looking at
    local LookTarget
    function zclib.Entity.GetLookTarget()
        return LookTarget
    end

    local timerid = "zclib.Entity.GetLookTarget"
    zclib.Timer.Remove(timerid)
    zclib.Timer.Create(timerid,0.1,0,function()
        if not IsValid(LocalPlayer()) then return end
        local tr = LocalPlayer():GetEyeTrace()
        if tr and tr.Hit then
            LookTarget = tr.Entity
        else
            LookTarget = nil
        end
    end)
end

zclib.Entity.List = zclib.Entity.List or {}

function zclib.Entity.GetAll()
	local clean = {}
	for k,v in pairs(zclib.Entity.List) do
		if IsValid(k) then
			table.insert(clean,k)
		else
			zclib.Entity.List[k] = nil
		end
	end
	return clean
end

zclib.Hook.Add("OnEntityCreated", "zclib_EntityTracker_add", function(ent)
	if IsValid(ent) then
		zclib.Entity.List[ent] = true
	end
end)

zclib.Hook.Add("EntityRemoved", "zclib_EntityTracker_remove", function(ent)
	if IsValid(ent) then
		zclib.Entity.List[ent] = nil
	end
end)

local function GetListSortedByCount(list,limit)
	local nList = {}

	for k, v in pairs(list) do
		table.insert(nList, {
			class = k,
			count = v
		})
	end

	table.sort(nList, function(a, b) return a.count > b.count end)
	return nList
end

function zclib.Entity.GetEntityCountSorted()
	local countList = {}
	local total = 0

	for k, v in pairs(zclib.Entity.GetAll()) do
		if not IsValid(v) then continue end
		local class = v:GetClass()
		countList[ class ] = (countList[ class ] or 0) + 1
		total = total + 1
	end

	countList = GetListSortedByCount(countList)

	return countList, total
end

local StartEntityTrackState = {}
local JoinTime = 0
function zclib.Entity.GetEntityCountDiffrence()
	local nList = zclib.Entity.GetEntityCountSorted()
	local prevList = {}
	for k,v in pairs(StartEntityTrackState) do
		prevList[v.class] = v.count
	end

	local winnerClass,winnerCount = "" , 0

	local diffList = {}

	for k,v in pairs(nList) do
		local prev_val = (prevList[v.class] or 0)
		local diff = v.count - prev_val

		diffList[ v.class ] = diff

		if diff > winnerCount then
			winnerClass = v.class
			winnerCount = diff
		end
	end

	diffList = GetListSortedByCount(diffList)

	return winnerClass , winnerCount , diffList
end

local function PrintListColored(limitMax,list,IsDiffrence,limit)
	for k, v in ipairs(list) do
		if v == nil or v.count == nil or v.count == 0 then continue end
		if v.count < limit then continue end
		local fract = 1 / (limitMax * 2) * math.Clamp(v.count - limitMax, 0, limitMax)
		local col = zclib.util.LerpColor(fract, color_white, color_red)

		local count = v.count
		if IsDiffrence and v.count > 0 then
			count = "+" .. count
		end

		MsgC(col, string.sub(v.class, 1, 38) .. string.rep(" ", 38 - v.class:len()) .. count .. "\n")
	end
end

function zclib.Entity.Print(limit)
	print(" ")
	MsgC(color_black, "-------------------------------------------" .. "\n")

	local domain = "SERVER"
	local domain_color = Color(108,163,255)
	if CLIENT then
		domain = "CLIENT"
		domain_color = Color(255,212,108)
	end
	MsgC(domain_color, "zcLib - Entity Count - " .. domain .. "\n")

	local nList, total = zclib.Entity.GetEntityCountSorted()

	if SERVER then
		MsgC(domain_color, "There are currently " .. total .. " entities on the server!" .. "\n")
	else
		MsgC(domain_color, "There are currently " .. total .. " entities in your game!" .. "\n")
	end

	PrintListColored(100,nList,false,limit)

	MsgC(color_black, "-------------------------------------------" .. "\n")

	local winnerClass , winnerCount , diffList = zclib.Entity.GetEntityCountDiffrence()

	if SERVER then
		MsgC(domain_color, "Since server start ("..zclib.util.FormatTime(CurTime()).." ago) the entity that increased the most in count is " .. winnerClass .." with " .. winnerCount .. "!" .. "\n")
	else
		MsgC(domain_color, "Since you joined ("..zclib.util.FormatTime(SysTime() - JoinTime).." ago) the entity that increased the most in count is " .. winnerClass .." with " .. winnerCount .. "!" .. "\n")
	end
	PrintListColored(50,diffList,true,limit)

	MsgC(color_black, "-------------------------------------------" .. "\n")
	print(" ")
end

if SERVER then
	util.AddNetworkString("zclib.Entity.Print")

	// Lets use the first playing joining as a init function
	zclib.Hook.Add("zclib_PlayerJoined", "zclib_PlayerJoined_EntityTracker", function(ply)

		local tbl = zclib.Entity.GetEntityCountSorted(1)
		StartEntityTrackState = table.Copy(tbl)

		zclib.Hook.Remove("zclib_PlayerJoined", "zclib_PlayerJoined_EntityTracker")
	end)
else
	net.Receive("zclib.Entity.Print", function(len, ply)
		local limit = net.ReadFloat()
		zclib.Entity.Print(limit)
	end)

	zclib.Hook.Add("zclib_PlayerInitialized", "zclib_PlayerInitialized_EntityTracker", function()
		timer.Simple(3,function()
			local tbl = zclib.Entity.GetEntityCountSorted(1)
			StartEntityTrackState = table.Copy(tbl)
			JoinTime = SysTime()
		end)
	end)
end

/*
	Prints out on how many entities did exist when the player join / server started
*/
concommand.Add("zclib_print_entities", function(ply, cmd, args)
	if zclib.Player.IsAdmin(ply) or not IsValid(ply) then
		local limit = tonumber(args[1] or 1)
		zclib.Entity.Print(limit)

		if SERVER and IsValid(ply) and zclib.Player.IsAdmin(ply) then
			net.Start("zclib.Entity.Print")
			net.WriteFloat(limit)
			net.Send(ply)
		end
	end
end)

if SERVER then

	local CachedEntityList = {}
	local NextCache = 0
	local NextID = 1
	local function CatchNextEntity(class)
		if CurTime() > NextCache then
			CachedEntityList = zclib.Entity.GetAll()
			NextCache = CurTime() + 15
		end

		local clean = {}
		for k,v in pairs(CachedEntityList) do
			if IsValid(v) and v:GetClass() == class then
				table.insert(clean,v)
			end
		end

		print("Found " .. #clean .. " " .. class)
		//PrintTable(clean)

		if NextID > #clean then NextID = 1 end

		print("Go to > " .. NextID)
		local target = clean[NextID]
		NextID = NextID + 1
		if IsValid(target) then
			return target
		else
			NextID = 0
		end
	end

	util.AddNetworkString("zclib.Entity.GoTo")
	net.Receive("zclib.Entity.GoTo", function(len, ply)
		if not zclib.Player.IsAdmin(ply) then return end
		local class = net.ReadString()

		if class == nil then return end
		local target = CatchNextEntity(class)
		if IsValid(target) then
			ply:SetPos(target:GetPos())
		end
	end)

	util.AddNetworkString("zclib.Entity.CleanUp")
	net.Receive("zclib.Entity.CleanUp", function(len, ply)
		if not zclib.Player.IsAdmin(ply) then return end
		local class = net.ReadString()
		if class == nil then return end

		for k,v in pairs(zclib.Entity.GetAll()) do
			if IsValid(v) and v:GetClass() == class then
				if class == "predicted_viewmodel" then
					local owner = v:GetOwner()
					print(tostring(v),"Owner: "..tostring(owner))
					if not IsValid(owner) then
						print(tostring(v), "Removed!")
						SafeRemoveEntityDelayed(v,0.1)
					end
				elseif class == "phys_lengthconstraint" then
					local parent = v:GetParent()
					print(tostring(v),"Parent: "..tostring(parent))

					print(tostring(v), "Removed!")
					SafeRemoveEntityDelayed(v,0.1)
				else
					print(tostring(v), "Removed!")
					SafeRemoveEntityDelayed(v,0.1)
				end
			end
		end
	end)
else
	/*
		Teleports the player to the specified class
	*/
	concommand.Add("zclib_goto_entityclass", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then
			local class = args[1]
			if class then
				net.Start("zclib.Entity.GoTo")
				net.WriteString(class)
				net.SendToServer()
			end
		end
	end)

	/*
		Cleanup entities
	*/
	concommand.Add("zclib_cleanup_entityclass", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then
			local class = args[1]
			if class then
				net.Start("zclib.Entity.CleanUp")
				net.WriteString(class)
				net.SendToServer()
			end
		end
	end)
end

concommand.Add("zclib_debug_entity", function(ply, cmd, args)
	if zclib.Player.IsAdmin(ply) then
		local tr = ply:GetEyeTrace()
		local ent = tr.Entity
		if IsValid(ent) then
			print("HammerID: ",tostring( ent:GetInternalVariable("hammerid")))
			print("Parent: ",tostring(ent:GetParent()))
			print("PhysObject: ",tostring(ent:GetPhysicsObject()))
			PrintTable(ent:GetKeyValues())
		end
	end
end)
