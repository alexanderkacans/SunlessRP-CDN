if CLIENT then return end
zclib = zclib or {}
zclib.STM = zclib.STM or {}

/*

    Save To Map - System
    Saves and loads entities to the map

*/

zclib.STM.List = zclib.STM.List or {}

function zclib.STM.Setup(id,path,getdata,load,remove,skipcleanup)
    zclib.STM.List[id] = {
        path = path,
        GetData = getdata,
        Load = load,
        Remove = remove,
		SkipCleanup = skipcleanup,
    }
end

function zclib.STM.Save(id,force)
	zclib.Print("[STM][Save] Initialized " .. id)
    local entry = zclib.STM.List[id]
    if entry == nil then
		zclib.ErrorPrint("[STM][Save] Data Entry is invalid for " .. id)
		return
	end

    local data = entry.GetData()
    if data == nil then
		zclib.ErrorPrint("[STM][Save] Returned Data is invalid for " .. id)
		return false
	end

    // If we force the saving of the data then it doesent matter if its empty
    if force ~= true and table.Count(data) <= 0 then
		zclib.ErrorPrint("[STM][Save] Returned Data was empty " .. id)
		return false
	end

	zclib.Print("[STM][Save] Completed " .. id)
    file.Write(entry.path, util.TableToJSON(data,true))
    return true
end

function zclib.STM.Load(id)
	zclib.Print("[STM][Load] Initialized " .. id)

	local entry = zclib.STM.List[ id ]

	if entry == nil then
		zclib.ErrorPrint("[STM][Load] Data Entry is invalid for " .. id)

		return
	end

	if not file.Exists(entry.path, "DATA") then
		//zclib.ErrorPrint("[STM][Load] Savefile path not found for " .. id)
		return false
	end

	local data = file.Read(entry.path, "DATA")
	if data == nil then
		zclib.ErrorPrint("[STM][Load] Read savefile was invalid for " .. id)

		return false
	end

	data = util.JSONToTable(data)
	if data == nil then
		zclib.ErrorPrint("[STM][Load] JSONToTable conversion failed for " .. id)

		return false
	end

	if data and table.Count(data) > 0 then
		zclib.Print("[STM][Load] Completed " .. id)
		entry.Load(data)
	else
		zclib.ErrorPrint("[STM][Load] Data list is empty for " .. id)
		return false
	end
end

function zclib.STM.GetData(id)
    zclib.Debug("[STM] GetData " .. id)
    local entry = zclib.STM.List[id]
    if entry == nil then return end

    if file.Exists(entry.path, "DATA") then
        local data = file.Read(entry.path, "DATA")
        if data == nil then return false end

        data = util.JSONToTable(data)
        if data == nil then return false end

        if data and table.Count(data) > 0 then
            return data
        else
            return false
        end
    else
        return false
    end
end

function zclib.STM.Remove(id)

    local entry = zclib.STM.List[id]
    if entry == nil then return end

    entry.Remove()

    if file.Exists(entry.path, "DATA") then
        file.Delete(entry.path)
        return true
    else
        return false
    end
end

zclib.Hook.Add("PostCleanupMap", "SaveToMap", function()
    for k,v in pairs(zclib.STM.List) do
		if v.SkipCleanup then continue end
        zclib.STM.Load(k)
    end
end)

if not zclib.STM.SetupLoaded then
    timer.Simple(3, function()
        zclib.Print("Loading STM Setups")
        for k, v in pairs(zclib.STM.List) do
            zclib.STM.Load(k)
        end
    end)
    zclib.STM.SetupLoaded = true
end
