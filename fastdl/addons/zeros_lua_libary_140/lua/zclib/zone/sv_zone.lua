if CLIENT then return end
zclib = zclib or {}
zclib.Zone = zclib.Zone or {}

/*

    The Zone System should automaticly Create / Load / Remove / Send zone lists to clients

*/

zclib.Hook.Add("zclib_PlayerJoined", "zclib_zone_PlayerJoined", function(ply)

    timer.Simple(0.5, function()
        if not IsValid(ply) then return end

        // Send the player all zones which are created for this map
        for k,v in pairs(zclib.Zone.Entrys) do
            if v then
                zclib.Print("Send " .. k .. " to " .. ply:Nick())
                zclib.Zone.Send(k,ply)
            end
        end
    end)
end)


util.AddNetworkString("zclib_Zone_Send")
function zclib.Zone.Send(entryid,ply)
    zclib.Debug("zclib.Zone.Send " .. tostring(ply))

    local zonelist = zclib.Zone.GetData(entryid)
    if zonelist == nil then return end

    local e_String = util.TableToJSON(zonelist)
    local e_Compressed = util.Compress(e_String)

    net.Start("zclib_Zone_Send")
    net.WriteString(entryid)
    net.WriteUInt(#e_Compressed,16)
    net.WriteData(e_Compressed,#e_Compressed)
    net.Send(ply)
end

function zclib.Zone.SendAll(entryid)
    zclib.Debug("zclib.Zone.SendAll")
    local zonelist = zclib.Zone.GetData(entryid)
    if zonelist == nil then return end

    local e_String = util.TableToJSON(zonelist)
    local e_Compressed = util.Compress(e_String)

    net.Start("zclib_Zone_Send")
    net.WriteString(entryid)
    net.WriteUInt(#e_Compressed,16)
    net.WriteData(e_Compressed,#e_Compressed)
    net.Broadcast()
end

util.AddNetworkString("zclib_Zone_Show")
function zclib.Zone.Show(entryid,ply,all)
    zclib.Debug("zclib.Zone.Show")
    net.Start("zclib_Zone_Show")
    net.WriteString(entryid)
	net.WriteBool(all == true)
    net.Send(ply)
end

util.AddNetworkString("zclib_Zone_Hide")
function zclib.Zone.Hide(ply)
    zclib.Debug("zclib.Zone.Hide")
    net.Start("zclib_Zone_Hide")
    net.Send(ply)
end

util.AddNetworkString("zclib_Zone_ShowSingle")
function zclib.Zone.ShowSingle(entryid,zoneid,ply)
    zclib.Debug("zclib.Zone.ShowSingle")
    net.Start("zclib_Zone_ShowSingle")
    net.WriteString(entryid)
    net.WriteUInt(zoneid,16)
    net.Send(ply)
end

// Creates a new zone
function zclib.Zone.Add(entryid,ply,pos,size,extradata)
    zclib.Debug("zclib.Zone.Add")

	//print("zclib.Zone.Add",entryid,"pos: "..tostring(pos),"size: "..tostring(size))

    local width = math.abs(size.x)
    local length = math.abs(size.y)
    if width < 10 or length < 10 then
        zclib.Notify(ply, "Zone is too small!", 1)
        return
    end

    local dat = table.Copy(extradata)
    dat.pos = pos
    dat.size = size
    table.insert(zclib.Zone.GetData(entryid),dat)

    zclib.Zone.Save(entryid,true)
    zclib.Zone.SendAll(entryid)
end

// Removes any zone thats intersecting at the provided position
function zclib.Zone.RemoveAt(entryid,ply,pos)
    zclib.Debug("zclib.Zone.RemoveAt")

    local zonelist = zclib.Zone.GetData(entryid)
    if zonelist == nil then return end

    local RemovedZone = false
    for k,v in pairs(zonelist) do
        if v == nil then continue end
        if v.pos == nil then continue end
        if v.size == nil then continue end

        if zclib.Zone.Check(entryid,k,pos) then

            local entry = zclib.Zone.GetEntry(entryid)
            if entry and entry.OnZoneRemoved then
                entry.OnZoneRemoved(k,v)
            end

            zonelist[k] = nil
            RemovedZone = true
        end
    end

    if RemovedZone then
        zclib.Zone.Save(entryid,true)
        zclib.Zone.SendAll(entryid)
    end

    return RemovedZone
end

concommand.Add("zclib_zone_remove", function(ply,cmd,args)
	if not ply:IsSuperAdmin() then return end

	local entryid = args[1]
	if not entryid then return end

	local zoneid = args[2]
	if not zoneid then return end
	zoneid = tonumber(zoneid)

	local zonelist = zclib.Zone.GetData(entryid)
	if zonelist == nil then return end

	zonelist[zoneid] = nil

	zclib.Zone.Save(entryid,true)
	zclib.Zone.SendAll(entryid)
end)


///////////////////// SAVING
// Saves all the zones which we currently have
function zclib.Zone.Save(entryid,force)
    zclib.Debug("[Zone] Saving " .. entryid)

    local entry = zclib.Zone.GetEntry(entryid)
    if entry == nil then return end

    local data = entry.GetData()
    if data == nil then return false end

    // If we force the saving of the data then it doesent matter if its empty
    if force ~= true and table.Count(data) <= 0 then return false end

    file.Write(entry.path, util.TableToJSON(data,true))
    return true
end

// Loads any zone data for the map
function zclib.Zone.Load(entryid)
    zclib.Debug("[Zone] Loading " .. entryid)
    local entry = zclib.Zone.GetEntry(entryid)
    if entry == nil then return end

    if file.Exists(entry.path, "DATA") then
        local data = file.Read(entry.path, "DATA")
        if data == nil then return false end

        data = util.JSONToTable(data)
        if data == nil then return false end

        if data and table.Count(data) > 0 then
            entry.Load(data)
        else
            return false
        end
    else
        return false
    end
end

// Removes any zone data for the provided id
function zclib.Zone.Remove(entryid)
    zclib.Debug("[Zone] Remove " .. entryid)
    local entry = zclib.Zone.GetEntry(entryid)
    if entry == nil then return end

    entry.Remove()

    zclib.Zone.SendAll(entryid)

    if file.Exists(entry.path, "DATA") then
        file.Delete(entry.path)
        return true
    else
        return false
    end
end

timer.Simple(3,function()
    for k,v in pairs(zclib.Zone.Entrys) do
        zclib.Zone.Load(k)
    end
end)
