zclib = zclib or {}

function zclib.Debug(mgs)
	if zclib.config.Debug then
		if istable(mgs) then
			print("[    DEBUG    ] Table Start >")
			PrintTable(mgs)
			print("[    DEBUG    ] Table End <")
		else
			print("[    DEBUG    ] [" .. math.Round(CurTime(), 2) .. "] " .. mgs)
		end
	end
end

function zclib.Debug_Net(NetworkString,Len)
	zclib.Debug("[" .. NetworkString .. "][" .. (Len / 8) .. " Bytes]")
end

function zclib.ConCommand(command,func)
	concommand.Add(command, function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then
			pcall(func,ply, cmd, args)
	    end
	end)
end

// Custom debug function which only debugs objects which have debug enabled
function zclib.Debug_Entity(ent, msg)
	if ent.Debug == nil or ent.Debug == false then return end
	print(tostring(ent) .. " " .. msg)
	debugoverlay.Sphere(ent:GetPos(), 20, 1, Color(255, 0, 255, 25), true)
end

zclib.ConCommand("zclib_debug_setmodel",function(ply,cmd,args)
	if zclib.Player.IsAdmin(ply) then ply:SetModel(args[1]) end
end)
