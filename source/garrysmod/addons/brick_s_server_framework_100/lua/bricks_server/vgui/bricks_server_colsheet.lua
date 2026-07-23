
local PANEL = {}

AccessorFunc( PANEL, "ActiveButton", "ActiveButton" )

function PANEL:Init()
	self.Navigation = vgui.Create( "bricks_server_scrollpanel", self )
	self.Navigation:Dock( LEFT )
	self.Navigation:SetWidth( BRICKS_SERVER.DEVCONFIG.MainNavWidth )
	self.Navigation:DockMargin( 0, 0, 0, 0 )
	self.Navigation.Paint = function( self2, w, h )
		draw.RoundedBoxEx( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ), false, false, true, false )
	end

	self.Content = vgui.Create( "Panel", self )
	self.Content:Dock( FILL )

	self.Items = {}
end

function PANEL:AddLinebreak()
	local lineBreak = vgui.Create( "DPanel", self.Navigation )
	lineBreak:Dock( TOP )
	lineBreak:DockMargin( 0, 0, 0, 10 )
	lineBreak:SetTall( 5 )
	lineBreak.Paint = function( self2, w, h )
		surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
		surface.DrawRect( 0, 0, w, h )
	end
end

function PANEL:AddSheet( label, panel, onLoad, icon, color1, color2 )
	if ( !IsValid( panel ) ) then return end

	local Sheet = {}
	Sheet.Button = vgui.Create( "DButton", self.Navigation )
	Sheet.Button.Target = panel
	Sheet.Button:Dock( TOP )
	Sheet.Button:DockMargin( 7, 0, 7, 10 )
	Sheet.Button:SetText( "" )
	Sheet.Button:SetTall( BRICKS_SERVER.Func.ScreenScale( 40 ) )
	Sheet.Button:SetColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
	surface.SetFont( "BRICKS_SERVER_Font25" )
	local textX, textY = surface.GetTextSize( string.upper( label ) )
	local iconMat
	BRICKS_SERVER.Func.GetImage( icon or "", function( mat ) iconMat = mat end )
	local iconSize = BRICKS_SERVER.Func.ScreenScale( 24 )
	local boxH, boxHMin = 0, 20
	Sheet.Button.Paint = function( self2, w, h )
		if( self2:IsHovered() or self2.m_bSelected ) then
			boxH = math.Clamp( boxH+3, boxHMin, h )
		else
			boxH = math.Clamp( boxH-3, boxHMin, h )
		end

		local textColor = Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b, 75 )

		if( self2.m_bSelected ) then
			textColor = BRICKS_SERVER.Func.GetTheme( 6 )
		end

		if( boxH > boxHMin ) then
			if( not color1 or not color2 ) then
				draw.RoundedBox( 8, 0, (h/2)-(boxH/2), w, boxH, self2:GetColor() )
			else
				BRICKS_SERVER.Func.DrawGradientRoundedBox( 8, 0, (h/2)-(boxH/2), w, boxH, 0, color1, color2 )
			end
		end

		if( iconMat ) then
			surface.SetDrawColor( textColor )
			surface.SetMaterial( iconMat )
			surface.DrawTexturedRect( 12, (h/2)-(iconSize/2), iconSize, iconSize )
		end

		draw.SimpleText( string.upper( label ), "BRICKS_SERVER_Font23", 12+iconSize+12, h/2-1, textColor, 0, TEXT_ALIGN_CENTER )

		if( Sheet.notifications and Sheet.notifications > 0 ) then
			local nX, nY, nW, nH = h+textX+5, (h/2)-(20/2), 20, 20
			draw.RoundedBox( 5, nX, nY, nW, nH, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
			draw.SimpleText( Sheet.notifications, "BRICKS_SERVER_Font20", nX+(nW/2), nY+(nH/2), BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
	Sheet.Button.DoClick = function()
		self:SetActiveButton( Sheet.Button )
	end

	Sheet.Button.label = label

	Sheet.Panel = panel
	Sheet.Panel:SetParent( self.Content )
	Sheet.Panel:SetAlpha( 0 )
	Sheet.Panel:SetVisible( false )

	if( onLoad ) then
		Sheet.Button.loaded = false

		if( istable( onLoad ) ) then
			Sheet.Button.onLoad = onLoad[1]
			Sheet.Button.onEntered = onLoad[2]
		else
			Sheet.Button.onLoad = onLoad
		end
	end

	table.insert( self.Items, Sheet )

	if ( !IsValid( self.ActiveButton ) ) then
		self:SetActiveButton( Sheet.Button )
	end
	
	return Sheet
end

function PANEL:Think()
	for k, v in pairs( self.Items ) do
		if( v.Think ) then
			v.Think()
		end
	end
end

function PANEL:SetActiveButton( active )
	if ( self.ActiveButton == active ) then return end

	if( self.OnSheetChange ) then
		self.OnSheetChange( active )
	end
	
	if ( self.ActiveButton && self.ActiveButton.Target ) then
		local targetPanel = self.ActiveButton.Target
		targetPanel:SetVisible( false )
		targetPanel:SetAlpha( 0 )
		self.ActiveButton:SetSelected( false )
		self.ActiveButton:SetToggle( false )
		self.ActiveButton:ColorTo( BRICKS_SERVER.Func.GetTheme( 2 ), 0.2 )
	end

	self.ActiveButton = active
	active.Target:SetVisible( true )
	active.Target:AlphaTo( 255, 0.2, 0, function() end )
	active:SetSelected( true )
	active:SetToggle( true )
	active:ColorTo( BRICKS_SERVER.Func.GetTheme( 5 ), 0.2 )

	if( active.onLoad and not active.loaded ) then
		active.onLoad()
		active.loaded = true
	elseif( active.onLoad and active.onEntered ) then
		active.onEntered()
	end

	self.Content:InvalidateLayout()
end

function PANEL:SetActiveSheet( sheetLabel )
	if( not sheetLabel ) then return end

	for k, v in pairs( self.Items ) do
		if( v.Button and v.Button.label and v.Button.label == sheetLabel ) then
			self:SetActiveButton( v.Button )
			break
		end
	end
end

derma.DefineControl( "bricks_server_colsheet", "", PANEL, "Panel" )
