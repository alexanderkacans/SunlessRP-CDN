zclib = zclib or {}

if CLIENT then
	/*
		Keep track on cached fonts which are created
	*/
	zclib.CachedFonts = zclib.CachedFonts or {}
	local oldFontFunc = surface.CreateFont
	function surface.CreateFont(name,data)
		//print("surface.CreateFont: "..name)
		zclib.CachedFonts[name] = true
		oldFontFunc(name,data)
	end
	concommand.Add("zclib_print_fonts", function(ply, cmd, args)
		PrintTable(zclib.CachedFonts)
	end)
end


/*
	Keep track on cached fonts which are created
*/
zclib.CachedEffects = zclib.CachedEffects or {}
local oldPrecacheFunc = PrecacheParticleSystem
function PrecacheParticleSystem(name)
	zclib.CachedEffects[name] = true
	hook.Run("zclib_OnParticleSystemPrecached", name)
	oldPrecacheFunc(name)
end

function zclib.GetCachedEffects()
	local FoundEffects = {}

	for k, v in pairs(zclib.CachedEffects) do
		table.insert(FoundEffects, k)
	end

	return FoundEffects
end

timer.Simple(2,function()
	for k,v in pairs(zclib.CachedEffects) do
		hook.Run("zclib_OnParticleSystemPrecached", k)
	end
end)
concommand.Add("zclib_print_effects", function(ply, cmd, args)
	PrintTable(zclib.CachedEffects)
end)
