net.Receive( "BRS.Net.SendConfig", function( len, ply )
    if( not BRICKS_SERVER.TEMP.Configs ) then
        BRICKS_SERVER.TEMP.Configs = {}
    end

    local uniqueStr = net.ReadString()
    local currentPart = net.ReadUInt( 5 )
    local totalParts = net.ReadUInt( 5 )
    local dataLen = net.ReadUInt( 16 )
    local partData = net.ReadData( dataLen )

    if( currentPart > 1 ) then
        if( BRICKS_SERVER.TEMP.Configs[uniqueStr] ) then
            BRICKS_SERVER.TEMP.Configs[uniqueStr] = BRICKS_SERVER.TEMP.Configs[uniqueStr] .. partData
        end
    else
        BRICKS_SERVER.TEMP.Configs[uniqueStr] = partData
    end

    if( currentPart == totalParts and BRICKS_SERVER.TEMP.Configs[uniqueStr] ) then
        if( totalParts > 1 and not BRICKS_SERVER.TEMP.Configs[uniqueStr] ) then return end

        local configUnCompressed = util.JSONToTable( util.Decompress( BRICKS_SERVER.TEMP.Configs[uniqueStr] ) ) or BRICKS_SERVER.BASECONFIG

        if( not BRICKS_SERVER.CONFIG ) then
            BRICKS_SERVER.CONFIG = table.Copy( configUnCompressed ) or {}
        else
            for k, v in pairs( configUnCompressed ) do
                BRICKS_SERVER.CONFIG[k] = v
            end
        end
    
        if( BRICKS_SERVER.Func.HasAdminAccess and BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then
            BS_ConfigCopyTable = table.Copy( BRICKS_SERVER.CONFIG )
        end
    
        hook.Run( "BRS.Hooks.ConfigReceived", configUnCompressed )
    
        RunConsoleCommand( "spawnmenu_reload" )
    end
end )

local function GetImageFromURL( url, failFunc )
    local CRC = util.CRC( url )
    local Extension = string.Split( url, "." )
    Extension = Extension[#Extension] or "png"

    if( not file.Exists( "bricks_server/images", "DATA" ) ) then
        file.CreateDir( "bricks_server/images" )
    end
    
    if( file.Exists( "bricks_server/images/" .. CRC .. "." .. Extension, "DATA" ) ) then
        BRICKS_SERVER.CachedMaterials[url] = Material( "data/bricks_server/images/" .. CRC .. "." .. Extension )

        if( failFunc ) then
            failFunc( BRICKS_SERVER.CachedMaterials[url], key )
        end

        return BRICKS_SERVER.CachedMaterials[url], key
    else
        http.Fetch( url, function( body )
            file.Write( "bricks_server/images/" .. CRC .. "." .. Extension, body )
            BRICKS_SERVER.CachedMaterials[url] = Material( "data/bricks_server/images/" .. CRC .. "." .. Extension )

            if( failFunc ) then
                failFunc( BRICKS_SERVER.CachedMaterials[url], key )
            end
        end )
    end
end

BRICKS_SERVER.CachedMaterials = {}

function BRICKS_SERVER.Func.CacheImageFromURL( url, failFunc )
    BRICKS_SERVER.CachedMaterials[url] = false

    if( not BRICKS_SERVER.CachedMaterials[url] ) then
        BRICKS_SERVER.CachedMaterials[url] = GetImageFromURL( url, failFunc )
    end
end

function BRICKS_SERVER.Func.CacheImageFromFile( filePath, fileName )
    BRICKS_SERVER.CachedMaterials[fileName] = Material( filePath )
end

function BRICKS_SERVER.Func.GetImage( key, onGetFunc )
    if( BRICKS_SERVER.CachedMaterials[key] ) then
        if( onGetFunc ) then
            onGetFunc( BRICKS_SERVER.CachedMaterials[key], key )
        else
            return BRICKS_SERVER.CachedMaterials[key], key
        end
    else
        if( string.StartWith( key, "http") ) then
            BRICKS_SERVER.Func.CacheImageFromURL( key, onGetFunc )
        end
    end
end

local files, directories = file.Find( "materials/bricks_server/*", "GAME" )
for k, v in pairs( files ) do
    BRICKS_SERVER.CachedMaterials[v] = Material( "materials/bricks_server/" .. v )
end

net.Receive( "BRS.Net.ProfileAdminSend", function( len, ply )
	local requestedID64 = net.ReadString()
	local profileTable = net.ReadTable()

	if( not requestedID64 or not profileTable ) then return end
	local requestedPly = player.GetBySteamID64( requestedID64 )

	if( IsValid( requestedPly ) ) then
		if( IsValid( BS_ADMIN_PROFILE ) and BS_ADMIN_PROFILE:IsVisible() and BS_ADMIN_PROFILE.RefreshProfile ) then
			BS_ADMIN_PROFILE:RefreshProfile( requestedID64, profileTable )
		end
	else
		notification.AddLegacy( BRICKS_SERVER.Func.L( "invalidPlayerProfile" ), 1, 5 )
	end
end )

function BRICKS_SERVER.Func.ConfigChange( moduleKey )
    if( not BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then return end

    if( (BS_ConfigsChanged or {})[moduleKey] ) then return end

    if( not BS_ConfigsChanged ) then
        BS_ConfigsChanged = {}
    end

    BS_ConfigsChanged[moduleKey] = true
end

function BRICKS_SERVER.Func.LoadClientConfig()
    BRICKS_SERVER.CLIENTCONFIG = BRICKS_SERVER.CLIENTCONFIG or {}

    for k, v in pairs( BRICKS_SERVER.BASECLIENTCONFIG ) do
        local type = v[2] or ""

        if( type == "number" or type == "bind" ) then
            BRICKS_SERVER.CLIENTCONFIG[k] = cookie.GetNumber( "bricks_server_" .. k, v[3] or 0 )
        elseif( type == "bool" ) then
            BRICKS_SERVER.CLIENTCONFIG[k] = tobool( cookie.GetNumber( "bricks_server_" .. k, v[3] or 0 ) )
        else
            BRICKS_SERVER.CLIENTCONFIG[k] = cookie.GetString( "bricks_server_" .. k, v[3] or "" )
        end
    end
end
BRICKS_SERVER.Func.LoadClientConfig()

function BRICKS_SERVER.Func.ChangeClientConfig( key, value )
    if( BRICKS_SERVER.BASECLIENTCONFIG[key] ) then
        BRICKS_SERVER.CLIENTCONFIG = BRICKS_SERVER.CLIENTCONFIG or {}

        if( BRICKS_SERVER.BASECLIENTCONFIG[key][2] and BRICKS_SERVER.BASECLIENTCONFIG[key][2] == "bool" ) then
            BRICKS_SERVER.CLIENTCONFIG[key] = value and 1 or 0
            cookie.Set( "bricks_server_" .. key, (value and 1 or 0) )
        else
            BRICKS_SERVER.CLIENTCONFIG[key] = value
            cookie.Set( "bricks_server_" .. key, value )
        end

        if( BRICKS_SERVER.BASECLIENTCONFIG[key][4] and isfunction( BRICKS_SERVER.BASECLIENTCONFIG[key][4] ) ) then
            BRICKS_SERVER.BASECLIENTCONFIG[key][4]( value )
        end
    end
end

function BRICKS_SERVER.Func.GetClientConfig( key )
    if( not BRICKS_SERVER.BASECLIENTCONFIG[key] ) then return end

    local type = BRICKS_SERVER.BASECLIENTCONFIG[key][2] or ""

    if( type == "number" ) then
        return BRICKS_SERVER.CLIENTCONFIG[key] or ((BRICKS_SERVER.BASECLIENTCONFIG[key] or {})[3] or 0)
    elseif( type == "string" ) then
        return BRICKS_SERVER.CLIENTCONFIG[key] or ((BRICKS_SERVER.BASECLIENTCONFIG[key] or {})[3] or "")
    elseif( type == "bind" ) then
        return BRICKS_SERVER.CLIENTCONFIG[key] or ((BRICKS_SERVER.BASECLIENTCONFIG[key] or {})[3] or 0)
    elseif( type == "bool" ) then
        return tobool( BRICKS_SERVER.CLIENTCONFIG[key] )
    end
end

function BRICKS_SERVER.Func.GetClientBind( key )
    if( not BRICKS_SERVER.BASECLIENTCONFIG[key] ) then return BRICKS_SERVER.Func.L( "unbound" ), 0 end

    local bindNum = BRICKS_SERVER.Func.GetClientConfig( key ) or BRICKS_SERVER.BASECLIENTCONFIG[key][3]
    if( BRICKS_SERVER.DEVCONFIG.KEY_BINDS[bindNum] ) then
        return BRICKS_SERVER.DEVCONFIG.KEY_BINDS[bindNum], bindNum
    else
        return BRICKS_SERVER.Func.L( "unbound" ), bindNum
    end
end

function BRICKS_SERVER.Func.SetClientCookie( key, type, value )
    if( type == "bool" ) then
        cookie.Set( "bricks_server_cc_" .. key, value and 1 or 0 )
    else
        cookie.Set( "bricks_server_cc_" .. key, value )
    end
end

function BRICKS_SERVER.Func.GetClientCookie( key, type )
    if( type == "number" ) then
        return cookie.GetNumber( "bricks_server_cc_" .. key, 0 )
    elseif( type == "bool" ) then
        return tobool( cookie.GetNumber( "bricks_server_cc_" .. key, 0 ) )
    else
        return cookie.GetString( "bricks_server_cc_" .. key, "" )
    end
end

BRICKS_SERVER.ConfigPages = BRICKS_SERVER.ConfigPages or {}
function BRICKS_SERVER.Func.AddConfigPage( name, vguiElement, addon, shouldCreate )
    for k, v in pairs( BRICKS_SERVER.ConfigPages ) do
        if( v[2] == vguiElement ) then return end
    end

    table.insert( BRICKS_SERVER.ConfigPages, { name, vguiElement, addon, shouldCreate } )
end

BRICKS_SERVER.Func.AddConfigPage( BRICKS_SERVER.Func.L( "themes" ), "bricks_server_config_themes" )
BRICKS_SERVER.Func.AddConfigPage( BRICKS_SERVER.Func.L( "groups" ), "bricks_server_config_groups" )
BRICKS_SERVER.Func.AddConfigPage( BRICKS_SERVER.Func.L( "general" ), "bricks_server_config_general" )
BRICKS_SERVER.Func.AddConfigPage( BRICKS_SERVER.Func.L( "itemWhitelisting" ), "bricks_server_config_itemwhitelist" )
BRICKS_SERVER.Func.AddConfigPage( BRICKS_SERVER.Func.L( "rarities" ), "bricks_server_config_rarities" )
BRICKS_SERVER.Func.AddConfigPage( BRICKS_SERVER.Func.L( "itemRarities" ), "bricks_server_config_itemrarities" )
BRICKS_SERVER.Func.AddConfigPage( BRICKS_SERVER.Func.L( "languages" ), "bricks_server_config_languages" )
BRICKS_SERVER.Func.AddConfigPage( "NPCS", "bricks_server_config_npcs" )

function BRICKS_SERVER.Func.FillVariableConfigs( parent, configKey, configChanged, specialConfigs )
    if( not BRICKS_SERVER.BASECONFIG[configKey] or not parent or not IsValid( parent ) ) then return end

    local spacing = 5
    local gridWide = (ScrW()*0.6)-BRICKS_SERVER.DEVCONFIG.MainNavWidth-20
    local slotsWide = (ScrW() >= 1080 and 2) or 1
    local slotWide = (gridWide-((slotsWide-1)*spacing))/slotsWide
    local slotTall = 80

    if( not parent.grid or not IsValid( parent.grid ) ) then
        parent.grid = vgui.Create( "DIconLayout", parent )
        parent.grid:Dock( TOP )
        parent.grid:DockMargin( 0, 0, 0, 5 )
        parent.grid:SetTall( slotTall )
        parent.grid:SetSpaceY( spacing )
        parent.grid:SetSpaceX( spacing )
    end

    if( not parent.grid or not IsValid( parent.grid ) ) then return end

    local configs, specialConfigs = {}, specialConfigs or {}

    for k, v in pairs( BRICKS_SERVER.BASECONFIG[configKey] ) do
        if( isnumber( v ) or isstring( v ) or isbool( v ) ) then
            configs[k] = v
        end
    end

    if( specialConfigs ) then
        for k, v in pairs( specialConfigs ) do
            configs[k] = v
        end
    end

    for k, v in pairs( configs ) do
        parent.slots = (parent.slots or 0)+1
        local slots = parent.slots
        local slotsTall = math.ceil( slots/slotsWide )
        parent.grid:SetTall( (slotsTall*slotTall)+((slotsTall-1)*spacing) )

        local header = k
        if( istable( v ) and v[3] ) then
            header = v[3]
        end

        local description
        if( istable( v ) and v[2] ) then
            description = v[2]
        end

        local variableBack = parent.grid:Add( "DPanel" )
        variableBack:SetSize( slotWide, slotTall )
        variableBack.Paint = function( self2, w, h )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

            draw.SimpleText( header, "BRICKS_SERVER_Font20", 10, 5, BRICKS_SERVER.Func.GetTheme( 5 ), 0, 0 )

            if( description ) then
                surface.SetFont( "BRICKS_SERVER_Font20" )
                local headerX, headerY = surface.GetTextSize( header )

                draw.SimpleText( description, "BRICKS_SERVER_Font20", 10+headerX+5, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
            end
        end

        if( not specialConfigs[k] and (isstring( v ) or isnumber( v )) ) then
            local valueEntryBack = vgui.Create( "DPanel", variableBack )
            valueEntryBack:Dock( BOTTOM )
            valueEntryBack:DockMargin( 10, 10, 10, 10 )
            valueEntryBack:SetTall( 40 )
            local Alpha = 0
            local valueEntry
            local color1 = BRICKS_SERVER.Func.GetTheme( 1 )
            valueEntryBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
        
                if( valueEntry:IsEditing() ) then
                    Alpha = math.Clamp( Alpha+5, 0, 100 )
                else
                    Alpha = math.Clamp( Alpha-5, 0, 100 )
                end
                
                draw.RoundedBox( 5, 0, 0, w, h, Color( color1.r, color1.g, color1.b, Alpha ) )
            end

            if( isnumber( v ) ) then
                valueEntry = vgui.Create( "bricks_server_numberwang", valueEntryBack )
                valueEntry:Dock( FILL )
                valueEntry:SetMinMax( 0, 9999999999999 )
                valueEntry:SetValue( ((BS_ConfigCopyTable or BRICKS_SERVER.CONFIG)[configKey] or {})[k] or 0 )
                valueEntry.OnValueChanged = function( self2, value )
                    BS_ConfigCopyTable[configKey][k] = tonumber( valueEntry:GetValue() )
                    BRICKS_SERVER.Func.ConfigChange( configChanged )
                end
            else
                valueEntry = vgui.Create( "bricks_server_textentry", valueEntryBack )
                valueEntry:Dock( FILL )
                valueEntry:SetValue( ((BS_ConfigCopyTable or BRICKS_SERVER.CONFIG)[configKey] or {})[k] or "" )
                valueEntry.OnChange = function( self2, value )
                    BS_ConfigCopyTable[configKey][k] = valueEntry:GetValue()
                    BRICKS_SERVER.Func.ConfigChange( configChanged )
                end
            end
        elseif( specialConfigs[k] or isbool( v ) ) then
            local toggleButton = vgui.Create( "DButton", variableBack )
            toggleButton:Dock( BOTTOM )
            toggleButton:DockMargin( 10, 10, 10, 10 )
            toggleButton:SetTall( 40 )
            toggleButton:SetText( "" )
            local alpha = 0
            toggleButton.Paint = function( self2, w, h )
                local buttonText = BRICKS_SERVER.Func.L( "edit" )
                local buttonColor = BRICKS_SERVER.Func.GetTheme( 2 )
                local buttonDownColor = BRICKS_SERVER.Func.GetTheme( 1 )

                if( not specialConfigs[k] and isbool( v ) ) then
                    local enabled = BS_ConfigCopyTable[configKey][k]
                    buttonText = (enabled and BRICKS_SERVER.Func.L( "enabled" )) or BRICKS_SERVER.Func.L( "disabled" )
                    buttonColor = (enabled and BRICKS_SERVER.DEVCONFIG.BaseThemes.Green) or BRICKS_SERVER.DEVCONFIG.BaseThemes.Red
                    buttonDownColor = (enabled and BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen) or BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed
                end
    
                if( not self2:IsDown() and self2:IsHovered() ) then
                    alpha = math.Clamp( alpha+5, 0, 200 )
                else
                    alpha = math.Clamp( alpha-5, 0, 255 )
                end
    
                draw.RoundedBox( 5, 0, 0, w, h, buttonColor )
    
                surface.SetAlphaMultiplier( alpha/255 )
                draw.RoundedBox( 5, 0, 0, w, h, buttonDownColor )
                surface.SetAlphaMultiplier( 1 )
    
                BRICKS_SERVER.Func.DrawClickCircle( self2, w, h, buttonDownColor )
    
                draw.SimpleText( buttonText, "BRICKS_SERVER_Font20", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
            if( specialConfigs[k] and istable( v ) and v[1] ) then
                toggleButton.DoClick = v[1]
            else
                toggleButton.DoClick = function()
                    BS_ConfigCopyTable[configKey][k] = not BS_ConfigCopyTable[configKey][k]
                    BRICKS_SERVER.Func.ConfigChange( configChanged )
                end
            end
        end
    end
end

BRS_SERVER_OS_DIFF = 0

net.Receive( "BRS.Net.SendServerTime", function()
    local svrOSTime = net.ReadInt( 32 )
    local svrCurTime = net.ReadInt( 32 )

    BRS_SERVER_OS_DIFF = os.time()-svrOSTime+svrCurTime-CurTime()
end )

function BRICKS_SERVER.Func.GetServerTime()
    return os.time()-BRS_SERVER_OS_DIFF
end

net.Receive( "BRS.Net.OpenBrickServer", function()
    if( BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then
        BS_ConfigsChanged = {}
        BS_ConfigCopyTable = table.Copy( BRICKS_SERVER.CONFIG )
    end

	if( not IsValid( BRICKS_SERVER_MENU ) ) then
		BRICKS_SERVER_MENU = vgui.Create( "bricks_server_menu" )
		BRICKS_SERVER_MENU:FillTabs()
    elseif( not BRICKS_SERVER_MENU:IsVisible() ) then
        BRICKS_SERVER_MENU:SetVisible( true )
        if( BRICKS_SERVER_MENU.FillProfile ) then BRICKS_SERVER_MENU.FillProfile() end
        if( BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then
            hook.Run( "BRS.Hooks.RefreshConfig" )
            if( BRICKS_SERVER_MENU.FillPlayers ) then BRICKS_SERVER_MENU.FillPlayers() end
            if( BRICKS_SERVER_MENU.RefreshAdminPerms ) then BRICKS_SERVER_MENU.RefreshAdminPerms() end
        end
    end
end )

BRICKS_SERVER.AdminPlayerFunctions = {}
function BRICKS_SERVER.Func.AddAdminPlayerFunc( title, category, func )
    if( not BRICKS_SERVER.AdminPlayerFunctions ) then
        BRICKS_SERVER.AdminPlayerFunctions = {}
    end

    table.insert( BRICKS_SERVER.AdminPlayerFunctions, { title, category, func } )
end

BRICKS_SERVER.Func.AddAdminPlayerFunc( BRICKS_SERVER.Func.L( "profile" ), BRICKS_SERVER.Func.L( "view" ), function( ply ) 
    if( not IsValid( BS_ADMIN_PROFILE ) ) then
        BS_ADMIN_PROFILE = vgui.Create( "bricks_server_admin_profile" )
    end

    net.Start( "BRS.Net.ProfileAdminRequest" )
        net.WriteString( ply:SteamID64() or "" )
    net.SendToServer()
end )

concommand.Add( "brs_removeonclose", function( ply, cmd, args )
	BRS_REMOVEONCLOSE = not BRS_REMOVEONCLOSE
end )

hook.Add( "InitPostEntity", "BRS.InitPostEntity.NetworkReady", function()
	net.Start( "BRS.Net.SendNetworkReady" )
	net.SendToServer()
end )

net.Receive( "BRS.Net.SendTopNotification", function()
    local text = net.ReadString()
    local time = net.ReadUInt( 8 ) or 5
    local color = net.ReadColor() or BRICKS_SERVER.Func.GetTheme( 5 )

    BRICKS_SERVER.Func.CreateTopNotification( text, time, color )
end )

net.Receive( "BRS.Net.SendNotification", function()
    local text = net.ReadString()
    local type = net.ReadUInt( 8 ) or 1
    local time = net.ReadUInt( 8 ) or 3

    notification.AddLegacy( text, type, time )
end )

net.Receive( "BRS.Net.SendChatNotification", function()
    chat.AddText( net.ReadColor(), net.ReadString(), " ", net.ReadColor(), net.ReadString() )
end )

net.Receive( "BRS.Net.UseMenuNPC", function()
    local vguiElement = net.ReadString()
    local title = net.ReadString()

    if( not vguiElement ) then return end

    if( IsValid( BRICKS_SERVER.TEMP.NPCMenu ) ) then
        BRICKS_SERVER.TEMP.NPCMenu:Remove()
    end

    BRICKS_SERVER.TEMP.NPCMenu = vgui.Create( "bricks_server_dframe" )
	BRICKS_SERVER.TEMP.NPCMenu:SetHeader( title )
    BRICKS_SERVER.TEMP.NPCMenu:SetSize( ScrW()*0.6-BRICKS_SERVER.DEVCONFIG.MainNavWidth, ScrH()*0.65 )
    BRICKS_SERVER.TEMP.NPCMenu:Center()
    
    local vguiPanel = vgui.Create( vguiElement, BRICKS_SERVER.TEMP.NPCMenu )
    vguiPanel:Dock( FILL )
    if( vguiPanel.FillPanel ) then
        vguiPanel:FillPanel()
    end
end )

function BRICKS_SERVER.Func.SendAdminConfig()
    if( BS_ConfigsChanged and table.Count( BS_ConfigsChanged ) > 0 ) then
        local configToSend = {}
        for k, v in pairs( BS_ConfigsChanged ) do
            if( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG)[k] ) then
                configToSend[k] = (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG)[k]
            end
        end

        local configData = util.Compress( util.TableToJSON( configToSend ) )

        net.Start( "BRS.Net.UpdateConfig" )
            net.WriteData( configData, string.len( configData ) )
        net.SendToServer()
    end
end