function BRICKS_SERVER.Func.ScreenScale( number, min, max )
    number = number*(ScrW()/2560)

    if( min and max ) then
        return math.Clamp( number, min, max )
    elseif( min or max ) then
        return min and math.max( min, number ) or math.min( max, number )
    else
        return number
    end
end

BRICKS_SERVER.UI = {
	Margin5 = BRICKS_SERVER.Func.ScreenScale( 5 ),
	Margin10 = BRICKS_SERVER.Func.ScreenScale( 10 ),
	Margin15 = BRICKS_SERVER.Func.ScreenScale( 15 ),
	Margin25 = BRICKS_SERVER.Func.ScreenScale( 25 ),
	Margin50 = BRICKS_SERVER.Func.ScreenScale( 50 ),
	Margin100 = BRICKS_SERVER.Func.ScreenScale( 100 )
}

function BRICKS_SERVER.Func.Repeat( val, amount )
	local args = {}
	for i = 1, amount do
		table.insert( args, val )
	end

	return unpack( args )
end

BRICKS_SERVER.DEVCONFIG.MainNavWidth = BRICKS_SERVER.Func.ScreenScale( 230 )
hook.Add( "OnScreenSizeChanged", "BRS.OnScreenSizeChanged.DevConfig", function()
    BRICKS_SERVER.DEVCONFIG.MainNavWidth = BRICKS_SERVER.Func.ScreenScale( 230 )
end )

--[[ FONTS ]]--
local function createFonts()
	surface.CreateFont( "BRICKS_SERVER_Font90", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 90 ),
		weight = 5000,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font25", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 25 ),
		weight = 500,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font24", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 24 ),
		weight = 500,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_NoSC_Font24", {
		font = "Montserrat Medium",
		extended = false,
		size = 24,
		weight = 500,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font23", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 23 ),
		weight = 500,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font20", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 20 ),
		weight = 500,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_NoSC_Font20", {
		font = "Montserrat Medium",
		extended = false,
		size = 20,
		weight = 500,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font17", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 17 ),
		weight = 500,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_NoSC_Font17", {
		font = "Montserrat Medium",
		extended = false,
		size = 17,
		weight = 500,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font17B", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 17 ),
		weight = 5000,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font18", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 18 ),
		weight = 500,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font19", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 19 ),
		weight = 500,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font20B", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 20 ),
		weight = 500,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font26", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 26 ),
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font30", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 27 ),
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font32", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 32 ),
		weight = 500,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font33", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 33 ),
		weight = 500,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_NoSC_Font33", {
		font = "Montserrat Medium",
		extended = false,
		size = 33,
		weight = 500,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font28B", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 28 ),
		weight = 650,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font36B", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 38 ),
		weight = 650,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font40", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 40 ),
		weight = 5000,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_NoSC_Font40", {
		font = "Montserrat Medium",
		extended = false,
		size = 40,
		weight = 5000,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font45", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 45 ),
		weight = 500,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font40B", {
		font = "Montserrat Bold",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 40 ),
		weight = 5000,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font50", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 70 ),
		weight = 5000,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font53", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 53 ),
		weight = 5000,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font20", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 20 ),
		weight = 500,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font11", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 11 ),
		weight = 500,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font13", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 13, 10 ),
		weight = 500,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font15", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 15 ),
		weight = 500,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font22B", {
		font = "Montserrat Bold",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 22 ),
		weight = 500,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font21", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 21 ),
		weight = 500,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font22", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 22 ),
		weight = 500,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font23B", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 23 ),
		weight = 5000,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_HUDFont", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 27 ),
		weight = 500,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font31", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 31 ),
		weight = 500,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_HUDFontS", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 25 ),
		weight = 5000,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_HUDFontB", {
		font = "Montserrat Medium",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 30 ),
		weight = 5000,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font100", {
		font = "Montserrat Bold",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 75 ),
		weight = 5000,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font50", {
		font = "Montserrat Bold",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 50 ),
		weight = 5000,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font30B", {
		font = "Montserrat Bold",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 30 ),
		weight = 5000,
		outline = false,
	} )

	surface.CreateFont( "BRICKS_SERVER_Font60B", {
		font = "Montserrat Bold",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 60 ),
		weight = 5000,
		outline = false,
	} )

	-- New Fonts
	surface.CreateFont( "BRS.Font.Bold20", {
		font = "Montserrat Bold",
		extended = false,
		size = BRICKS_SERVER.Func.ScreenScale( 20 ),
		weight = 500,
		outline = false,
	} )
end
createFonts()

hook.Add( "OnScreenSizeChanged", "BRS.OnScreenSizeChanged.Fonts", createFonts )

--[[ FUNCTIONS ]]--
local blur = Material("pp/blurscreen")
function BRICKS_SERVER.Func.DrawBlur( p, a, d )
	local x, y = p:LocalToScreen(0, 0)
	surface.SetDrawColor( 255, 255, 255 )
    surface.SetMaterial( blur )
    
	for i = 1, d do
		blur:SetFloat( "$blur", (i / d ) * ( a ) )
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect( x * -1, y * -1, ScrW(), ScrH() )
	end
end

local panelMeta = FindMetaTable( "Panel" )
function panelMeta:SetBRSToolTip( posX, posY, sizeW, sizeH, text, visiblePanel )
	self.OnCursorEntered = function()
		if( self.Menu and IsValid( self.Menu ) ) then return end
		
		if( IsValid( BRS_TOOLTIP ) ) then
			BRS_TOOLTIP:Remove()
		end

		local textTable = text
		if( not istable( text ) ) then
			textTable = { text }
		end

		BRS_TOOLTIP = vgui.Create( "DPanel" )
		BRS_TOOLTIP:MakePopup()
		BRS_TOOLTIP:DockPadding( 10, 5, 0, 0 )
		BRS_TOOLTIP.Paint = function( self2, w, h )
			BRICKS_SERVER.BSHADOWS.BeginShadow()
			local x, y = self2:LocalToScreen( 0, 0 )
			draw.RoundedBox( 8, x, y, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )			
			BRICKS_SERVER.BSHADOWS.EndShadow(1, 1, 1, 255, 0, 0, false )
		end

		local textX, textY = 0, 0
		for k, v in pairs( textTable ) do
			local textString = v
			local textColor = BRICKS_SERVER.Func.GetTheme( 6 )
			local textFont = "BRICKS_SERVER_Font20"
			if( istable( v ) ) then
				textString = v[1] or BRICKS_SERVER.Func.L( "errorNoText" )
				textColor = v[2] or BRICKS_SERVER.Func.GetTheme( 6 )
				textFont = v[3] or "BRICKS_SERVER_Font20"
			end

			surface.SetFont( textFont )
			
			local newTextX, newTextY = surface.GetTextSize( textString )
			if( newTextX > textX ) then
				textX = newTextX
			end
			textY = textY+newTextY

			local textPanel = vgui.Create( "DLabel", BRS_TOOLTIP )
			textPanel:SetText( textString )
			textPanel:SetFont( textFont )
			textPanel:Dock( TOP )
			textPanel:SetTall( newTextY )

			if( isfunction( textColor ) ) then
				textPanel.Think = function()
					textPanel:SetTextColor( textColor() )
				end
			else
				textPanel:SetTextColor( textColor )
			end
		end

		BRS_TOOLTIP:SetSize( textX+20, textY+10 )
		BRS_TOOLTIP:SetPos( posX+sizeW+5, posY+(sizeH/2)-(BRS_TOOLTIP:GetTall()/2) )
		BRS_TOOLTIP:SetAlpha( 0 )
		BRS_TOOLTIP:AlphaTo( 255, 0.1 )
		BRS_TOOLTIP.Think = function()
			if( IsValid( BRS_TOOLTIP ) and not self:IsHovered() ) then
				BRS_TOOLTIP:Remove()
			end
		end
	end

	self.OnCursorExited = function()
		if( IsValid( BRS_TOOLTIP ) ) then
			BRS_TOOLTIP:Remove()
		end
	end

	self.OnRemove = function()
		if( IsValid( BRS_TOOLTIP ) ) then
			BRS_TOOLTIP:Remove()
		end
	end
end

local entityMeta = FindMetaTable( "Entity" )
function entityMeta:SetBRSEntityToolTip( text )
	if( not IsValid( self ) ) then return end

	if( not BRS_ENTITY_TOOLTIPS ) then
		BRS_ENTITY_TOOLTIPS = {}
	end

	local textTable = text
	if( not istable( text ) ) then
		textTable = { text }
	end

	local textX, textY = 0, 0
	for k, v in pairs( textTable ) do
		local textString = v
		local textColor = BRICKS_SERVER.Func.GetTheme( 6 )
		local textFont = "BRICKS_SERVER_Font20"
		if( istable( v ) ) then
			textString = v[1] or BRICKS_SERVER.Func.L( "errorNoText" )
			textColor = v[2] or BRICKS_SERVER.Func.GetTheme( 6 )
			textFont = v[3] or "BRICKS_SERVER_Font20"
		end

		surface.SetFont( textFont )
		
		local newTextX, newTextY = surface.GetTextSize( textString )
		if( newTextX > textX ) then
			textX = newTextX
		end
		textY = textY+newTextY
	end

	BRS_ENTITY_TOOLTIPS[self] = { textTable, textX+20, textY+10 }
end

hook.Add( "HUDPaint", "BRS.HUDPaint.EntityToolTips", function()
	if( LocalPlayer():GetEyeTrace() and LocalPlayer():GetEyeTrace().HitPos ) then
		local hitPos = LocalPlayer():GetEyeTrace().HitPos

		if( LocalPlayer():GetPos():DistToSqr( hitPos ) > 10000 ) then return end

		local entTable = {}
		for k, v in pairs( ents.FindInSphere( hitPos, 25 ) ) do
			if( IsValid( v ) and BRS_ENTITY_TOOLTIPS and BRS_ENTITY_TOOLTIPS[v] ) then
				table.insert( entTable, { hitPos:DistToSqr( v:GetPos() ), v } )
			end
		end

		table.sort( entTable, function(a, b) return a[1] < b[1] end )

		local ent = (entTable[1] or {})[2]
		if( ent and IsValid( ent ) ) then
			local pos = Vector( ent:GetPos().x, ent:GetPos().y, ent:GetPos().z+25 )
			local pos2d = pos:ToScreen()

			local textTable, width, height = BRS_ENTITY_TOOLTIPS[ent][1], BRS_ENTITY_TOOLTIPS[ent][2], BRS_ENTITY_TOOLTIPS[ent][3]
			local xPos, yPos = pos2d.x, pos2d.y

			draw.RoundedBox( 5, xPos, yPos, width, height, BRICKS_SERVER.Func.GetTheme( 0 ) )

			local textX, textY = 0, 0
			for i = 1, #textTable do
				local textString = textTable[i] or ""
				local textColor = BRICKS_SERVER.Func.GetTheme( 6 )
				local textFont = "BRICKS_SERVER_Font20"
				if( istable( textTable[i] ) ) then
					textString = textTable[i][1] or BRICKS_SERVER.Func.L( "errorNoText" )
					textColor = textTable[i][2] or BRICKS_SERVER.Func.GetTheme( 6 )
					textFont = textTable[i][3] or "BRICKS_SERVER_Font20"
				end

				draw.SimpleText( textString, textFont, xPos+10, yPos+5+textY, ((isfunction( textColor ) and textColor()) or textColor), 0, 0 )
	
				surface.SetFont( textFont )
				
				local newTextX, newTextY = surface.GetTextSize( textString )
				if( newTextX > textX ) then
					textX = newTextX
				end
				textY = textY+newTextY
			end
		end
	end
end )

hook.Add( "EntityRemoved", "BRS.EntityRemoved.RemoveEntityToolTips", function( ent )
	if( BRS_ENTITY_TOOLTIPS and BRS_ENTITY_TOOLTIPS[ent] ) then
		BRS_ENTITY_TOOLTIPS[ent] = nil
	end
end )

local notifQueue = {}
local function createNotif()
	if( not notifQueue[1] ) then return end

	local headerText, headerColor, subText, subColor = notifQueue[1][1], notifQueue[1][2], notifQueue[1][3], notifQueue[1][4]

	surface.PlaySound( "common/warning.wav" )

	BRS_CENTER_NOTIF_PANEL = vgui.Create( "DPanel" )
	BRS_CENTER_NOTIF_PANEL:SetSize( ScrW(), ScrH() )
	BRS_CENTER_NOTIF_PANEL:SetPos( -BRS_CENTER_NOTIF_PANEL:GetWide(), (ScrH()/2)-(BRS_CENTER_NOTIF_PANEL:GetTall()/2) )
	BRS_CENTER_NOTIF_PANEL:MoveTo( (ScrW()/2)-(BRS_CENTER_NOTIF_PANEL:GetWide()/2), (ScrH()/2)-(BRS_CENTER_NOTIF_PANEL:GetTall()/2), 0.5, 0, 1 )
	local spacing = 4
	BRS_CENTER_NOTIF_PANEL.Paint = function( self, w, h )
		draw.SimpleText( headerText, "BRICKS_SERVER_Font53", w/2-1, h/3+1+spacing, BRICKS_SERVER.Func.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
		draw.SimpleText( headerText, "BRICKS_SERVER_Font53", w/2, h/3+spacing, headerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
		draw.SimpleText( subText, "BRICKS_SERVER_Font30", w/2-1, h/3+1-spacing, BRICKS_SERVER.Func.GetTheme( 3 ), TEXT_ALIGN_CENTER, 0 )
		draw.SimpleText( subText, "BRICKS_SERVER_Font30", w/2, h/3-spacing, subColor, TEXT_ALIGN_CENTER, 0 )
	end
	
	timer.Simple( 3, function()
		if( IsValid( BRS_CENTER_NOTIF_PANEL ) ) then
			BRS_CENTER_NOTIF_PANEL:MoveTo( ScrW(), (ScrH()/2)-(BRS_CENTER_NOTIF_PANEL:GetTall()/2), 0.5, 0, 1, function()
				if( IsValid( BRS_CENTER_NOTIF_PANEL ) ) then
					BRS_CENTER_NOTIF_PANEL:Remove()
					table.remove( notifQueue, 1 )
					createNotif()
				end
			end )
		end
	end )
end

function BRICKS_SERVER.Func.AddCenterNotification( headerText, headerColor, subText, subColor )
	if( BRS_CENTER_NOTIF_PANEL and IsValid( BRS_CENTER_NOTIF_PANEL ) ) then 
		for k, v in pairs( notifQueue ) do
			if( v[1] == headerText and v[3] == subText ) then
				return
			end
		end

		table.insert( notifQueue, { headerText, headerColor, subText, subColor } )
	else
		table.insert( notifQueue, { headerText, headerColor, subText, subColor } )
		createNotif()
	end
end

--[[ PAINTING ]]--
function BRICKS_SERVER.Func.DrawProgress( text, status )
	if( status >= 1 ) then return end
	
	local width, height = ScrW()*0.1, 10
	local y = (ScrH()/4)*3-50

	draw.RoundedBox( 5, (ScrW()/2)-(width/2), y, width, height, BRICKS_SERVER.Func.GetTheme( 3 ))

	draw.RoundedBox( 5, (ScrW()/2)-(width/2), y, width*math.Clamp( status, 0, 1 ), height, BRICKS_SERVER.Func.GetTheme( 5 ) )
end

local gradientDown = Material( 'vgui/gradient_down' )
local gradientUp = Material( 'vgui/gradient_up' )
local gradientLeft = Material( 'vgui/gradient-l' )
local gradientRight = Material( 'vgui/gradient-r' )
function BRICKS_SERVER.Func.DrawMaterialShadow( x, y, w, h, GradientType )
	if( GradientType == "Down" ) then
		surface.SetMaterial( gradientDown )
	elseif( GradientType == "Up" ) then
		surface.SetMaterial( gradientUp )	
	elseif( GradientType == "Left" ) then
		surface.SetMaterial( gradientLeft )	
	elseif( GradientType == "Right" ) then
		surface.SetMaterial( gradientRight )
	end
	surface.SetDrawColor( 0, 0, 0, 175 )
	surface.DrawTexturedRect( x, y, w, h )
end

function BRICKS_SERVER.Func.DrawCircle( x, y, radius, color )
	if( radius <= 0 ) then return end
	
	if( color and istable( color ) and color.r and color.g and color.b ) then
		surface.SetDrawColor( color )
	end
	
	draw.NoTexture()

	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, 45 do
		local a = math.rad( ( i / 45 ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

function BRICKS_SERVER.Func.PrecachedArc( cx, cy, radius, thickness, startang, endang, roughness )
	local triarc = {}
	-- local deg2rad = math.pi / 180
	
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
			x=ox,
			y=oy,
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
			x=ox,
			y=oy,
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

function BRICKS_SERVER.Func.DrawCachedArc( arc, color )
	draw.NoTexture()

	if( color ) then
		surface.SetDrawColor( color )
	end

	for k,v in ipairs(arc) do
		surface.DrawPoly(v)
	end
end


function BRICKS_SERVER.Func.DrawArc( cx, cy, radius, thickness, startang, endang, color )
	BRICKS_SERVER.Func.DrawCachedArc( BRICKS_SERVER.Func.PrecachedArc( cx, cy, radius, thickness, startang, endang ), color )
end

local radiusAnim, fadeAnim, endRadius = 0.2, 0.2, 0
function BRICKS_SERVER.Func.DrawClickCircle( panel, w, h, color, cornerRadius )
	if( panel:IsDown() and not panel.doClickAnim ) then
		endRadius = math.sqrt( ((w/2)^2)+((h/2)^2) )
		panel.doClickAnimEndTime = CurTime()+radiusAnim+fadeAnim
		panel.doClickAnim = true
	end

	if( panel.doClickAnim ) then
		local timeLeft = (panel.doClickAnimEndTime or 0)-CurTime()
		if( timeLeft <= 0 ) then
			panel.doClickAnimEndTime = nil
			panel.doClickAnim = false
		end

		local radiusTimeLeft = (panel.doClickAnimEndTime or 0)-fadeAnim-CurTime()
		local radius = endRadius*math.Clamp( (radiusAnim-radiusTimeLeft)/radiusAnim, 0, 1 )

		local fade = 1
		if( CurTime() >= (panel.doClickAnimEndTime or 0)-fadeAnim ) then
			fade = math.Clamp( timeLeft/fadeAnim, 0, 1 )
		end

		surface.SetAlphaMultiplier( fade )
		draw.NoTexture()
		surface.SetDrawColor( color )
		if( cornerRadius ) then
			BRICKS_SERVER.Func.DrawRoundedMask( cornerRadius, 0, 0, w, h, function()
				BRICKS_SERVER.Func.DrawCircle( w/2, h/2, radius, radius )
			end )
		else
			BRICKS_SERVER.Func.DrawCircle( w/2, h/2, radius, radius )
		end
		surface.SetAlphaMultiplier( 1 )

	end
end

local g_grds, g_wgrd, g_sz
function BRICKS_SERVER.Func.DrawGradientBox(x, y, w, h, al, ...)
	g_grds = {...}

	x = math.Round( x )
	y = math.Round( y )
	w = math.Round( w )
	h = math.Round( h )

	al = math.Clamp(math.floor(al), 0, 1)
	if(al == 1) then
		local t = w
		w, h = h, t
	end
	g_wgrd = w / (#g_grds - 1)
	local n
	for i = 0, w do
		for c = 1, #g_grds do
			n = c
			if(i <= g_wgrd * c) then
				break
			end
		end
		g_sz = i - (g_wgrd * (n - 1))
		surface.SetDrawColor(
			Lerp(g_sz/g_wgrd, g_grds[n].r, g_grds[n + 1].r),
			Lerp(g_sz/g_wgrd, g_grds[n].g, g_grds[n + 1].g),
			Lerp(g_sz/g_wgrd, g_grds[n].b, g_grds[n + 1].b),
			Lerp(g_sz/g_wgrd, g_grds[n].a, g_grds[n + 1].a))
		if(al == 1) then
			surface.DrawRect(x, y + i, h, 1)
		else
			surface.DrawRect(x + i, y, 1, h)
		end
	end
end

local gradientMatR, gradientMatU, gradientMatD = Material("gui/gradient"), Material("gui/gradient_up"), Material("gui/gradient_down")
function BRICKS_SERVER.Func.DrawTexturedGradientBox(x, y, w, h, direction, ...)
	local colors = {...}
	local horizontal = direction != 1
	local secSize = math.ceil( ((horizontal and w) or h)/math.ceil( #colors/2 ) )
	
	local previousPos = (horizontal and x or y)-secSize
	for k, v in pairs( colors ) do
		if( k % 2 != 0 ) then
			previousPos = previousPos+secSize
			surface.SetDrawColor( v )
			surface.DrawRect( (horizontal and previousPos or x), (horizontal and y or previousPos), (horizontal and secSize or w), (horizontal and h or secSize) )
		end
	end

	local previousGradPos = (horizontal and x or y)-secSize
	for k, v in pairs( colors ) do
		if( k % 2 == 0 ) then
			previousGradPos = previousGradPos+secSize
			surface.SetDrawColor( v )
			surface.SetMaterial( horizontal and gradientMatR or gradientMatU )
			if( horizontal ) then
				surface.DrawTexturedRectUV( (horizontal and previousGradPos or x), (horizontal and y or previousGradPos), (horizontal and secSize or w), (horizontal and h or secSize), 1, 0, 0, 1)
			else
				surface.DrawTexturedRect( (horizontal and previousGradPos or x), (horizontal and y or previousGradPos), (horizontal and secSize or w), (horizontal and h or secSize))
			end

			if( colors[k+1] ) then
				surface.SetDrawColor( v )
				surface.SetMaterial( horizontal and gradientMatR or gradientMatD )
				surface.DrawTexturedRect((horizontal and previousGradPos+secSize or x), (horizontal and y or previousGradPos+secSize), (horizontal and secSize or w), (horizontal and h or secSize))
			end
		end
	end
end

-- Credits: https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/includes/modules/draw.lua, https://gist.github.com/MysteryPancake/e8d367988ef05e59843f669566a9a59f
BRICKS_SERVER.MaskMaterial = CreateMaterial("!brsmask","UnlitGeneric",{
	["$translucent"] = 1,
	["$vertexalpha"] = 1,
	["$alpha"] = 1,
})

local whiteColor = Color( 255, 255, 255 )
local renderTarget
function BRICKS_SERVER.Func.DrawRoundedMask( cornerRadius, x, y, w, h, drawFunc )
	if( not renderTarget ) then
		renderTarget = GetRenderTargetEx( "BRS_GRADIENT_ROUNDEDBOX", ScrW(), ScrH(), RT_SIZE_FULL_FRAME_BUFFER, MATERIAL_RT_DEPTH_NONE, 2, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGBA8888 )
	end

	render.PushRenderTarget( renderTarget )
	render.OverrideAlphaWriteEnable( true, true )
	render.Clear( 0, 0, 0, 0 ) 

	drawFunc()

	--Draw the mask
	render.OverrideBlendFunc( true, BLEND_ZERO, BLEND_SRC_ALPHA, BLEND_DST_ALPHA, BLEND_ZERO )
	draw.RoundedBox( cornerRadius, x, y, w, h, whiteColor )
	render.OverrideBlendFunc( false )
	render.OverrideAlphaWriteEnable( false )
	render.PopRenderTarget() 

	--Update material
	BRICKS_SERVER.MaskMaterial:SetTexture( "$basetexture", renderTarget )

	--Clear material for upcoming draw calls
	draw.NoTexture()

	surface.SetDrawColor( 255, 255, 255, 255 ) 
	surface.SetMaterial( BRICKS_SERVER.MaskMaterial ) 
	render.SetMaterial( BRICKS_SERVER.MaskMaterial )
	render.DrawScreenQuad() 
end

function BRICKS_SERVER.Func.DrawGradientRoundedBox( cornerRadius, x, y, w, h, al, ... )
	local varArgs = { ... }
	BRICKS_SERVER.Func.DrawRoundedMask( cornerRadius, x, y, w, h, function()
		BRICKS_SERVER.Func.DrawGradientBox( x, y, w, h, al, unpack( varArgs ) )
	end )
end

function BRICKS_SERVER.Func.StartStencil()
	render.ClearStencil()
	render.SetStencilEnable( true )

	render.SetStencilWriteMask( 1 )
	render.SetStencilTestMask( 1 )

	render.SetStencilFailOperation( STENCILOPERATION_REPLACE )
	render.SetStencilPassOperation( STENCILOPERATION_ZERO )
	render.SetStencilZFailOperation( STENCILOPERATION_ZERO )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )
	render.SetStencilReferenceValue( 1 )
end

function BRICKS_SERVER.Func.MiddleStencil()
	render.SetStencilFailOperation( STENCILOPERATION_ZERO )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilZFailOperation( STENCILOPERATION_ZERO )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
	render.SetStencilReferenceValue( 1 )
end

function BRICKS_SERVER.Func.EndStencil()
	render.SetStencilEnable( false )
	render.ClearStencil()
end

function BRICKS_SERVER.Func.DrawPartialRoundedBox( cornerRadius, x, y, w, h, color, roundedBoxW, roundedBoxH, roundedBoxX, roundedBoxY )
	BRICKS_SERVER.Func.StartStencil()

	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawRect( x, y, w, h )

	BRICKS_SERVER.Func.MiddleStencil()

	draw.RoundedBox( cornerRadius, (roundedBoxX or x), (roundedBoxY or y), roundedBoxW, roundedBoxH, color )

	BRICKS_SERVER.Func.EndStencil()
end

function BRICKS_SERVER.Func.DrawPartialRoundedBoxEx( cornerRadius, x, y, w, h, color, roundedBoxW, roundedBoxH, roundedBoxX, roundedBoxY, roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight )
	BRICKS_SERVER.Func.StartStencil()

	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawRect( x, y, w, h )

	BRICKS_SERVER.Func.MiddleStencil()

	draw.RoundedBoxEx( cornerRadius, (roundedBoxX or x), (roundedBoxY or y), roundedBoxW, roundedBoxH, color, roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight )

	BRICKS_SERVER.Func.EndStencil()
end

-- Credits: https://github.com/FPtje/DarkRP/blob/master/gamemode/modules/base/cl_util.lua
local function charWrap(text, remainingWidth, maxWidth)
    local totalWidth = 0

    text = text:gsub(".", function(char)
        totalWidth = totalWidth + surface.GetTextSize(char)

        -- Wrap around when the max width is reached
        if totalWidth >= remainingWidth then
            -- totalWidth needs to include the character width because it's inserted in a new line
            totalWidth = surface.GetTextSize(char)
            remainingWidth = maxWidth
            return "\n" .. char
        end

        return char
    end)

    return text, totalWidth
end

function BRICKS_SERVER.Func.TextWrap(text, font, maxWidth)
    local totalWidth = 0

    surface.SetFont(font)

    local spaceWidth = surface.GetTextSize(' ')
    text = text:gsub("(%s?[%S]+)", function(word)
		local char = string.sub(word, 1, 1)
		if char == "\n" or char == "\t" then
			totalWidth = 0
		end

		local wordlen = surface.GetTextSize(word)
		totalWidth = totalWidth + wordlen

		-- Wrap around when the max width is reached
		if wordlen >= maxWidth then -- Split the word if the word is too big
			local splitWord, splitPoint = charWrap(word, maxWidth - (totalWidth - wordlen), maxWidth)
			totalWidth = splitPoint
			return splitWord
		elseif totalWidth < maxWidth then
			return word
		end

		-- Split before the word
		if char == ' ' then
			totalWidth = wordlen - spaceWidth
			return '\n' .. string.sub(word, 2)
		end

		totalWidth = wordlen
		return '\n' .. word
	end)

    return text, string.len( text )-string.len( string.Replace( text, "\n", "" ) )+1
end

-- Credits: https://github.com/FPtje/DarkRP/blob/master/gamemode/modules/base/cl_drawfunctions.lua
local function safeText(text)
    return string.match(text, "^#([a-zA-Z_]+)$") and text .. " " or text
end

function BRICKS_SERVER.Func.DrawNonParsedText(text, font, x, y, color, xAlign)
    return draw.DrawText(safeText(text), font, x, y, color, xAlign)
end