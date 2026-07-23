
local PANEL = {}

AccessorFunc( PANEL, "ActiveButton", "ActiveButton" )

function PANEL:Init()
	self.navigationBack = vgui.Create( "DPanel", self )
	self.navigationBack:Dock( TOP )
	self.navigationBack:SetTall( 50 )
	self.navigationBack:DockMargin( 0, 0, 0, 5 )
	local NavWidth = (ScrW()*0.6)-BRICKS_SERVER.DEVCONFIG.MainNavWidth-20
	self.navigationBack.Paint = function( self2, w, h )
		if( self.rounded ) then
			draw.RoundedBox( 5, 0, 0, w, h, (self.navColor or BRICKS_SERVER.Func.GetTheme( 3 )) )
		else
			surface.SetDrawColor( self.navColor or BRICKS_SERVER.Func.GetTheme( 3 ) )
			surface.DrawRect( 0, 0, w, h )
		end
	end

	local moveDist = 100
	
	self.Navigation = vgui.Create( "DPanel", self.navigationBack )
	self.Navigation:SetPos( 0, 0 )
	self.Navigation:SetSize( 0, self.navigationBack:GetTall() )
	self.Navigation.Paint = function( self2, w, h ) end

	function self.Navigation.UpdateWide()
		self.Navigation:SetWide( math.Clamp( self.buttonsWide, 0, NavWidth-25+(self.Navigation.leftMargin or 0) ) )
		if( self.buttonsWide > NavWidth+10 ) then
			if( not IsValid( self.Navigation.rightButton ) ) then
				self.Navigation.rightButton = vgui.Create( "DButton", self.navigationBack )
				self.Navigation.rightButton:SetSize( 25, self.navigationBack:GetTall() )
				self.Navigation.rightButton:SetPos( NavWidth-self.Navigation.rightButton:GetWide(), 0 )
				self.Navigation.rightButton:SetText( "" )
				local changeAlpha = 0
				self.Navigation.rightButton.Paint = function( self2, w, h )
					draw.RoundedBoxEx( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ), false, true, false, true )

					if( self2:IsHovered() or self2.m_bSelected ) then
						changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
					else
						changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
					end
			
					surface.SetAlphaMultiplier( changeAlpha/255 )
					draw.RoundedBoxEx( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ), false, true, false, true )
					surface.SetAlphaMultiplier( 1 )
			
					draw.SimpleText( ">", "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				end
				self.Navigation.rightButton.DoClick = function()
					if( (NavWidth-50)+(self.Navigation.leftMargin or 0) >= self.buttonsWide ) then return end
					self.Navigation.leftMargin = math.Clamp( (self.Navigation.leftMargin or 0)+moveDist, 0, self.buttonsWide-(NavWidth-25) )
					self.Navigation:SetPos( -self.Navigation.leftMargin, 0 )
					self.Navigation.UpdateWide()
				end
			end

			if( (self.Navigation.leftMargin or 0) > 0 and not IsValid( self.Navigation.leftButton ) ) then
				self.Navigation.leftButton = vgui.Create( "DButton", self.navigationBack )
				self.Navigation.leftButton:SetSize( 25, self.navigationBack:GetTall() )
				self.Navigation.leftButton:SetPos( 0, 0 )
				self.Navigation.leftButton:SetText( "" )
				local changeAlpha = 0
				self.Navigation.leftButton.Paint = function( self2, w, h )
					draw.RoundedBoxEx( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ), true, false, true, false )

					if( self2:IsHovered() or self2.m_bSelected ) then
						changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
					else
						changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
					end
			
					surface.SetAlphaMultiplier( changeAlpha/255 )
					draw.RoundedBoxEx( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ), true, false, true, false )
					surface.SetAlphaMultiplier( 1 )
			
					draw.SimpleText( "<", "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				end
				self.Navigation.leftButton.DoClick = function()
					self.Navigation.leftMargin = math.Clamp( (self.Navigation.leftMargin or 0)-moveDist, 0, self.buttonsWide-(NavWidth-25) )
					self.Navigation:SetPos( -self.Navigation.leftMargin, 0 )
					self.Navigation.UpdateWide()
				end
			elseif( (self.Navigation.leftMargin or 0) <= 0 and IsValid( self.Navigation.leftButton ) ) then
				self.Navigation.leftButton:Remove()
			end
		end
	end

	self.Content = vgui.Create( "Panel", self )
	self.Content:Dock( FILL )

	self.Items = {}
end

function PANEL:UseButtonOnlyStyle()
	self.ButtonOnly = true
end

function PANEL:AddSheet( label, panel, makeActive, onLoad )

	if ( !IsValid( panel ) ) then return end

	local Sheet = {}
	Sheet.Button = vgui.Create( "DButton", self.Navigation )
	Sheet.Button.Target = panel
	Sheet.Button:Dock( LEFT )
	Sheet.Button:DockMargin( 0, 0, 0, 0 )
	Sheet.Button:SetText( "" )
	Sheet.Button.label = label
	surface.SetFont( "BRICKS_SERVER_Font25" )
	local textX, textY = surface.GetTextSize( label )
	Sheet.Button:SetWide( textX+30 )
	self.buttonsWide = (self.buttonsWide or 0)+(textX+30)
	self.Navigation.UpdateWide()
	local changeAlpha = 0
	local ButX, ButY = false, false
	local first = false
	if( #self.Items <= 0 ) then
		first = true
	end
	Sheet.Button.Paint = function( self2, w, h )
		if( not ButX or not ButY ) then
			ButX, ButY = self2:LocalToScreen( 0, 0 )
		end

		if( self2:IsHovered() or self2.m_bSelected ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end

		surface.SetAlphaMultiplier( changeAlpha/255 )
		if( not first or not self.rounded ) then
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 5 ) )
			surface.DrawRect( 0, h-2, w, 2 )
		else
			BRICKS_SERVER.Func.DrawPartialRoundedBoxEx( 5, 0, h-2, w, 2, BRICKS_SERVER.Func.GetTheme( 5 ), w, 10, 0, h-10, false, false, true, false )
		end
		surface.SetAlphaMultiplier( 1 )

		draw.SimpleText( label, "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	Sheet.Button.DoClick = function()
		self:SetActiveButton( Sheet.Button )
	end

	if( onLoad ) then
		Sheet.Button.onLoad = onLoad() 
	end

	Sheet.Button.label = label

	Sheet.Panel = panel
	Sheet.Panel:SetParent( self.Content )
	Sheet.Panel:SetVisible( false )

	if ( self.ButtonOnly ) then
		Sheet.Button:SizeToContents()
	end

	table.insert( self.Items, Sheet )

	if ( !IsValid( self.ActiveButton ) ) then
		self:SetActiveButton( Sheet.Button, true )
	elseif( makeActive ) then
		self:SetActiveButton( Sheet.Button )
	end
	
	return Sheet
end

function PANEL:AddButton( label, func )
	local sheetButton = vgui.Create( "DButton", self.Navigation )
	sheetButton:Dock( LEFT )
	sheetButton:DockMargin( 0, 0, 0, 0 )
	sheetButton:SetText( "" )
	sheetButton.label = label
	surface.SetFont( "BRICKS_SERVER_Font25" )
	local textX, textY = surface.GetTextSize( label )
	sheetButton:SetWide( textX+30 )
	self.buttonsWide = (self.buttonsWide or 0)+(textX+30)
	self.Navigation.UpdateWide()
	local changeAlpha = 0
	local ButX, ButY = false, false
	local first = false
	if( #self.Items <= 0 ) then
		first = true
	end
	sheetButton.Paint = function( self2, w, h )
		if( not ButX or not ButY ) then
			ButX, ButY = self2:LocalToScreen( 0, 0 )
		end

		if( self2:IsHovered() or self2.m_bSelected ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end

		surface.SetAlphaMultiplier( changeAlpha/255 )
		if( not first or not self.rounded ) then
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 5 ) )
			surface.DrawRect( 0, h-2, w, 2 )
		else
			draw.RoundedBoxEx( 5, 0, h-20, w, 20, BRICKS_SERVER.Func.GetTheme( 5 ), false, false, true, false )
		end
		surface.SetAlphaMultiplier( 1 )

		if( first ) then
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
			surface.DrawRect( 0, h-20, w, 18 )
		end

		draw.SimpleText( label, "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	sheetButton.DoClick = func
	
	return sheetButton
end

function PANEL:Think()
	for k, v in pairs( self.Items ) do
		if( v.Think ) then
			v.Think()
		end
	end
end

function PANEL:SetActiveButton( active, first )

	if ( self.ActiveButton == active ) then return end

	if ( self.ActiveButton && self.ActiveButton.Target ) then
		self.ActiveButton.Target:SetVisible( false )
		self.ActiveButton:SetSelected( false )
		self.ActiveButton:SetToggle( false )
	end

	self.ActiveButton = active
	active.Target:SetVisible( true )
	active:SetSelected( true )
	active:SetToggle( true )

	if( active.onLoad ) then
		active.onLoad()
	end

	self.Content:InvalidateLayout()

	if( not first and self.pageClickFunc ) then
		self.pageClickFunc( active.label )
	end
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

function PANEL:ClearSheets()
	self.buttonsWide = 0
	self.Items = {}
	self.Navigation:Clear()
	self.Content:Clear()
end

derma.DefineControl( "bricks_server_colsheet_top", "", PANEL, "Panel" )
