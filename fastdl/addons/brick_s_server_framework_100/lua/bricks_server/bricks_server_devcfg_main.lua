--[[
    !!WARNING!!
        ALL CONFIG IS DONE INGAME, DONT EDIT ANYTHING HERE
        Type !bricksserver ingame or use the f4menu
    !!WARNING!!
]]--

BRICKS_SERVER.DEVCONFIG.BaseThemes = {}
BRICKS_SERVER.DEVCONFIG.BaseThemes.Red = Color(201, 70, 70)
BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed = Color(181, 50, 50)
BRICKS_SERVER.DEVCONFIG.BaseThemes.Green = Color(46, 204, 113)
BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen = Color(39, 174, 96)
BRICKS_SERVER.DEVCONFIG.BaseThemes.Gold = Color(201,176,55)
BRICKS_SERVER.DEVCONFIG.BaseThemes.Silver = Color(180,180,180)
BRICKS_SERVER.DEVCONFIG.BaseThemes.Bronze = Color(173,138,86)
BRICKS_SERVER.DEVCONFIG.BaseThemes.White = Color( 255, 255, 255 )
BRICKS_SERVER.DEVCONFIG.BaseThemes.Black = Color( 0, 0, 2505 )

BRICKS_SERVER.DEVCONFIG.AccentThemes = {}
BRICKS_SERVER.DEVCONFIG.AccentThemes["Turquoise"] = { Color(22, 160, 133), Color(26, 188, 156) }
BRICKS_SERVER.DEVCONFIG.AccentThemes["Emerald"] = { Color(39, 174, 96), Color(46, 204, 113) }
BRICKS_SERVER.DEVCONFIG.AccentThemes["Blue"] = { Color(41, 128, 185), Color(52, 152, 219) }
BRICKS_SERVER.DEVCONFIG.AccentThemes["Amethyst"] = { Color(142, 68, 173), Color(155, 89, 182) }
BRICKS_SERVER.DEVCONFIG.AccentThemes["Yellow"] = { Color(243, 156, 18), Color(241, 196, 15) }
BRICKS_SERVER.DEVCONFIG.AccentThemes["Orange"] = { Color(211, 84, 0), Color(230, 126, 34) }
BRICKS_SERVER.DEVCONFIG.AccentThemes["Red"] = { Color(181, 50, 50), Color(201, 70, 70) }

BRICKS_SERVER.DEVCONFIG.BackgroundThemes = {}
BRICKS_SERVER.DEVCONFIG.BackgroundThemes["Dark"] = { Color(25, 25, 25), Color(40, 40, 40), Color(49, 49, 49), Color(68, 68, 68), Color( 255, 255, 255 ) }
BRICKS_SERVER.DEVCONFIG.BackgroundThemes["DarkBlue"] = { Color(26, 41, 56), Color(36, 51, 66), Color(44, 62, 80), Color(52, 73, 94), Color( 255, 255, 255 ) }
BRICKS_SERVER.DEVCONFIG.BackgroundThemes["Light"] = { Color(152, 157, 161), Color(170, 177, 182), Color(189, 195, 199), Color(236, 240, 241), Color( 0, 0, 0 ) }
BRICKS_SERVER.DEVCONFIG.BackgroundThemes["Grey"] = { Color(101, 115, 116), Color(111, 125, 126), Color(127, 140, 141), Color(149, 165, 166), Color( 255, 255, 255 ) }

BRICKS_SERVER.DEVCONFIG.EntityTypes = BRICKS_SERVER.DEVCONFIG.EntityTypes or {}
BRICKS_SERVER.DEVCONFIG.EntityTypes["bricks_server_npc"] = { 
    GetDataFunc = function( entity ) 
        return entity:GetNPCKeyVar() or 0
    end,
    SetDataFunc = function( entity, data ) 
        return entity:SetNPCKey( data or 0 )
    end
}

BRICKS_SERVER.DEVCONFIG.NPCTypes = BRICKS_SERVER.DEVCONFIG.NPCTypes or {}

BRICKS_SERVER.DEVCONFIG.WeaponModels = {
    ["weapon_ar2"] = "models/weapons/w_irifle.mdl",
    ["weapon_bugbait"] = "models/weapons/w_bugbait.mdl",
    ["weapon_crossbow"] = "models/weapons/w_crossbow.mdl",
    ["weapon_crowbar"] = "models/weapons/w_crowbar.mdl",
    ["weapon_frag"] = "models/weapons/w_grenade.mdl",
    ["weapon_physcannon"] = "models/weapons/w_Physics.mdl",
    ["weapon_pistol"] = "models/weapons/w_pistol.mdl",
    ["weapon_rpg"] = "models/weapons/w_rocket_launcher.mdl",
    ["weapon_shotgun"] = "models/weapons/w_shotgun.mdl",
    ["weapon_slam"] = "models/weapons/w_slam.mdl",
    ["weapon_smg1"] = "models/weapons/w_smg1.mdl",
    ["weapon_stunstick"] = "models/weapons/w_stunbaton.mdl",
    ["weapon_medkit"] = "models/weapons/w_medkit.mdl",
    ["weapon_physgun"] = "models/weapons/w_Physics.mdl",
    ["gmod_tool"] = "models/weapons/w_toolgun.mdl",

    ["arrest_stick"] = "models/weapons/w_stunbaton.mdl",
    ["unarrest_stick"] = "models/weapons/w_stunbaton.mdl",
    ["stunstick"] = "models/weapons/w_stunbaton.mdl",
    ["weaponchecker"] = "models/weapons/v_hands.mdl",
}

BRICKS_SERVER.DEVCONFIG.KEY_BINDS = {
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z",
    "Numpad 0",
    "Numpad 1",
    "Numpad 2",
    "Numpad 3",
    "Numpad 4",
    "Numpad 5",
    "Numpad 6",
    "Numpad 7",
    "Numpad 8",
    "Numpad 0",
    "Numpad /",
    "Numpad *",
    "Numpad -",
    "Numpad +",
    "Numpad Enter",
    "Numpad .",
    "(",
    ")",
    ";",
    "'",
    "`",
    ",",
    ".",
    "/",
    [[\]],
    "-",
    "=",
    "Enter",
    "Space",
    "Backspace",
    "Tab",
    "Capslock",
    "Numlock",
    "Escape",
    "Scrolllock",
    "Insert",
    "Delete",
    "Home",
    "End",
    "Pageup",
    "Pagedown",
    "Break",
    "Left Shift",
    "Right Shift",
    "Alt",
    "Right Alt",
    "Left Control",
    "Right Control",
    "Left Windows",
    "Right Windows",
    "App",
    "Up",
    "Left",
    "Down",
    "Right",
    "F1",
    "F2",
    "F3",
    "F4",
    "F5",
    "F6",
    "F7",
    "F8",
    "F9",
    "F10",
    "F11",
    "F12",
    "Capslock Toggle",
    "Numlock Toggle",
    "Last",
    "Count"
}

-- Inventory --
BRICKS_SERVER.DEVCONFIG.INVENTORY = BRICKS_SERVER.DEVCONFIG.INVENTORY or {}
BRICKS_SERVER.DEVCONFIG.INVENTORY.DefaultEntFuncs = {
    GetItemData = function( ent )
        local itemData = { ent:GetClass(), ent:GetModel() }
        
        return itemData, 1
    end,
    OnSpawn = function( ply, pos, itemData )
        local ent = ents.Create( itemData[1] )
        if( not IsValid( ent ) ) then return end
        ent:SetPos( pos )
        ent:SetModel( itemData[2] )
        ent:Spawn()
        if( ent.CPPISetOwner ) then ent:CPPISetOwner( ply ) end
        if( ent.Setowning_ent ) then ent:Setowning_ent( ply ) end
    end,
    ModelDisplay = function( Panel, itemData )
        if( not Panel.Entity or not IsValid( Panel.Entity ) ) then return end

        local mn, mx = Panel.Entity:GetRenderBounds()
        local size = 0
        size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
        size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
        size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

        Panel:SetFOV( 65 )
        Panel:SetCamPos( Vector( size, size, size ) )
        Panel:SetLookAt( (mn + mx) * 0.5 )
    end,
    GetInfo = function( itemData )
        local name = BRICKS_SERVER.Func.GetList( "entities" )[itemData[1] or ""] or (itemData[1] or "Unknown")
        return { name, "Some " .. name .. ".", (BRICKS_SERVER.CONFIG.INVENTORY.ItemRarities or {})[itemData[1] or ""] }
    end,
    GetItemKey = function( itemData )
        return itemData[1]
    end,
    CanCombine = function( itemData1, itemData2 )
        if( itemData1[1] == itemData2[1] ) then
            return true
        end

        return false
    end,
}

BRICKS_SERVER.DEVCONFIG.RarityTypes = {}
BRICKS_SERVER.DEVCONFIG.RarityTypes["SolidColor"] = {
    Title = "Solid Color"
}
BRICKS_SERVER.DEVCONFIG.RarityTypes["Gradient"] = {
    Title = "Gradient"
}
BRICKS_SERVER.DEVCONFIG.RarityTypes["Fade"] = {
    Title = "Fade"
}
BRICKS_SERVER.DEVCONFIG.RarityTypes["Rainbow"] = {
    Title = "Rainbow"
}

BRICKS_SERVER.DEVCONFIG.Currencies = BRICKS_SERVER.DEVCONFIG.Currencies or {}
local function loadCurrencies()
    if( DarkRP ) then
        BRICKS_SERVER.DEVCONFIG.Currencies["darkrp_money"] = {
            Title = "DarkRP Money",
            getFunction = function( ply )
                return ply:getDarkRPVar( "money" )
            end,
            addFunction = function( ply, amount )
                ply:addMoney( amount )
            end,
            formatFunction = function( amount )
                return DarkRP.formatMoney( amount )
            end
        }
    end

    if( BRICKSCREDITSTORE ) then
        BRICKS_SERVER.DEVCONFIG.Currencies["brcs_credits"] = {
            Title = "Credits",
            getFunction = function( ply )
                return ply:GetBRCS_Credits()
            end,
            addFunction = function( ply, amount )
                ply:AddBRCS_Credits( amount )
            end,
            formatFunction = function( amount )
                return BRICKSCREDITSTORE.FormatCredits( amount )
            end
        }
    end

    if( mTokens ) then
        BRICKS_SERVER.DEVCONFIG.Currencies["mtokens"] = {
            Title = "mTokens",
            getFunction = function( ply )
                return ((SERVER and mTokens.GetPlayerTokens(ply)) or (CLIENT and mTokens.PlayerTokens)) or 0
            end,
            addFunction = function( ply, amount )
                if( amount > 0 ) then
                    mTokens.AddPlayerTokens(ply, amount)
                else
                    mTokens.TakePlayerTokens(ply, math.abs(amount))
                end
            end,
            formatFunction = function( amount )
                return string.Comma( amount ) .. " Tokens"
            end
        }
    end
    
    BRICKS_SERVER.DEVCONFIG.Currencies["ps2_points"] = {
        Title = "PS2 Points",
        getFunction = function( ply )
            return (ply.PS2_Wallet or {}).points or 0
        end,
        addFunction = function( ply, amount )
            ply:PS2_AddStandardPoints( amount )
        end,
        formatFunction = function( amount )
            return string.Comma( amount ) .. " Points"
        end
    }

    BRICKS_SERVER.DEVCONFIG.Currencies["ps2_premium_points"] = {
        Title = "PS2 Premium Points",
        getFunction = function( ply )
            return (ply.PS2_Wallet or {}).premiumPoints or 0
        end,
        addFunction = function( ply, amount )
            ply:PS2_AddPremiumPoints( amount )
        end,
        formatFunction = function( amount )
            return string.Comma( amount ) .. " Premium Points"
        end
    }

    BRICKS_SERVER.DEVCONFIG.Currencies["ps1_points"] = {
        Title = "PS1 Points",
        getFunction = function( ply )
            return ply:PS_GetPoints() or 0
        end,
        addFunction = function( ply, amount )
            ply:PS_GivePoints( amount )
        end,
        formatFunction = function( amount )
            return string.Comma( amount ) .. " Points"
        end
    }

    if( SH_POINTSHOP ) then
        BRICKS_SERVER.DEVCONFIG.Currencies["sh_points"] = {
            Title = "SH Points",
            getFunction = function( ply )
                return ply:SH_GetStandardPoints()
            end,
            addFunction = function( ply, amount )
                ply:SH_AddStandardPoints( amount )
            end,
            formatFunction = function( amount )
                return string.Comma( amount ) .. " Points"
            end
        }

        BRICKS_SERVER.DEVCONFIG.Currencies["sh_premium_points"] = {
            Title = "SH Premium Points",
            getFunction = function( ply )
                return ply:SH_GetPremiumPoints()
            end,
            addFunction = function( ply, amount )
                ply:SH_AddPremiumPoints( amount )
            end,
            formatFunction = function( amount )
                return string.Comma( amount ) .. " Premium Points"
            end
        }
    end
end

if( gmod.GetGamemode() ) then
    loadCurrencies()
else
    hook.Add( "OnGamemodeLoaded", "BRS.OnGamemodeLoaded.DevConfig", loadCurrencies )
end