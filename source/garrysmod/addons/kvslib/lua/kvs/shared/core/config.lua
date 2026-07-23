-- Function used to load all configs files
function KVS:LoadConfigs( )
	KVS.CONFIG = { }
	KVS.MISSING_CONFIG = { }
	local files = file.Find( string.format( '%s/*.lua', KVS.CONFIG_PATH ),  'LUA' )
	for _, config in pairs( files ) do
		local filename = string.Split( config, '.lua' )[1]
		AddCSLuaFile( string.format( '%s/%s.lua', KVS.CONFIG_PATH, filename ) )
		KVS.CONFIG[ filename ] = include( string.format( '%s/%s.lua', KVS.CONFIG_PATH, filename ) )
	end
end

-- Function used to get a config using dotted notation
function KVS.GetConfig( key, nil_return )
	if ( not isstring( key ) ) then return 'key.must.be.a.string' end
	local keys = string.Split( key, '.' )

	local value = KVS.CONFIG
	if not value then
		KVS:LoadConfigs()
	end
	local match = true

	for _, v in pairs( keys ) do
		if ( value[ v ] ) then
			value = value[ v ]
		else
			match = false
		end
	end

	if ( match and ( IsColor( value ) or not istable( value ) or ( istable( value ) and table.Count(value) > 0 ) ) ) then -- TODO review all type possible from config
		return value
	elseif ( nil_return ) then
		return nil
	else
		if ( not KVS.MISSING_CONFIG[ key ] ) then table.insert( KVS.MISSING_CONFIG, key ) end
		return key
	end
end
