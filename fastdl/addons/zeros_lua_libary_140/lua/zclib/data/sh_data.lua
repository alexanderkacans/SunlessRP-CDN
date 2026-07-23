
/*

    This system will handle the loading / saving / sending / receiving and updating of Config data

*/

zclib = zclib or {}
zclib.Data = zclib.Data or {}

zclib.Data.Entrys = zclib.Data.Entrys or {}

function zclib.Data.RebuildListIDs(id)
	local entry = zclib.Data.Entrys[ id ]

	if not entry or not entry.Get then
		zclib.ErrorPrint("[" .. id .. "] > Data entry invalid!")

		return
	end

	local data = entry.Get()

	if not data then
		zclib.ErrorPrint("[" .. id .. "] > Returned Data invalid!")

		return
	end

	local list = {}

	for k, v in pairs(data) do
		if v == nil then continue end
		local uniqueid = v.uniqueid or zclib.util.GenerateUniqueID("xxxxxxxxxx")

		if istable(v) and v.uniqueid == nil then
			v.uniqueid = uniqueid
		end

		list[ uniqueid ] = k
	end

	entry.ListIDs = table.Copy(list)
	entry.OnIDListRebuild(list)
	zclib.Debug("zclib.Data.RebuildListIDs " .. entry.script .. " " .. id)
end

if CLIENT then

    // Called from interface after config change
    function zclib.Data.UpdateConfig(id)
        local entry = zclib.Data.Entrys[id]

        local e_String = util.TableToJSON(entry.Get())
        local e_Compressed = util.Compress(e_String)
        net.Start("zclib_Data_Update")
        net.WriteUInt(#e_Compressed,16)
        net.WriteData(e_Compressed,#e_Compressed)
        net.WriteString(id)
        net.SendToServer()

        zclib.Debug("zclib.Data.UpdateConfig " .. entry.script .. " " .. id .. " " .. tostring(LocalPlayer()))
    end

    // Called from SERVER after config UPDATE
    net.Receive("zclib_Data_Update", function(len)
        zclib.Debug_Net("zclib_Data_Update", len)

        local dataLength = net.ReadUInt(16)
        local dataDecompressed = util.Decompress(net.ReadData(dataLength))
        local config = util.JSONToTable(dataDecompressed)
        local id = net.ReadString()

        local entry = zclib.Data.Entrys[id]
        if entry == nil then
            zclib.Debug("zclib_Data_Update for " .. id .. " failed!")
            return
        end
		zclib.Debug("zclib_Data_Update " .. entry.script .. " " .. id .. " " .. tostring(LocalPlayer()) .. "[" .. (len / 8) .. " Bytes]")

        entry.OnReceived(config)

        zclib.Data.RebuildListIDs(id)
    end)

    for k,v in pairs(zclib.Data.Entrys) do
        zclib.Data.RebuildListIDs(k)
    end
else

	// Loads the Data Configs once the SERVER finished loading
	timer.Simple(2,function()
		zclib.Print("Setting up Data Entrys")
		for k,v in pairs(zclib.Data.Entrys) do

			if file.Exists(v.path, "DATA") then
				local config = file.Read(v.path,"DATA")
				if config then

					config = util.JSONToTable(config)

					zclib.Print(v.script .. " " .. k .. " - Data Config loaded!")

					v.OnLoaded(config)

					zclib.Data.UpdateConfig(k)
				end
			end

			zclib.Data.RebuildListIDs(k)
		end
	end)

    // Saves the Data config
    util.AddNetworkString("zclib_Data_Update")
    net.Receive("zclib_Data_Update", function(len,ply)
        zclib.Debug_Net("zclib_Data_Update", len)

        if zclib.Player.Timeout(nil,ply) == true then
            return
        end
        if zclib.Player.IsAdmin(ply) == false then
            return
        end

        local dataLength = net.ReadUInt(16)
        local dataDecompressed = util.Decompress(net.ReadData(dataLength))
        local config = util.JSONToTable(dataDecompressed)
        local id = net.ReadString()

        zclib.Data.Save(ply,id,config)
    end)

    function zclib.Data.Save(ply,id,config)
        local entry = zclib.Data.Entrys[id]

        zclib.Debug("zclib_Data_Update " .. entry.script .. " " .. id .. " " .. tostring(ply))

        entry.OnReceived(config)

		if entry.OnPreSave then config = entry.OnPreSave(config) end

        // Save to file
        file.Write(entry.path, util.TableToJSON(config,true))

        zclib.Data.RebuildListIDs(id)

        // Inform CLIENTS
        zclib.Data.UpdateConfig(id)
    end

	// Remove the whole file
	function zclib.Data.Remove(ply,id)
		if zclib.Player.IsAdmin(ply) == false then
			return
		end

		local entry = zclib.Data.Entrys[id]

		// Save to file
		file.Delete(entry.path)
	end

    // Informs all CLIENTS about the config change, This is usally only needed if the config gets changed mid game without a restart
    function zclib.Data.UpdateConfig(id)
        local entry = zclib.Data.Entrys[id]
        local e_String = util.TableToJSON(entry.Get())
        local e_Compressed = util.Compress(e_String)
        net.Start("zclib_Data_Update")
        net.WriteUInt(#e_Compressed,16)
        net.WriteData(e_Compressed,#e_Compressed)
        net.WriteString(id)
        net.Broadcast()

        entry.OnSend()
        zclib.Debug("zclib.Data.UpdateConfig " .. entry.script .. " " .. id)
    end

    function zclib.Data.Send(id,ply)
        local entry = zclib.Data.Entrys[id]
        if entry == nil then
            zclib.Debug("zclib.Data.Send Entry not found! " .. id .. tostring(ply))
            return
        end
        local data = entry.Get()
        if data == nil then
            zclib.Debug("zclib.Data.Send Data not found! " .. id .. tostring(ply))
            return
        end

        local e_String = util.TableToJSON(data)
        local e_Compressed = util.Compress(e_String)
        net.Start("zclib_Data_Update")
        net.WriteUInt(#e_Compressed,16)
        net.WriteData(e_Compressed,#e_Compressed)
        net.WriteString(id)
        net.Send(ply)

        entry.OnSend()

        zclib.Debug("zclib.Data.Send " .. entry.script .. " " .. id .. " " .. tostring(ply))
    end
end

function zclib.Data.Setup(id,script,path,Get,OnLoaded,OnSend,OnReceived,OnIDListRebuild,OnPreSave)
    zclib.Debug("zclib.Data.Setup " .. script .. " " .. id)
    zclib.Data.Entrys[id] = {
        // Returns the var of data
        Get = Get,

        // The name of the script
        script = script,

        // The path we save the data to
        path = path,

        // Run stuff after we loaded the data
        OnLoaded = OnLoaded,

        // Run stuff after we send the data
        OnSend = OnSend,

        // Run stuff after we received the data
        OnReceived = OnReceived,

        // Run stuff after we rebuild the id list
        OnIDListRebuild = OnIDListRebuild,

		// Can be used to modify the data before its getting saved
		OnPreSave = OnPreSave,
    }
end
