local PANEL = {}

function PANEL:Init()
	self:SetSize( 45, 50 )

	self.toggle = vgui.Create( "DButton", self )
	self.toggle:Dock( LEFT )
	self.toggle:SetWide( 45 )
	self.toggle:SetText( "" )
	self.toggle.xPos = 0
	self.toggle.Paint = function( self2, w, h )
		local backH = 16
		local circleRadius = math.min( h/2, (backH/2)*1.35 )
		self2.minXPos, self2.maxXPos = circleRadius, w-circleRadius

		draw.RoundedBox( backH/2, 0, (h/2)-(backH/2), w, backH, (self.backgroundCol or BRICKS_SERVER.Func.GetTheme( 3 )) )
		
		if( self.toggled ) then
			self2.xPos = math.Clamp( self2.xPos+3, self2.minXPos, self2.maxXPos )
		else
			self2.xPos = math.Clamp( self2.xPos-3, self2.minXPos, self2.maxXPos )
		end

		BRICKS_SERVER.Func.DrawCircle( self2.xPos, h/2, circleRadius, (self.toggled and BRICKS_SERVER.DEVCONFIG.BaseThemes.Green) or BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
	end
	self.toggle.DoClick = function()
		self.toggled = not self.toggled

		if( self.OnChange ) then
			self.OnChange( self.toggled )
		end
	end
end

function PANEL:SetValue( value )
	if( value ) then
		self.toggle.xPos = self.toggle.maxXPos or 0
		self.toggled = true
	else
		self.toggle.xPos = self.toggle.minXPos or 0
		self.toggled = false
	end
end

function PANEL:SetDisabled( value )
	self.toggle:SetDisabled( value )
end

function PANEL:SetTitle( title )
	self.title = title

	surface.SetFont( "BRICKS_SERVER_Font20" )
	local titleX, titleY = surface.GetTextSize( self.title or BRICKS_SERVER.Func.L( "toggle" ) )

	if( title != "" ) then
		self:SetWide( 45+5+titleX )
	else
		self:SetWide( 45 )
	end
end

function PANEL:Paint( w, h )
	draw.SimpleText( (self.title or BRICKS_SERVER.Func.L( "toggle" )), "BRICKS_SERVER_Font20", self.toggle:GetWide()+5, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
end
 
vgui.Register( "bricks_server_dcheckbox", PANEL, "DPanel" )