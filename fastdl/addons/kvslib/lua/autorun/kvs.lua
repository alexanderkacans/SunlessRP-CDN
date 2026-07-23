KVS 				= { }
KVS.LOADER 			= { }

KVS.PATH 			= 'kvs'
KVS.CONFIG_PATH = 'kvs/shared/config'
KVS.DEVELOPER_MODE = false
KVS.FONTS_ALIASES = KVS.FONTS_ALIASES or { }

if not file.IsDir( KVS.PATH, 'DATA' ) then
	file.CreateDir( KVS.PATH, 'DATA' )
end

if SERVER then
	util.AddNetworkString( 'kvs.on.server.send.toast' )
end

function KVS:LoadFiles()
	--[[
		SHARED
	]]
	local files, folders = file.Find( "kvs/shared/*", "LUA" )
	for k, v in pairs( folders ) do 
		local filesList = file.Find( "kvs/shared/" .. v .. "/*.lua", "LUA" )
		
		for k, file in pairs( filesList ) do 

			if SERVER then
				AddCSLuaFile( "kvs/shared/" .. v .. "/" .. file )
			end

			include( "kvs/shared/" .. v .. "/" .. file )

			print( "Loaded file : ", "kvs/shared/" .. v .. "/" .. file)
		end
	end

	--[[
		CLIENT
	]]
	local files, folders = file.Find( "kvs/client/*", "LUA" )
	for k, v in pairs( folders ) do 
		local filesList = file.Find( "kvs/client/" .. v .. "/*.lua", "LUA" )
		
		for k, file in pairs( filesList ) do 
			if CLIENT then
				include( "kvs/client/" .. v .. "/" .. file )
			elseif SERVER then
				AddCSLuaFile( "kvs/client/" .. v .. "/" .. file )
			end

			print( "Loaded file : ", "kvs/client/" .. v .. "/" .. file)
		end
	end

	--[[
		SERVER
	]]
	local files, folders = file.Find( "kvs/server/*", "LUA" )
	for k, v in pairs( folders ) do 
		local filesList = file.Find( "kvs/server/" .. v .. "/*.lua", "LUA" )
		
		for k, file in pairs( filesList ) do 
			include( "kvs/server/" .. v .. "/" .. file )

			print( "Loaded file : ", "kvs/server/" .. v .. "/" .. file)
		end
	end

	hook.Run( 'KVS.OnKVSLoaded' )
end

function KVS.LOADER:Init()
	KVS:LoadFiles()

	KVS:LoadConfigs()

	KVS.LOADER:InitCore()
end

function KVS.LOADER:InitCore()

	KVS.INFO = 1
	KVS.WARNING = 2
	KVS.DANGER = 3
	KVS.SUCCESS = 4

	if ( CLIENT ) then
		local font = KVS.GetFont
		local config = KVS.GetConfig

		KVS:RegisterFontAlias( 'Vegur', 'Vegur' )
		KVS:RegisterFontAlias( 'Vegur Light', 'Vegur Light' )
		KVS:RegisterFontAlias( 'Vegur Bold', 'Vegur Bold' )
		KVS:RegisterFontAlias( 'FAS', 'Font Awesome 5 Free Solid' )
		KVS:RegisterFontAlias( 'FAB', 'Font Awesome 5 Brands Regular' )
		KVS:RegisterFontAlias( 'FAR', 'Font Awesome 5 Free Regular' )
		hook.Run('KVS.PostRegisterFontAliases')

		KVS:RegisterToastSeverity( KVS.INFO, config( 'vgui.color.info' ), { font = font( 'FAS', 31, 'extended' ), unicode = 0xf05a } )
		KVS:RegisterToastSeverity( KVS.WARNING, config( 'vgui.color.warning' ), { font = font( 'FAS', 31, 'extended' ), unicode = 0xf06a } )
		KVS:RegisterToastSeverity( KVS.DANGER, config( 'vgui.color.danger' ), { font = font( 'FAS', 31, 'extended' ), unicode = 0xf057 } )
		KVS:RegisterToastSeverity( KVS.SUCCESS, config( 'vgui.color.accept_green' ), { font = font( 'FAS', 31, 'extended' ), unicode = 0xf00c } )
		hook.Run( 'KVS.PostRegisterToastSeverity' )
	end
end

KVS.LOADER:Init()
