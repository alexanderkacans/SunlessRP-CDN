--[[
    !!WARNING!!
        ALL CONFIG IS DONE INGAME, DONT EDIT ANYTHING HERE
        Type !bricksserver ingame
    !!WARNING!!
]]--

--[[ MODULES CONFIG ]]--
BRICKS_SERVER.BASECONFIG.MODULES = BRICKS_SERVER.BASECONFIG.MODULES or {}
BRICKS_SERVER.BASECONFIG.MODULES["default"] = { true, {
    ["currencies"] = true
} }

--[[ GENERAL CONFIG ]]--
BRICKS_SERVER.BASECONFIG.GENERAL = BRICKS_SERVER.BASECONFIG.GENERAL or {}
BRICKS_SERVER.BASECONFIG.GENERAL["Donate Link"] = "https://www.blackrockgaming.co.uk/donate"
BRICKS_SERVER.BASECONFIG.GENERAL["Server Name"] = "BRG"
BRICKS_SERVER.BASECONFIG.GENERAL["3D2D Display Distance"] = 500000
BRICKS_SERVER.BASECONFIG.GENERAL["Use Textured Gradients (Better FPS)"] = true
BRICKS_SERVER.BASECONFIG.GENERAL.AdminPermissions = { 
    ["superadmin"] = true, 
    ["founder"] = true, 
    ["owner"] = true 
}
BRICKS_SERVER.BASECONFIG.GENERAL.Groups = {
    [1] = { "Staff", { ["moderator"] = true, ["admin"] = true, ["superadmin"] = true } },
    [2] = { "VIP++", { ["vip++"] = true, ["superadmin"] = true }, Color(201,176,55) },
    [3] = { "VIP+", { ["vip+"] = true, ["vip++"] = true, ["superadmin"] = true }, Color(180,180,180) },
    [4] = { "VIP", { ["vip"] = true, ["vip+"] = true, ["vip++"] = true, ["superadmin"] = true }, Color(173,138,86) },
    [5] = { "User", {}, Color(201, 70, 70), true }
}
BRICKS_SERVER.BASECONFIG.GENERAL.Rarities = {
    [1] = { "Common", "Gradient", { Color( 154, 154, 154 ), Color( 154*1.5, 154*1.5, 154*1.5 ) } },
    [2] = { "Uncommon", "Gradient", { Color( 104, 255, 104 ), Color( 104*1.5, 255*1.5, 104*1.5 ) } },
    [3] = { "Rare", "Gradient", { Color( 42, 133, 219 ),Color( 42*1.5, 133*1.5, 219*1.5 )  } },
    [4] = { "Epic", "Gradient", { Color( 152, 68, 255 ), Color( 152*1.5, 68*1.5, 255*1.5 ) } },
    [5] = { "Legendary", "Gradient", { Color( 253, 162, 77 ), Color( 253*1.5, 162*1.5, 77*1.5 ) } },
    [6] = { "Glitched", "Rainbow" }
}

--[[ LANGUAGE CONFIG ]]--
BRICKS_SERVER.BASECONFIG.LANGUAGE = {}
BRICKS_SERVER.BASECONFIG.LANGUAGE.Language = "english"
BRICKS_SERVER.BASECONFIG.LANGUAGE.Languages = {}

--[[ THEME CONFIG ]]--
BRICKS_SERVER.BASECONFIG.THEME = {}
BRICKS_SERVER.BASECONFIG.THEME[0] = Color(25, 25, 25)
BRICKS_SERVER.BASECONFIG.THEME[1] = Color(40, 40, 40)
BRICKS_SERVER.BASECONFIG.THEME[2] = Color(49, 49, 49)
BRICKS_SERVER.BASECONFIG.THEME[3] = Color(68, 68, 68)
BRICKS_SERVER.BASECONFIG.THEME[4] = Color(181, 50, 50)
BRICKS_SERVER.BASECONFIG.THEME[5] = Color(201, 70, 70)
BRICKS_SERVER.BASECONFIG.THEME[6] = Color(255, 255, 255)

--[[ INVENTORY ]]--
BRICKS_SERVER.BASECONFIG.INVENTORY = BRICKS_SERVER.BASECONFIG.INVENTORY or {}
BRICKS_SERVER.BASECONFIG.INVENTORY.ItemRarities = {
    ["Wood"] = "Uncommon",
    ["Scrap"] = "Uncommon",
    ["Iron"] = "Common",
    ["Plastic"] = "Common",
    ["Ruby"] = "Rare",
    ["Diamond"] = "Epic",
    ["weapon_ak472"] = "Legendary",
    ["weapon_deagle2"] = "Rare",
    ["weapon_fiveseven2"] = "Common",
    ["weapon_glock2"] = "Common",
    ["weapon_p2282"] = "Common",
    ["weapon_m42"] = "Rare",
    ["weapon_mac102"] = "Uncommon",
    ["weapon_mp52"] = "Uncommon",
    ["weapon_pumpshotgun2"] = "Uncommon",
    ["ls_sniper"] = "Epic",
}
BRICKS_SERVER.BASECONFIG.INVENTORY.Whitelist = {
    ["spawned_shipment"] = { true, true },
    ["spawned_weapon"] = { true, true },
    ["bricks_server_ink"] = { false, true },
    ["bricks_server_resource"] = { false, true },
    ["bricks_server_resource_wood"] = { false, true },
    ["bricks_server_resource_scrap"] = { false, true },
    ["bricks_server_resource_iron"] = { false, true },
    ["bricks_server_resource_plastic"] = { false, true },
    ["bricks_server_resource_ruby"] = { false, true },
    ["bricks_server_resource_diamond"] = { false, true }
}

--[[ NPCS ]]--
BRICKS_SERVER.BASECONFIG.NPCS = BRICKS_SERVER.BASECONFIG.NPCS or {}