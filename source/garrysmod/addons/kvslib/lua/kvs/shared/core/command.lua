concommand.Add( 'KVS.GetUndefinedConfigs', function( )
	if ( not KVS or not KVS.MISSING_CONFIG ) then return end
	PrintTable( KVS.MISSING_CONFIG )
end )
