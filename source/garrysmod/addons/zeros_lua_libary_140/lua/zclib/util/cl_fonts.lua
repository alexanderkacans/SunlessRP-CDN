if SERVER then return end

zclib = zclib or {}
zclib.LoadedFonts = {}
zclib.FontData = {}

/*

	This system creates fonts on demand and only on demand

*/

zclib.Hook.Add("OnScreenSizeChanged", "zclib.LoadedFonts", function(oldWidth, oldHeight)
	zclib.LoadedFonts = {}

	zclib.Print("ScreenSize changed, Clearing font cache.")
end)

function zclib.GetFont(id)
	if zclib.LoadedFonts[id] then
		// Font already exists
		return id
	else

		local FontData = zclib.FontData[id] or zclib.FontData["zclib_font_big"]

		// Linux needs everything to be lowercase
		//if system.IsLinux() then
			FontData.font = string.lower(FontData.font)
		//end

		// Create Font
		surface.CreateFont(id, FontData)
		zclib.LoadedFonts[id] = true

		zclib.Print("Font " .. id .. " cached!")
		return id
	end
end

function zclib.AddFont(id,data) zclib.FontData[id] = data end

zclib.FontData["zclib_world_font_giant"] = {
	font = "Nexa Bold",
	extended = true,
	size = 100,
	weight = 200,
	antialias = true
}

zclib.FontData["zclib_world_font_large"] = {
	font = "Nexa Bold",
	extended = true,
	size = 90,
	weight = 200,
	antialias = true
}

zclib.FontData["zclib_world_font_big"] = {
	font = "Nexa Bold",
	extended = true,
	size = 70,
	weight = 200,
	antialias = true
}

zclib.FontData["zclib_world_font_medium"] = {
	font = "Nexa Bold",
	extended = true,
	size = 50,
	weight = 200,
	antialias = true
}

zclib.FontData["zclib_world_font_mediumsmall"] = {
	font = "Nexa Bold",
	extended = true,
	size = 35,
	weight = 200,
	antialias = true
}

zclib.FontData["zclib_world_font_mediumsmoll"] = {
	font = "Nexa Bold",
	extended = true,
	size = 29,
	weight = 200,
	antialias = true
}


zclib.FontData["zclib_world_font_small"] = {
	font = "Nexa Bold",
	extended = true,
	size = 25,
	weight = 200,
	antialias = true
}

zclib.FontData["zclib_world_font_tiny"] = {
	font = "Nexa Bold",
	extended = true,
	size = 20,
	weight = 200,
	antialias = true
}

zclib.FontData["zclib_world_font_verytiny"] = {
	font = "Nexa Bold",
	extended = true,
	size = 15,
	weight = 200,
	antialias = true
}

zclib.FontData["zclib_world_font_supertiny"] = {
	font = "Nexa Bold",
	extended = true,
	size = 12,
	weight = 200,
	antialias = true
}


zclib.FontData["zclib_font_ultra"] = {
	font = "Nexa Bold",
	extended = true,
	size = ScreenScale(100),
	weight = ScreenScale(500),
	antialias = true
}

zclib.FontData["zclib_font_giant"] = {
	font = "Nexa Bold",
	extended = true,
	size = ScreenScale(40),
	weight = ScreenScale(500),
	antialias = true
}

zclib.FontData["zclib_font_huge"] = {
	font = "Nexa Bold",
	extended = true,
	size = ScreenScale(30),
	weight = ScreenScale(500),
	antialias = true
}

zclib.FontData["zclib_font_large"] = {
	font = "Nexa Bold",
	extended = true,
	size = ScreenScale(25),
	weight = ScreenScale(100),
	antialias = true
}

zclib.FontData["zclib_font_bigger"] = {
	font = "Nexa Bold",
	extended = true,
	size = ScreenScale(20),
	weight = ScreenScale(100),
	antialias = true
}

zclib.FontData["zclib_font_big"] = {
	font = "Nexa Bold",
	extended = true,
	size = ScreenScale(15),
	weight = ScreenScale(100),
	antialias = true
}


zclib.FontData["zclib_font_medium"] = {
	font = "Nexa Bold",
	extended = true,
	size = ScreenScale(10),
	weight = ScreenScale(100),
	antialias = true
}

zclib.FontData["zclib_font_medium_thin"] = {
	font = "Nexa Light",
	extended = true,
	size = ScreenScale(10),
	weight = ScreenScale(1),
	antialias = true
}

zclib.FontData["zclib_font_mediumsmall"] = {
	font = "Nexa Bold",
	extended = true,
	size = ScreenScale(8),
	weight = ScreenScale(100),
	antialias = true
}

zclib.FontData["zclib_font_mediumsmall_blur"] = {
	font = "Nexa Bold",
	extended = true,
	size = ScreenScale(8),
	weight = ScreenScale(100),
	blursize = 5,
	antialias = true
}
zclib.FontData["zclib_font_mediumsmall_thin"] = {
	font = "Nexa Light",
	extended = true,
	size = ScreenScale(8),
	weight = ScreenScale(1),
	antialias = true
}

zclib.FontData["zclib_font_mediumsmoll_thin"] = {
	font = "Nexa Light",
	extended = true,
	size = ScreenScale(7),
	weight = ScreenScale(1),
	antialias = true
}


zclib.FontData["zclib_font_small"] = {
	font = "Nexa Bold",
	extended = true,
	size = ScreenScale(6),
	weight = ScreenScale(100),
	antialias = true
}

zclib.FontData["zclib_font_smoll"] = {
	font = "Nexa Light",
	extended = true,
	size = ScreenScale(5),
	weight = ScreenScale(100),
	antialias = true
}

zclib.FontData["zclib_font_small_thin"] = {
	font = "Nexa Light",
	extended = true,
	size = ScreenScale(6),
	weight = ScreenScale(1),
	antialias = true
}

zclib.FontData["zclib_font_tiny"] = {
	font = "Nexa Bold",
	extended = true,
	size = ScreenScale(5),
	weight = ScreenScale(100),
	antialias = true
}

zclib.FontData["zclib_font_makro"] = {
	font = "Nexa Bold",
	extended = true,
	size = ScreenScale(4),
	weight = ScreenScale(100),
	antialias = true
}


zclib.FontData["zclib_font_nano"] = {
	font = "Nexa Bold",
	extended = true,
	size = ScreenScale(3.5),
	weight = ScreenScale(100),
	antialias = true
}
