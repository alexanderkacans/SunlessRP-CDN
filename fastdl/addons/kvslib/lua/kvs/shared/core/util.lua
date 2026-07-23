function KVS:OverrideMeta( meta, functionName, func )
    local name = 'Base' .. functionName
    meta[ name ] = meta[ functionName ]

    meta[ functionName ] = function( ... )
        local args = { ... }
        table.remove( args, 1 ) -- Remove the panel object from the args
        local values = { func( unpack( args ) ) } -- Call the new function witht the passed parameters
        if ( values[ 1 ] == true ) then return end
        table.remove( values, 1 ) -- Remove the value which prevent the base function
        meta[ name ]( meta, unpack( #values > 0 && values or args ) ) -- Call the base function with the returned value OR with the default ones
    end

    return meta[ name ], meta[ functionName ]
end