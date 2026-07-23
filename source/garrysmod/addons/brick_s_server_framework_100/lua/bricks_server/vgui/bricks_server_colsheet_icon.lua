
local PANEL = {}

AccessorFunc( PANEL, "ActiveButton", "ActiveButton" )

function PANEL:Init()

	self.Navigation = vgui.Create( "bricks_server_scrollpanel", self )
	self.Navigation:Dock( LEFT )
	self.Navigation:SetWidth( 65 )
	self.Navigation:DockMargin( 0, 0, 0, 0 )
	self.Navigation.Paint = function( self2, w, h )
		draw.RoundedBoxEx( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ), false, false, true, false )
	end

	self.Content = vgui.Create( "Panel", self )
	self.Content:Dock( FILL )

	self.Items = {}

end

function PANEL:UseButtonOnlyStyle()
	self.ButtonOnly = true
end

function PANEL:AddSheet( panel, onLoad, icon, dontShow )

	if ( !IsValid( panel ) ) then return end

	local Sheet = {}
	Sheet.Button = vgui.Create( "DButton", self.Navigation )
	Sheet.Button.Target = panel
	Sheet.Button:Dock( TOP )
	Sheet.Button:SetText( "" )
	Sheet.Button:SetTall( (not dontShow and 65) or 0 )
	local changeAlpha = 0
	local iconMat
	BRICKS_SERVER.Func.GetImage( icon or "", function( mat ) iconMat = mat end )
	Sheet.Button.Paint = function( self2, w, h )
		if( self2:IsHovered() or self2.m_bSelected ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end

		surface.SetAlphaMultiplier( changeAlpha/255 )
		surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 5 ) )
		surface.DrawRect( 0, 0, 5, h )
		surface.SetAlphaMultiplier( 1 )

		if( iconMat ) then
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6, 75 ) )
			surface.SetMaterial( iconMat )
			local iconSize = 32
			surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
		end
	end

	Sheet.Button.DoClick = function()
		if( not Sheet.Button.m_bSelected ) then
			changeAlpha = 0
		end

		self:SetActiveButton( Sheet.Button )
	end

	Sheet.Panel = panel
	Sheet.Panel:SetParent( self.Content )
	Sheet.Panel:SetAlpha( 0 )
	Sheet.Panel:SetVisible( false )

	if( onLoad ) then
		Sheet.Button.onLoad = onLoad
	end

	if ( self.ButtonOnly ) then
		Sheet.Button:SizeToContents()
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

	if ( self.ActiveButton && self.ActiveButton.Target ) then
		local targetPanel = self.ActiveButton.Target
		targetPanel:SetVisible( false )
		targetPanel:SetAlpha( 0 )
		self.ActiveButton:SetSelected( false )
		self.ActiveButton:SetToggle( false )
	end

	self.ActiveButton = active
	active.Target:SetVisible( true )
	active.Target:AlphaTo( 255, 0.2, 0, function() end )
	active:SetSelected( true )
	active:SetToggle( true )

	if( active.onLoad and not active.loaded ) then
		active.onLoad()
		active.loaded = true
	end

	self.Content:InvalidateLayout()
end

derma.DefineControl( "bricks_server_colsheet_icon", "", PANEL, "Panel" )
