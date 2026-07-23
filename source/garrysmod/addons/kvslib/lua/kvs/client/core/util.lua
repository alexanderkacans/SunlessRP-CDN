local config = KVS.GetConfig
local font = KVS.GetFont
-- function to draw a name above the head of a NPC
function KVS:SetNPCName( eEntity, sName, unicode )
	if not IsValid( eEntity ) then return end 
	sName = sName or "No name"

	local iIndex = eEntity:EntIndex()
	local sFont = font( "Rajdhani Bold", 40 )
	local sFas = font( "FAS", 25, "extended" ) 
	local char
	local iLogoWidth, iLogoHeight
	hook.Add( "PostDrawTranslucentRenderables", "PostDrawTranslucentRenderables.KVS.NPCName" .. iIndex, function()
		if not IsValid( eEntity ) then 
			hook.Remove( "PostDrawTranslucentRenderables", "PostDrawTranslucentRenderables.KVS.NPCName" .. iIndex )
			return
		end
		
		local iTall = ( eEntity:OBBMaxs()[ 3 ] or 75 ) + 5
		local aAngle = eEntity:LocalToWorldAngles( Angle( 0, 90, 90 ) )
		local vPos = eEntity:LocalToWorld( Vector( 0, 0, iTall ) )

		cam.Start3D2D( vPos, aAngle, 0.1 )
			surface.SetFont( sFont )
			local iTextWidth, iTextHeight = surface.GetTextSize( sName )

			local iBoxWidth, iBoxHeight = iTextWidth + 40, iTextHeight + 20

			if unicode then 
				char = utf8.char( unicode )
				surface.SetFont( sFas )
				iLogoWidth, iLogoHeight = surface.GetTextSize( char )
				iBoxWidth = iBoxWidth + iLogoWidth
			end

			draw.RoundedBox( 4, -iBoxWidth / 2, -iBoxHeight / 2, iBoxWidth, iBoxHeight, config( 'vgui.color.black' ) )
			draw.RoundedBoxEx( 4, -iBoxWidth / 2, iBoxHeight / 2 - 5, iBoxWidth, 5, config( 'vgui.color.primary' ), false, false, true, true )
			draw.SimpleText( sName, sFont, unicode and iLogoWidth / 2 + 5 or 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			if unicode then
				draw.SimpleText( char, sFas, -( iTextWidth ) / 2 - 5, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
		cam.End3D2D()
	end )
end

-- Function used to get the pixel size of a text with a specific font
function KVS:GetSizeFromFont( font, text )
	surface.SetFont( font )
	return surface.GetTextSize( text )
end

-- Function used to get a darken color than the color passed in parameters and relative to a fraction
function KVS:GetDarkenColor( color, fraction )
	return Color( math.min( color.r - color.r * fraction, 255 ), math.min( color.g - color.g * fraction, 255 ), math.min( color.b - color.b * fraction, 255 ), color.a )
end

-- Function used to get a lighten color than the color passed in parameters and relative to a fraction
function KVS:GetLightenColor( color, fraction )
	return Color( math.min( color.r + color.r * fraction, 255 ), math.min( color.g + color.g * fraction, 255 ), math.min( color.b + color.b * fraction, 255 ), color.a )
end

-- Function used to determinate if we should use black or white color
function KVS:GetColorFromContrast( color )
	if ( color.r * 0.299 + color.g * 0.587 + color.b * 0.114 > 186 ) then
		return config( 'vgui.color.black' )
	else
		return config( 'vgui.color.white' )
	end
end

-- Function used to calculate using vectors (x and y coordinates)
function KVS:IsPointInCircle( point, center, radius )
	return point:DistToSqr( center ) < radius ^ 2
end

function KVS:MakeChainableMethod( panel, methods )
	if ( not istable( methods ) or not ispanel( panel ) ) then return end

	-- Override default functions
	for _, name in pairs( methods ) do
		panel[ name .. 'Internal' ] = panel[ name ]
		panel[ name ] = function( _, ... )
			panel[ name .. 'Internal' ]( panel, unpack( { ... } ) )
			return panel
		end
	end
end

-- Function used to create accessors for any panel
function KVS:AccessorFunc( tab, varname, name, force, invalidate )
	if ( not tab ) then debug.Trace( ) end

	tab[ 'Get' .. name ] = function( s )
		return s[ varname ]
	end

	tab[ 'Set' .. name ] = function( s, v )
		if ( force == FORCE_STRING ) then s[ varname ] = tostring( v ) end
		if ( force == FORCE_NUMBER ) then s[ varname ] = tonumber( v ) end
		if ( force == FORCE_BOOL ) then s[ varname ] = tobool( v ) end
		if ( force == nil ) then s[ varname ] = v end
		if ( invalidate == true and s.InvalidateLayout ) then s:InvalidateLayout( true ) end
		return s
	end
end

local white_mat = Material( 'vgui/white' ) -- TODO Find a way to manage all materials

function KVS:DrawGradientQuad( x, y, w, h, topLeftColor, topRightColor, bottomLeftColor, bottomRightColor )
	-- mesh.End()
	render.SetMaterial( white_mat )

	mesh.Begin( MATERIAL_QUADS, 1 )

	mesh.Position( Vector( x, y ) )
	mesh.Color( topLeftColor.r, topLeftColor.g, topLeftColor.b, topLeftColor.a )
	mesh.AdvanceVertex()

	mesh.Position( Vector( w, y ) )
	mesh.Color( topRightColor.r, topRightColor.g, topRightColor.b, topRightColor.a  )
	mesh.AdvanceVertex()

	mesh.Position( Vector( w, h ) )
	mesh.Color( bottomRightColor.r, bottomRightColor.g, bottomRightColor.b, bottomRightColor.a )
	mesh.AdvanceVertex()

	mesh.Position( Vector( x, h ) )
	mesh.Color( bottomLeftColor.r, bottomLeftColor.g, bottomLeftColor.b, bottomLeftColor.a )
	mesh.AdvanceVertex()

	mesh.End()
end

function KVS:DrawLinearGradient( x, y, w, h, color1, color2, vertical )
	local topLeftColor, topRightColor, bottomLeftColor, bottomRightColor = color1, color2, color1, color2
	if ( vertical == true ) then
		topLeftColor, topRightColor, bottomLeftColor, bottomRightColor = color1, color1, color2, color2
	end
	self:DrawGradientQuad( x, y, w + x, h + y, topLeftColor, topRightColor, bottomLeftColor, bottomRightColor )
end

function KVS:DrawLinear( x, y, w, h, colors )
	table.sort( colors, 'pos' )

	for pos = 1, #colors - 1 do
		
	end
end

function KVS:AimPositionOnFloor( ply )
	local trace = ply:GetEyeTrace( )
	local angles = trace.HitNormal:Angle( )
	local floor_trace = util.TraceLine( {
		start = trace.HitPos,
		endpos = trace.HitPos - Vector( 0, 0, 9 * 10^9 )
	} )

	return floor_trace.HitPos, angles
end

-- function KVS:DrawSimpleLinear( x, y, w, h,  )

-- end