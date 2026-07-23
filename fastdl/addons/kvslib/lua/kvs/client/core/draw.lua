local tex_corner8	= surface.GetTextureID( "gui/corner8" )
local tex_corner16	= surface.GetTextureID( "gui/corner16" )
local tex_corner32	= surface.GetTextureID( "gui/corner32" )
local tex_corner64	= surface.GetTextureID( "gui/corner64" )
local tex_corner512	= surface.GetTextureID( "gui/corner512" )
local tex_white		= surface.GetTextureID( "vgui/white" )

function draw.RoundedBorderEx( cornersize, bordersize, x, y, w, h, color, tl, tr, bl, br )

	surface.SetDrawColor( color.r, color.g, color.b, color.a )

	-- Do not waste performance if they don't want rounded corners
	if ( cornersize <= 0 ) then
		surface.DrawRect( x, y, w, h )
		return
	end

	x = math.Round( x )
	y = math.Round( y )
	w = math.Round( w )
	h = math.Round( h )

	bordersize = bordersize or 0
	cornersize =  math.Clamp( math.min( math.Round( cornersize ), math.floor( w / 2 ) ), 0, bordersize )
	cornersize = math.Clamp( cornersize, 0, bordersize )

	-- Draw as much of the rect as we can without textures
	surface.DrawRect( x, y + cornersize, bordersize, h - cornersize * 2 ) -- LEFT
	surface.DrawRect( x + cornersize, y, w - cornersize * 2, bordersize ) -- TOP
	surface.DrawRect( x + cornersize, y + h - cornersize, w - cornersize * 2, bordersize ) -- BOTTOM
	surface.DrawRect( x + w - bordersize, y + cornersize, bordersize, h - cornersize * 2 ) -- RIGHT

	local tex = tex_corner8
	if ( cornersize > 8 ) then tex = tex_corner16 end
	if ( cornersize > 16 ) then tex = tex_corner32 end
	if ( cornersize > 32 ) then tex = tex_corner64 end
	if ( cornersize > 64 ) then tex = tex_corner512 end

	surface.SetTexture( tex )

	if ( tl ) then
		surface.DrawTexturedRectUV( x, y, cornersize, cornersize, 0, 0, 1, 1 )
	else
		surface.DrawRect( x, y, cornersize, cornersize )
	end

	if ( tr ) then
		surface.DrawTexturedRectUV( x + w - cornersize, y, cornersize, cornersize, 1, 0, 0, 1 )
	else
		surface.DrawRect( x + w - cornersize, y, cornersize, cornersize )
	end

	if ( bl ) then
		surface.DrawTexturedRectUV( x, y + h -cornersize, cornersize, cornersize, 0, 1, 1, 0 )
	else
		surface.DrawRect( x, y + h - cornersize, cornersize, cornersize )
	end

	if ( br ) then
		surface.DrawTexturedRectUV( x + w - cornersize, y + h - cornersize, cornersize, cornersize, 1, 1, 0, 0 )
	else
		surface.DrawRect( x + w - cornersize, y + h - cornersize, cornersize, cornersize )
	end

end

function draw.RoundedBorder( cornersize, bordersize, x, y, w, h, color )
	draw.RoundedBorderEx( cornersize, x, y, w, h, color, true, true, true, true )
end

function draw.KVS_Arc(cx,cy,radius,thickness,startang,endang,roughness,color)
	draw.NoTexture()
	surface.SetDrawColor(color)
	surface.KVS_DrawArc( surface.KVS_PrecacheArc(cx,cy,radius,thickness,startang,endang,roughness) )
end

function surface.KVS_PrecacheArc(cx,cy,radius,thickness,startang,endang,roughness)
	local triarc = {}
	-- local deg2rad = math.pi / 180
	radius = radius / 2
	-- Define step
	local roughness = math.max(roughness or 1, 1)
	local step = roughness
	
	-- Correct start/end ang
	local startang,endang = startang or 0, endang or 0
	
	if startang > endang then
		step = math.abs(step) * -1
	end
	
	-- Create the inner circle's points.
	local inner = {}
	local r = radius - thickness
	for deg=startang, endang, step do
		local rad = math.rad(deg)
		-- local rad = deg2rad * deg
		local ox, oy = cx+(math.cos(rad)*r), cy+(-math.sin(rad)*r)
		table.insert(inner, {
			x=ox + radius,
			y=oy + radius,
			u=(ox-cx)/radius + .5,
			v=(oy-cy)/radius + .5,
		})
	end	
	
	-- Create the outer circle's points.
	local outer = {}
	for deg=startang, endang, step do
		local rad = math.rad(deg)
		-- local rad = deg2rad * deg
		local ox, oy = cx+(math.cos(rad)*radius), cy+(-math.sin(rad)*radius)
		table.insert(outer, {
			x=ox + radius,
			y=oy + radius,
			u=(ox-cx)/radius + .5,
			v=(oy-cy)/radius + .5,
		})
	end	
	
	-- Triangulize the points.
	for tri=1,#inner*2 do -- twice as many triangles as there are degrees.
		local p1,p2,p3
		p1 = outer[math.floor(tri/2)+1]
		p3 = inner[math.floor((tri+1)/2)+1]
		if tri%2 == 0 then --if the number is even use outer.
			p2 = outer[math.floor((tri+1)/2)]
		else
			p2 = inner[math.floor((tri+1)/2)]
		end
	
		table.insert(triarc, {p1,p2,p3})
	end
	
	-- Return a table of triangles to draw.
	return triarc
end

function surface.KVS_DrawArc(arc) //Draw a premade arc.
	for k,v in ipairs(arc) do
		surface.DrawPoly(v)
	end
end

surface.PrecacheArc = surface.KVS_PrecacheArc
surface.DrawArc = surface.KVS_DrawArc
draw.Arc = draw.KVS_Arc