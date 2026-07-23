function BRICKS_SERVER.Func.SaveConfig( keysChanged )
	local Config = BRICKS_SERVER.CONFIG
	if( Config != nil ) then
		if( not istable( Config ) ) then
			BRICKS_SERVER.Func.LoadConfig()
			return
		end
	else
		BRICKS_SERVER.Func.LoadConfig()
		return
	end
	
	if( not file.Exists( "bricks_server/config", "DATA" ) ) then
		file.CreateDir( "bricks_server/config" )
	end

	for k, v in pairs( keysChanged or table.GetKeys( BRICKS_SERVER.CONFIG ) ) do
		local writeValue = util.TableToJSON( BRICKS_SERVER.CONFIG[v] or {} )
		file.Write( "bricks_server/config/" .. v .. ".txt", writeValue )
	end
end

util.AddNetworkString( "BRS.Net.SendConfig" )
function BRICKS_SERVER.Func.SendConfig( ply, configKeys )
	local compressedConfig = util.Compress( util.TableToJSON( BRICKS_SERVER.CONFIG ) )
	local split = 60000
	local len = string.len( compressedConfig )
	local parts = math.ceil( len/split )
	local partsTable = {}

	for i = 1, parts do
		local min
		local max
		if i == 1 then
			min = i
			max = split
		elseif i > 1 and i ~= parts then
			min = ( i - 1 ) * split + 1
			max = min + split - 1
		elseif i > 1 and i == parts then
			min = ( i - 1 ) * split + 1
			max = len
		end

		partsTable[i] = string.sub( compressedConfig, min, max )
	end

	local uniqueStr, currentKey = "BRS_CONFIG_SEND_" .. tostring( ply ), 1
	local function sendConfig()
		if( not partsTable[currentKey] ) then return end
		
		local dataLen = string.len( partsTable[currentKey] )
		net.Start( "BRS.Net.SendConfig" )
			net.WriteString( uniqueStr )
			net.WriteUInt( currentKey, 5 )
			net.WriteUInt( #partsTable, 5 )
			net.WriteUInt( dataLen, 16 )
			net.WriteData( partsTable[currentKey], dataLen )
		net.Send( ply )

		currentKey = currentKey+1
	end
	sendConfig()

	if( #partsTable > 1 ) then
		timer.Create( uniqueStr, 0.1, #partsTable, sendConfig )
	end
end

hook.Add( "PlayerInitialSpawn", "BRS.PlayerInitialSpawn.ConfigSend", function( ply )
	if( IsValid( ply ) ) then
		BRICKS_SERVER.Func.SendConfig( ply )
	end
end )

util.AddNetworkString( "BRS.Net.RequestConfig" )
net.Receive( "BRS.Net.RequestConfig", function( len, ply )
	if( (ply.requestConfigCooldown or 0) > CurTime() ) then return end
	
	ply.requestConfigCooldown = CurTime()+5
	
	BRICKS_SERVER.Func.SendConfig( ply )
end )

function BRICKS_SERVER.Func.UpdateConfig( newConfig, ply )
	if( istable( newConfig ) ) then 
		for k, v in pairs( newConfig ) do
			BRICKS_SERVER.CONFIG[k] = v
		end

		local configKeys = table.GetKeys( newConfig )

		BRICKS_SERVER.Func.SendConfig( player.GetAll(), configKeys )

		BRICKS_SERVER.Func.SaveConfig( configKeys )

		BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "configSaved" ) )

		hook.Run( "BRS.Hooks.ConfigUpdated", configKeys )
	end
end

util.AddNetworkString( "BRS.Net.UpdateConfig" )
net.Receive( "BRS.Net.UpdateConfig", function( len, ply )
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	local compressedConfig = net.ReadData( len )

	if( not compressedConfig ) then return end

	local unCompressedConfig = util.Decompress( compressedConfig )

	if( not unCompressedConfig ) then return end

	local newConfigTable = util.JSONToTable( unCompressedConfig )

	if( not newConfigTable ) then return end

	BRICKS_SERVER.Func.UpdateConfig( newConfigTable, ply )
end )

util.AddNetworkString( "BRS.Net.ProfileAdminRequest" )
util.AddNetworkString( "BRS.Net.ProfileAdminSend" )
net.Receive( "BRS.Net.ProfileAdminRequest", function( len, ply )
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	local requestedID64 = net.ReadString()

	if( not requestedID64 ) then return end
	local requestedPly = player.GetBySteamID64( requestedID64 )

	if( IsValid( requestedPly ) ) then
		local profileTable = {}

		hook.Run( "BRS.Hooks.ProfileSend", profileTable, requestedPly )

		net.Start( "BRS.Net.ProfileAdminSend" )
			net.WriteString( requestedID64 )
			net.WriteTable( profileTable )
		net.Send( ply )
	else
		BRICKS_SERVER.Func.SendNotification( ply, 1, 5, BRICKS_SERVER.Func.L( "invalidPlayerProfile" ) )
	end
end )