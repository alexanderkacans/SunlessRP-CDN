
local PANEL = {}

AccessorFunc( PANEL, "ActiveButton", "ActiveButton" )

function PANEL:Init()
	self.Navigation = vgui.Create( "bricks_server_scrollpanel", self )
	self.Navigation:Dock( LEFT )
	self.Navigation:SetWidth( 200 )
	self.Navigation:DockMargin( 0, 0, 0, 0 )
	self.Navigation.Paint = function( self2, w, h )
		draw.RoundedBoxEx( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ), false, false, true, false )
	end

	self.Content = vgui.Create( "Panel", self )
	self.Content:Dock( FILL )

	self.Items = {}
	self.CategoryButtons = {}
end

function PANEL:AddLinebreak()
	local lineBreak = vgui.Create( "DPanel", self.Navigation )
	lineBreak:Dock( TOP )
	lineBreak:DockMargin( 5, 10, 5, 10 )
	lineBreak:DockMargin( 5, 10, 5, 10 )
	lineBreak:SetTall( 5 )
	lineBreak.Paint = function( self2, w, h )
		draw.RoundedBox( 3, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
	end
end

function PANEL:AddSheet( label, panel, onLoad, icon, dontShow )
	if ( !IsValid( panel ) ) then return end

	local Sheet = {}
	Sheet.Button = vgui.Create( "DButton", self.Navigation )
	Sheet.Button.Target = panel
	Sheet.Button:Dock( TOP )
	Sheet.Button:SetText( "" )
	Sheet.Button:SetTall( (not dontShow and 65) or 0 )
	local changeAlpha = 0
	surface.SetFont( "BRICKS_SERVER_Font25" )
	local textX, textY = surface.GetTextSize( label )
	local iconMat
	BRICKS_SERVER.Func.GetImage( icon or "", function( mat ) iconMat = mat end )
	Sheet.Button.Paint = function( self2, w, h )
		if( self2:IsHovered() or self2.m_bSelected ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end

		surface.SetAlphaMultiplier( changeAlpha/255 )
		if( self2.m_bSelected ) then
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 5 ) )
			surface.DrawRect( 0, 0, w, h )
		elseif( self2:IsHovered() ) then
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 5 ) )
			surface.DrawRect( 0, 0, 5, h )
		end
		surface.SetAlphaMultiplier( 1 )

		if( iconMat ) then
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
			surface.SetMaterial( iconMat )
			local iconSize = 32
			surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
		end

		draw.SimpleText( label, "BRICKS_SERVER_Font25", h, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )

		if( Sheet.notifications and Sheet.notifications > 0 ) then
			local nX, nY, nW, nH = h+textX+5, (h/2)-(20/2), 20, 20
			draw.RoundedBox( 5, nX, nY, nW, nH, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
			draw.SimpleText( Sheet.notifications, "BRICKS_SERVER_Font20", nX+(nW/2), nY+(nH/2), BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end

	Sheet.Button.DoClick = function()
		if( not Sheet.Button.m_bSelected ) then
			changeAlpha = 0
		end

		self:SetActiveButton( Sheet.Button )
	end

	Sheet.Button.label = label

	Sheet.Panel = panel
	Sheet.Panel:SetParent( self.Content )
	Sheet.Panel:SetAlpha( 0 )
	Sheet.Panel:SetVisible( false )

	if( onLoad ) then
		Sheet.Button.loaded = false
		Sheet.Button.onLoad = onLoad
	end

	table.insert( self.Items, Sheet )

	if ( !IsValid( self.ActiveButton ) ) then
		self:SetActiveButton( Sheet.Button )
	end
	
	return Sheet
end

function PANEL:AddCategory( label, icon )
	local categoryButton = vgui.Create( "DButton", self.Navigation )
	categoryButton:Dock( TOP )
	categoryButton:SetText( "" )
	local tall = 65
	categoryButton:SetTall( tall )
	categoryButton:DockPadding( 0, tall, 0, 0 )
	local changeAlpha = 0
	surface.SetFont( "BRICKS_SERVER_Font25" )
	local textX, textY = surface.GetTextSize( label )
	local iconMat
	BRICKS_SERVER.Func.GetImage( icon or "", function( mat ) iconMat = mat end )
	categoryButton.Paint = function( self2, w, h )
		if( self2:IsHovered() or self2.m_bSelected ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end

		surface.SetAlphaMultiplier( changeAlpha/255 )
		if( self2.m_bSelected ) then
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 5 ) )
			surface.DrawRect( 0, 0, w, tall )
		elseif( self2:IsHovered() ) then
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 5 ) )
			surface.DrawRect( 0, 0, 5, tall )
		end
		surface.SetAlphaMultiplier( 1 )

		if( iconMat ) then
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
			surface.SetMaterial( iconMat )
			local iconSize = 32
			surface.DrawTexturedRect( (tall-iconSize)/2, (tall/2)-(iconSize/2), iconSize, iconSize )
		end

		draw.SimpleText( label, "BRICKS_SERVER_Font25", tall, tall/2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
	end
	categoryButton.DoClick = function()
		if( not categoryButton.m_bSelected ) then
			changeAlpha = 0
		end

		for k, v in pairs( self.Items ) do
			if( v.parentCategory and v.parentCategory == categoryButton ) then
				self:SetActiveButton( v.Button )
				break
			end
		end
	end
	categoryButton.fullHeight = tall

	table.insert( self.CategoryButtons, categoryButton )
	
	return categoryButton
end

function PANEL:AddSubSheet( parentCategory, label, panel, onLoad )

	if( not IsValid( parentCategory ) or not IsValid( panel ) ) then return end

	local Sheet = {}
	Sheet.Button = vgui.Create( "DButton", parentCategory )
	Sheet.Button.Target = panel
	Sheet.Button:Dock( TOP )
	Sheet.Button:SetText( "" )
	Sheet.Button:SetTall( 30 )
	local changeAlpha = 0
	Sheet.Button.Paint = function( self2, w, h )
		if( self2:IsHovered() or self2.m_bSelected ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 50 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 50 )
		end

		surface.SetAlphaMultiplier( changeAlpha/255 )
		surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 4 ) )
		surface.DrawRect( 0, 0, w, h )
		surface.SetAlphaMultiplier( 1 )

		draw.SimpleText( label, "BRICKS_SERVER_Font17", 15, h/2, BRICKS_SERVER.Func.GetTheme( 5 ), 0, TEXT_ALIGN_CENTER )
	end

	Sheet.Button.DoClick = function()
		if( not Sheet.Button.m_bSelected ) then
			changeAlpha = 0
		end

		self:SetActiveButton( Sheet.Button )
	end

	Sheet.Button.label = label

	Sheet.Panel = panel
	Sheet.Panel:SetParent( self.Content )
	Sheet.Panel:SetAlpha( 0 )
	Sheet.Panel:SetVisible( false )

	if( onLoad ) then
		Sheet.Button.loaded = false
		Sheet.Button.onLoad = onLoad
	end

	Sheet.parentCategory = parentCategory
	Sheet.Button.parentCategory = parentCategory
	parentCategory.fullHeight = parentCategory.fullHeight+Sheet.Button:GetTall()

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

	for k, v in pairs( self.CategoryButtons ) do
		if( v.m_bSelected and (not active.parentCategory or active.parentCategory != v) ) then
			v.m_bSelected = false
			v:SizeTo( self.Navigation:GetWide(), 65, 0.2 )
			break
		elseif( not v.m_bSelected and active.parentCategory and active.parentCategory == v ) then
			v.m_bSelected = true
			v:SizeTo( self.Navigation:GetWide(), v.fullHeight, 0.2 )
			break
		end
	end
	
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

function PANEL:SetActiveSheet( sheetLabel )
	if( not sheetLabel ) then return end

	for k, v in pairs( self.Items ) do
		if( v.Button and v.Button.label and v.Button.label == sheetLabel ) then
			self:SetActiveButton( v.Button )
			break
		end
	end
end

derma.DefineControl( "bricks_server_colsheet_old", "", PANEL, "Panel" )
