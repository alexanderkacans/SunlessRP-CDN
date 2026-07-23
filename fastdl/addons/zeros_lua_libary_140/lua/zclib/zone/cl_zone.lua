if SERVER then return end
zclib = zclib or {}
zclib.Zone = zclib.Zone or {}

net.Receive("zclib_Zone_Send", function(len)
    zclib.Debug_Net("zclib_Zone_Send", len)
    local entryid = net.ReadString()
    local dataLength = net.ReadUInt(16)
    local dataDecompressed = util.Decompress(net.ReadData(dataLength))
    local data = util.JSONToTable(dataDecompressed)

    if data and istable(data) then
        zclib.Zone.Set(entryid,data)
    end
end)

net.Receive("zclib_Zone_Show", function(len)
    zclib.Debug_Net("zclib_Zone_Show", len)
    local entryid = net.ReadString()
	local showall = net.ReadBool()
    zclib.Zone.Preview_Start(entryid,showall)
end)

net.Receive("zclib_Zone_Hide", function(len)
    zclib.Debug_Net("zclib_Zone_Hide", len)
    zclib.Zone.Preview_Stop()
end)

local function HasToolActive(entryid,ply)
    if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "gmod_tool" then
        local tool = ply:GetTool()
        if tool and table.Count(tool) > 0 and IsValid(tool.SWEP) and tool.Mode == zclib.Zone.GetToolName(entryid) then
            return tool
        else
            return false
        end
    else
        return false
    end
end

local RenderHook = "HUDPaint"

local CurEntryid
function zclib.Zone.Preview_Start(entryid,showall)

    if zclib.Hook.Exist(RenderHook, "zclib_zone_preview") and CurEntryid == entryid then return end

	zclib.Zone.Preview_Stop()
	zclib.Debug("zclib.Zone.Preview_Start " .. entryid)
    local ply = LocalPlayer()
	CurEntryid = entryid

    zclib.Hook.Add(RenderHook, "zclib_zone_preview", function(bDrawingDepth, bDrawingSkybox, isDraw3DSkybox)
        if isDraw3DSkybox then return end

        if not IsValid(ply) or ply:Alive() == false then
            zclib.Zone.Preview_Stop()
        end

        if HasToolActive(entryid,ply) == false then
            zclib.Zone.Preview_Stop()
        end

        local tr = ply:GetEyeTrace()
        if not tr.Hit or not tr.HitPos then return end

		local npos = zclib.Zone.GetTracePos(entryid, ply, tr)

		cam.Start3D(EyePos(),EyeAngles(),nil,0,0,ScrW(),ScrH(),1,100000000000)

        render.SetColorMaterial()
        render.DrawWireframeSphere( npos, 5,9, 9,zclib.colors["zone_green01"], true )

        if ply.zclib_ZoneStart and npos then
			if zclib.Zone.GetFreeSize(entryid) then
				local zoneSize = zclib.Zone.GetFinalSize(entryid,tr,ply.zclib_ZoneStart,npos)
	            render.SetColorMaterial()
				render.DrawBox(ply.zclib_ZoneStart, angle_zero, vector_origin, zoneSize,zclib.colors["zone_green01"])
	            render.DrawWireframeBox(ply.zclib_ZoneStart, angle_zero, vector_origin, zoneSize,zclib.colors["zone_green01"], true)
			else

				local vec01 = Vector(0, 0,zclib.Zone.GetHeight(entryid) - zclib.Zone.GetExtraHeight(entryid))

				local zoneSize = zclib.Zone.GetSize(entryid,ply.zclib_ZoneStart,npos)

				render.SetColorMaterial()
				render.DrawBox(ply.zclib_ZoneStart - vec01, angle_zero, vector_origin, zoneSize,zclib.colors["zone_green01"])
	            render.DrawWireframeBox(ply.zclib_ZoneStart - vec01, angle_zero, vector_origin, zoneSize,zclib.colors["zone_green01"], true)
			end
        end

        zclib.Zone.DrawAll(entryid,tr.HitPos,function(zone_id,pos)
            return zclib.Zone.Check(entryid,zone_id,tr.HitPos or vector_origin) and zclib.colors["zone_green01"] or zclib.colors["zone_white"]
        end)

		cam.End3D()
    end)

	zclib.Hook.Add("PostDrawTranslucentRenderables", "zclib_zone_preview",function(bDrawingDepth, bDrawingSkybox, isDraw3DSkybox)
		if isDraw3DSkybox then return end

		if not IsValid(ply) or ply:Alive() == false then
			zclib.Zone.Preview_Stop()
		end

		if HasToolActive(entryid,ply) == false then
			zclib.Zone.Preview_Stop()
		end

		local tr = ply:GetEyeTrace()
		if not tr.Hit or not tr.HitPos then return end


		zclib.Zone.DrawAll(entryid,tr.HitPos,function(zone_id,pos)
			return zclib.Zone.Check(entryid,zone_id,tr.HitPos or vector_origin) and zclib.colors["zone_green01"] or zclib.colors["zone_white"]
		end)
	end)
end

function zclib.Zone.Preview_Stop()
    zclib.Hook.Remove(RenderHook, "zclib_zone_preview")
	zclib.Hook.Remove("PostDrawTranslucentRenderables", "zclib_zone_preview")
end

function zclib.Zone.Draw(entry,zone_id,zone_data,size,pos,check,entryid)

    local asize
	if zclib.Zone.GetFreeSize(entryid) then
		asize = Vector(size.x,size.y,size.z)
	else
		asize = Vector(size.x,size.y,((entry.BaseHeight or 200) * 2) + (entry.ExtraHeight or 200))
	end

    local thickPos,thickSize = zclib.Zone.GetThickness(entryid,pos,asize)
    if thickPos and thickSize then
        pos = pos + thickPos
        asize = asize + thickSize
    end

	render.SetColorMaterial()
    local color = check(zone_id,pos)
    if entry.FillZone then
        render.DrawBox(pos, angle_zero, vector_origin, asize, color)
    end
    render.DrawWireframeBox(pos, angle_zero, vector_origin, asize, color, entry.WriteZ == nil and true or entry.WriteZ)

	cam.IgnoreZ(true)
    cam.Start3D2D(pos + (size / 2) + Vector(0, 0, entry.BaseHeight or 200), zclib.HUD.GetLookAngles(), 1)
        entry.DrawZone(zone_id,zone_data)
    cam.End3D2D()
	cam.IgnoreZ(false)
end

function zclib.Zone.DrawAll(entryid,pos,check)
    local entry = zclib.Zone.GetEntry(entryid)
    if entry == nil then return end

	// Overwrites the DrawAll zones function
	if entry.DrawAllOverwrite then
		entry.DrawAllOverwrite(entryid,pos,check)
	else
		for k, v in pairs(zclib.Zone.GetData(entryid)) do
	        if v and v.pos and v.size then
	            zclib.Zone.Draw(entry,k,v,v.size,v.pos,check,entryid)
	        end
	    end
	end
end

////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////

net.Receive("zclib_Zone_ShowSingle", function(len)
    zclib.Debug_Net("zclib_Zone_ShowSingle", len)
    local entryid = net.ReadString()
    local zoneid = net.ReadUInt(16)
    zclib.Zone.DrawSingle(entryid,zoneid)
end)

function zclib.Zone.DrawSingle(entryid,zoneid)

    local entry = zclib.Zone.GetEntry(entryid)
    if entry == nil then return end

    local zonelist = entry.GetData()
    if zonelist == nil then return end

    local zoneData = zonelist[zoneid]
    if zoneData == nil then return end

    local FinishTime = CurTime() + 10

    zclib.Hook.Remove(RenderHook, "zclib_zone_preview")
    local ply = LocalPlayer()
    zclib.Hook.Add(RenderHook, "zclib_zone_preview", function(bDrawingDepth, bDrawingSkybox, isDraw3DSkybox)
        if isDraw3DSkybox then return end

        if not IsValid(ply) or ply:Alive() == false then
            zclib.Hook.Remove(RenderHook, "zclib_zone_preview")
        end

        if CurTime() >= FinishTime then
            zclib.Hook.Remove(RenderHook, "zclib_zone_preview")
        end

        zclib.Zone.Draw(entry,zoneid,zoneData,zoneData.size,zoneData.pos,function() return zclib.colors["zone_red01"] end,entryid)
    end)

	zclib.Hook.Remove("PostDrawTranslucentRenderables", "zclib_zone_preview")
	zclib.Hook.Add("PostDrawTranslucentRenderables", "zclib_zone_preview", function(bDrawingDepth, bDrawingSkybox, isDraw3DSkybox)
		if isDraw3DSkybox then return end

		if not IsValid(ply) or ply:Alive() == false then
			zclib.Hook.Remove("PostDrawTranslucentRenderables", "zclib_zone_preview")
		end

		if CurTime() >= FinishTime then
			zclib.Hook.Remove("PostDrawTranslucentRenderables", "zclib_zone_preview")
		end

		zclib.Zone.Draw(entry,zoneid,zoneData,zoneData.size,zoneData.pos,function() return zclib.colors["zone_red01"] end,entryid)
	end)
end
