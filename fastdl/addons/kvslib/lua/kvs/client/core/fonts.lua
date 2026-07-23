local allowed_extras_args = { [ 'extended' ] = true, [ 'antialias' ] = true, [ 'underline' ] = true, [ 'italic' ] = true, [ 'strikeout' ] = true, [ 'symbol' ] = true, [ 'rotary' ] = true, [ 'shadow' ] = true, [ 'additive' ] = true, [ 'outline' ] = true }
local allowed_integer_extras_args = { [ 'weight' ] = true, [ 'blursize' ] = true, [ 'scanlines' ] = true }

-- Function used to register a font alias
function KVS:RegisterFontAlias( alias, name )
	if ( not KVS.FONTS_ALIASES[ alias ] ) then
		KVS.FONTS_ALIASES[ alias ] = name
	end
end

-- Function used to recover a font by passing his alias, his size and any other parameters
function KVS.GetFont( alias, size, ... )
	KVS.FONTS = KVS.FONTS or { }
	if ( not KVS.FONTS_ALIASES[ alias ] ) then
		print( 'The following alias isn\'t registered, registering automatically as : ' .. alias )
		KVS.FONTS_ALIASES[ alias ] = alias
	end

	local table_concat = { alias, size }
	local extras = { }
	if ( #{ ... } > 0 ) then
		for _, v in pairs( { ... } ) do
			local exploded = { }
			local matching_char = string.match( v, '[-:]' )
			if ( matching_char ) then
				exploded = string.Explode( matching_char, v )
			end

			if ( allowed_extras_args[ v ] or ( matching_char and #exploded > 1 and ( allowed_extras_args[ exploded[ 2 ] ] or ( allowed_integer_extras_args[ exploded[ 1 ] ] and isnumber( tonumber( exploded[ 2 ] ) ) ) ) ) ) then
				if allowed_extras_args[ v ] then
					extras[ v ] = true
				end

				if ( allowed_extras_args[ exploded[ 2 ] ] ) then
					extras[ exploded[ 2 ] ] = exploded[ 1 ] == 'no' and false
				end

				if ( allowed_integer_extras_args[ exploded[ 1 ] ] ) then
					extras[ exploded[ 1 ] ] = tonumber( exploded[ 2 ])
				end

				table.insert( table_concat, v )
			end
		end
	end

	local font_name = table.concat( table_concat, '_' )
	if ( not KVS.FONTS[ font_name ] ) then
		surface.CreateFont( font_name, {
			font = 		KVS.FONTS_ALIASES[ alias ],
			size = 		size,
			extended = 	extras[ 'extended' ] or false,
			weight = 	extras[ 'weight' ] or 500,
			blursize = 	extras[ 'blursize' ] or 0,
			scanlines = extras[ 'scanlines' ] or 0,
			antialias = extras[ 'antialias' ] or true,
			underline = extras[ 'underline' ] or false,
			italic = 	extras[ 'italic' ] or false,
			strikeout = extras[ 'strikeout' ] or false,
			symbol = 	extras[ 'symbol' ] or false,
			rotary = 	extras[ 'rotary' ] or false,
			shadow = 	extras[ 'shadow' ] or false,
			additive = 	extras[ 'additive' ] or false,
			outline = 	extras[ 'outline' ] or false,
		})
		KVS.FONTS[ font_name ] = true
	end

	return font_name
end
