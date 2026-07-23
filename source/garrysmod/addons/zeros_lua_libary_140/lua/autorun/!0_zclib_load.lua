local function NicePrint(txt)
	if SERVER then
		MsgC(Color(84, 150, 197), txt .. "\n")
	else
		MsgC(Color(193, 193, 98), txt .. "\n")
	end
end

local function PreLoadFile(path)
	if CLIENT then
		include(path)
	else
		AddCSLuaFile(path)
		include(path)
	end
end

local function LoadFiles(path)
	local files, _ = file.Find(path .. "/*", "LUA")

	for _, v in pairs(files) do
		if string.sub(v, 1, 3) == "sh_" then
			if CLIENT then
				include(path .. "/" .. v)
			else
				AddCSLuaFile(path .. "/" .. v)
				include(path .. "/" .. v)
			end
		end
	end

	for _, v in pairs(files) do
		if string.sub(v, 1, 3) == "cl_" then
			if CLIENT then
				include(path .. "/" .. v)
			else
				AddCSLuaFile(path .. "/" .. v)
			end
		elseif string.sub(v, 1, 3) == "sv_" then
			include(path .. "/" .. v)
		end
	end
end

local function Initialize()

	PreLoadFile("zclib/sh_main_config.lua")
	PreLoadFile("zclib/util/sh_atracker.lua")
	LoadFiles("zclib/util")
	LoadFiles("zclib/util/player")
	LoadFiles("zclib/generic")
	LoadFiles("zclib/data")
	LoadFiles("zclib/zone")
	LoadFiles("zclib/inventory")
	LoadFiles("zclib/inventory/vgui")

	NicePrint(" ")
	NicePrint("Zeros Libary loaded!")
	NicePrint(" ")
end

Initialize()
