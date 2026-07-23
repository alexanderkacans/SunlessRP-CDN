if( not sql.TableExists( "bricks_server_currencies" ) ) then
	sql.Query( [[ CREATE TABLE bricks_server_currencies ( 
		steamID64 varchar(20) NOT NULL, 
		currencyKey int,
        amount int
	); ]] )
end

print( "[BricksServer SQLLite] bricks_server_currencies table validated!" )

function BRICKS_SERVER.Func.InsertCurrencyEntryDB( steamID64, currencyKey, amount )
    local query = sql.Query( string.format( "INSERT INTO bricks_server_currencies( steamID64, currencyKey, amount ) VALUES('%s', %d, %d);", steamID64, currencyKey, amount ) )
	
	if( query == false ) then
		print( "[BricksServer SQLLite] ERROR", sql.LastError() )
	end
end

function BRICKS_SERVER.Func.UpdateCurrencyEntryDB( steamID64, currencyKey, amount )
	local query = sql.Query( "UPDATE bricks_server_currencies SET amount = " .. amount .. " WHERE steamID64 = '" .. steamID64 .. "' AND currencyKey = " .. currencyKey .. ";" )
	
	if( query == false ) then
		print( "[BricksServer SQLLite] ERROR", sql.LastError() )
	end
end

function BRICKS_SERVER.Func.FetchCurrencyEntryDB( steamID64, func )
	local query = sql.Query( "SELECT * FROM bricks_server_currencies WHERE steamID64 = '" .. steamID64 .. "';" )

	if( query == false ) then
		print( "[BricksServer SQLLite] ERROR", sql.LastError() )
	else
		func( query or {} )
	end
end