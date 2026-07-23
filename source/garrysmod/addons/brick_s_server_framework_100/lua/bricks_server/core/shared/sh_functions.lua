AddCSLuaFile( "sh_cami.lua" )
include( "sh_cami.lua" )

function BRICKS_SERVER.Func.GetAdminGroup( ply )
	if( serverguard ) then
		return serverguard.player:GetRank( ply )
	else
		return ply:GetNWString( "usergroup", "" )
	end

	return ""
end

function BRICKS_SERVER.Func.HasAdminAccess( ply )
	if( not IsValid( ply ) ) then return false end

	if( ply:IsSuperAdmin() ) then return true end
	
	if( BRICKS_SERVER.CONFIG.GENERAL.AdminPermissions ) then
		if( xAdmin ) then
			for k, v in pairs( BRICKS_SERVER.CONFIG.GENERAL.AdminPermissions ) do
				if( ply:IsUserGroup( k ) ) then
					return true
				end
			end
		else
			return tobool( BRICKS_SERVER.CONFIG.GENERAL.AdminPermissions[BRICKS_SERVER.Func.GetAdminGroup( ply )] )
		end
	end

	return false
end

function BRICKS_SERVER.Func.GetAdminSystemRanks()
	local ranks = {}
	for k, v in pairs( CAMI:GetUsergroups() ) do
		ranks[k] = v.Name
	end

	return ranks
end

function BRICKS_SERVER.Func.IsInGroup( ply, group )
	local groupTable = {}
	for k, v in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
		if( group == v[1] ) then
			groupTable = v
			break
		end
	end

	if( groupTable ) then
		if( (groupTable[2] or {})[BRICKS_SERVER.Func.GetAdminGroup( ply )] ) then
			return true
		end

		if( xAdmin ) then
			for k, v in pairs( (groupTable[2] or {}) ) do
				if( ply:IsUserGroup( k ) ) then
					return true
				end
			end
		end

		if( sam and ply.GetSecondaryUserGroup and groupTable[ply:GetSecondaryUserGroup()] ) then
			return true
		end
	else
		return true
	end

	return false
end

function BRICKS_SERVER.Func.GetGroup( ply )
	for k, v in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
		if( BRICKS_SERVER.Func.IsInGroup( ply, v[1] ) ) then return v, k end
	end

	for k, v in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
		if( v[4] ) then return v, k end
	end

	return false
end

function BRICKS_SERVER.Func.FormatTime( time, miliSeconds, dontShowHours )
	local timeTable = string.FormattedTime( time )

	if( time >= 86400 ) then
		return math.floor( time/86400 ) .. " days, " .. string.format( "%02i:%02i:%02i", timeTable.h-(math.floor( time/86400 )*24), timeTable.m, timeTable.s )
	else
		if( not miliSeconds ) then
			return dontShowHours and string.format( "%02i:%02i", timeTable.m, timeTable.s ) or string.format( "%02i:%02i:%02i", timeTable.h, timeTable.m, timeTable.s )
		else
			return string.format( "%02i:%02i:%02i", timeTable.h, timeTable.m, timeTable.s, timeTable.ms )
		end
	end
end

function BRICKS_SERVER.Func.FormatWordTime( time )
	local timeText = (time != 1 and BRICKS_SERVER.Func.L( "seconds", time )) or BRICKS_SERVER.Func.L( "second", time )

	if( time >= 60 ) then
		if( time < 3600 ) then
			local minutes = math.floor( time/60 )
			timeText = (minutes != 1 and BRICKS_SERVER.Func.L( "minutes", minutes )) or BRICKS_SERVER.Func.L( "minute", minutes )
		else
			if( time < 86400 ) then
				local hours = math.floor( time/3600 )
				timeText = (hours != 1 and BRICKS_SERVER.Func.L( "hours", hours )) or BRICKS_SERVER.Func.L( "hour", hours )
			else
				local days = math.floor( time/86400 )
				timeText = (days != 1 and BRICKS_SERVER.Func.L( "days", days )) or BRICKS_SERVER.Func.L( "day", days )
			end
		end
	end

	return timeText
end

function BRICKS_SERVER.Func.FormatTimeInPlace( time )
	local currentDate = os.date( "*t" )
	local dateTable = os.date( "*t", time )
	
	if( dateTable.day == currentDate.day ) then
		return os.date( "%H:%M", time )
	else
		return os.date( "%d/%m/%Y", time )
	end
end

function BRICKS_SERVER.Func.GetList( listReq )
	if( listReq == "boosters" ) then
		local boosters = {}
		for k, v in pairs( BS_ConfigCopyTable.BOOSTERS ) do
			boosters[k] = v.Title
		end

		return boosters
	elseif( listReq == "vehicles" ) then
		local vehicles = {}
		for k, v in pairs( list.Get( "Vehicles" ) ) do
			vehicles[k] = v.Name or BRICKS_SERVER.Func.L( "error" )
		end

		return vehicles
	elseif( listReq == "weapons" ) then
		local weapons = {}
		for k, v in pairs( list.Get( "Weapon" ) ) do
			weapons[k] = ((v.PrintName or "") != "" and v.PrintName) or k
		end

		return weapons
	elseif( listReq == "entities" ) then
		local entities = {}
		for k, v in pairs( list.Get( "SpawnableEntities" ) ) do
			entities[k] = ((v.PrintName or "") != "" and v.PrintName) or k
		end

		return entities
	elseif( listReq == "resources" ) then
		local resources = {}
		for k, v in pairs( BS_ConfigCopyTable.CRAFTING.Resources ) do
			resources[k] = k
		end

		return resources
	elseif( listReq == "currencies" ) then
		local currencies = {}
		for k, v in pairs( BRICKS_SERVER.DEVCONFIG.Currencies ) do
			currencies[k] = v.Title
		end

		return currencies
	elseif( listReq == "ammo" ) then
		local ammo = {}

		local currentID = 1
		while true do
			local ammoType = game.GetAmmoData( currentID )

			if( ammoType and istable( ammoType ) ) then
				ammo[ammoType.name] = ammoType.name
				currentID = currentID+1
			else
				break
			end
		end

		return ammo
	elseif( listReq == "easySkins" ) then
		local skins = {}
		for k, v in pairs( SH_EASYSKINS.GetSkins() ) do
			skins[v.id] = v.dispName
		end

		return skins
	else
		return {}
	end
end

function BRICKS_SERVER.Func.GetWeaponName( weaponClass )
	if( weapons.GetStored( weaponClass ) and weapons.GetStored( weaponClass ).PrintName ) then
		return weapons.GetStored( weaponClass ).PrintName
	end
end

function BRICKS_SERVER.Func.GetWeaponModel( weaponClass )
	if( weapons.GetStored( weaponClass ) and weapons.GetStored( weaponClass ).WorldModel ) then
		return weapons.GetStored( weaponClass ).WorldModel
	elseif( BRICKS_SERVER.DEVCONFIG.WeaponModels[weaponClass] ) then
		return BRICKS_SERVER.DEVCONFIG.WeaponModels[weaponClass]
	end
end

function BRICKS_SERVER.Func.GetRarityInfo( rarityName )
	for k, v in pairs( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).GENERAL.Rarities or {} ) do
		if( (v[1] or "") == rarityName ) then
			return v, k
		end
	end

	return (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).GENERAL.Rarities[1], 1
end

function BRICKS_SERVER.Func.GetRarityColor( rarityInfo )
	if( not rarityInfo or not rarityInfo[2] ) then return BRICKS_SERVER.Func.GetTheme( 5 ) end

	local rarityType = rarityInfo[2]
	if( rarityType == "SolidColor" ) then
		return rarityInfo[3]
	elseif( rarityType == "Gradient" ) then
		return rarityInfo[3][1]
	elseif( rarityType == "Fade" ) then
		return rarityInfo[3][1]
	elseif( rarityType == "Rainbow" ) then
		return HSVToColor( CurTime()*360, 1, 1 )
	end
end

function BRICKS_SERVER.Func.GetRarityItems()
	local possibleItems = {}
	for k, v in pairs( list.Get( "Weapon" ) ) do
		local weaponModel = BRICKS_SERVER.Func.GetWeaponModel( k )
		if( weaponModel ) then
			possibleItems[k] = { (v.PrintName or BRICKS_SERVER.Func.L( "nil" )), weaponModel }
		else
			possibleItems[k] = { (v.PrintName or BRICKS_SERVER.Func.L( "nil" )) }
		end
	end

	if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "crafting" ) ) then
		for k, v in pairs( BRICKS_SERVER.CONFIG.CRAFTING.Resources ) do
			possibleItems[k] = { k, v[1], v[2] }
		end
	end

	for k, v in pairs( BRICKS_SERVER.CONFIG.INVENTORY.Whitelist or {} ) do
		if( k == "spawned_weapon" or k == "spawned_shipment" or string.StartWith( k, "bricks_server_resource" ) ) then continue end

		if( list.Get( "SpawnableEntities" )[k] ) then
			possibleItems[k] = { list.Get( "SpawnableEntities" )[k].PrintName or k }
		else
			possibleItems[k] = { k }
		end
	end

	return possibleItems
end

function BRICKS_SERVER.Func.GetInvTypeCFG( class )
	if( BRICKS_SERVER.DEVCONFIG.INVENTORY.EntTypes[class] ) then
		return BRICKS_SERVER.DEVCONFIG.INVENTORY.EntTypes[class]
	else
		for k, v in pairs( BRICKS_SERVER.DEVCONFIG.INVENTORY.EntTypes ) do
			if( string.EndsWith( k, "*" ) ) then
				local starter = string.Replace( k, "*", "" )
				if( string.StartWith( class, starter ) ) then
					return BRICKS_SERVER.DEVCONFIG.INVENTORY.EntTypes[k]
				end
			end
		end
		return BRICKS_SERVER.DEVCONFIG.INVENTORY.DefaultEntFuncs
	end
end

function BRICKS_SERVER.Func.GetEntTypeField( class, field )
	local entTypeCfg = BRICKS_SERVER.Func.GetInvTypeCFG( class )

	if( entTypeCfg[field] ) then
		return entTypeCfg[field]
	else
		return BRICKS_SERVER.DEVCONFIG.INVENTORY.DefaultEntFuncs[field] or false
	end
end

function BRICKS_SERVER.Func.GetTranslatedString( lang, string, func )
    lang  = lang  or "en"
    string = string or ""

    if lang == "en" or string == "" then
        func( string )
	end
	
	local urlFetch = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=" .. lang .. "&dt=t&q=" .. string.Replace( string, " ", "-" )

    http.Fetch( urlFetch, function( bodyString, bodyLen, headers, successCode )
		local jsonTable = util.JSONToTable( bodyString )

		if( jsonTable and jsonTable[1] and jsonTable[1][1] and jsonTable[1][1][1] ) then
			func( jsonTable[1][1][1] )
		else
			func( false, "INVALID TABLE" )
		end
	end, function( errorMsg )
		func( false, errorMsg )
	end )
end

function BRICKS_SERVER.Func.UTCTime()
	return os.time()
end