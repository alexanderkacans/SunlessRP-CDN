
local PANEL = {}

AccessorFunc( PANEL, "ActiveButton", "ActiveButton" )

function PANEL:Init()
	self.Navigation = vgui.Create( "bricks_server_scrollpanel", self )
	self.Navigation:Dock( LEFT )
	self.Navigation:SetWidth( 200 )
	self.Navigation.Paint = function( self2, w, h )
		if( not self.dontRoundBack ) then
			draw.RoundedBox( 5, 0, 0, w, h,  BRICKS_SERVER.Func.GetTheme( 2, 200 ) )
		else
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2, 200 ) )
			surface.DrawRect( 0, 0, w, h )
		end
	end

	self.Content = vgui.Create( "Panel", self )
	self.Content:Dock( FILL )

	self.Items = {}
	self.Categories = {}
end

function PANEL:CreateSearchBar()
	self.searchBack = vgui.Create( "DPanel", self.Navigation )
	self.searchBack:Dock( TOP )
	self.searchBack:SetTall( 30 )
	local search = Material( "materials/bricks_server/search_16.png" )
	local alpha = 0
	self.searchBack.Paint = function( self2, w, h )
		surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3, 100 ) )
		surface.DrawRect( 0, 0, w, h )

		if( self.searchBar:IsEditing() ) then
			alpha = math.Clamp( alpha+5, 0, 100 )
		else
			alpha = math.Clamp( alpha-5, 0, 100 )
		end
		
		surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3, alpha ) )
		surface.DrawRect( 0, 0, w, h )
	
		surface.SetDrawColor( 255, 255, 255, 20+((alpha/100)*255) )
		surface.SetMaterial( search )
		local size = 16
		surface.DrawTexturedRect( w-size-(h-size)/2, (h-size)/2, size, size )
	end

	self.searchBar = vgui.Create( "bricks_server_search", self.searchBack )
	self.searchBar:Dock( FILL )
	self.searchBar:SetFont( "BRICKS_SERVER_Font20" )
	self.searchBar.OnChange = function()
		self:RefreshSheetButtons()
	end
end

function PANEL:UseButtonOnlyStyle()
	self.ButtonOnly = true
end

function PANEL:AddSheet( label, panel, color, onLoad, categoryName, categoryColor )
	if ( !IsValid( panel ) ) then return end

	if( table.Count( self.Categories ) <= 0 ) then
		self.Categories["Default"] = vgui.Create( "bricks_server_navcategorycollapse", self.Navigation )
		self.Categories["Default"]:Dock( TOP )
		self.Categories["Default"]:SetLabel( "Default" )
		self.Categories["Default"]:SetBackColor( BRICKS_SERVER.Func.GetTheme( 5 ) )
	end

	categoryName = categoryName or "Default"
	categoryColor = categoryColor or BRICKS_SERVER.Func.GetTheme( 5 )

	if( not self.Categories[categoryName] ) then
		self.Categories[categoryName] = vgui.Create( "bricks_server_navcategorycollapse", self.Navigation )
		self.Categories[categoryName]:Dock( TOP )
		self.Categories[categoryName]:SetLabel( categoryName )
		self.Categories[categoryName]:SetBackColor( categoryColor )
	end

	self.Categories[categoryName].Count = (self.Categories[categoryName].Count or 0)+1

	local Sheet = {}
	Sheet.Button = vgui.Create( "DButton", self.Categories[categoryName] )
	Sheet.Button.Target = panel
	Sheet.Button:Dock( TOP )
	Sheet.Button:DockMargin( 5, ((self.Categories[categoryName].Count == 1 and 5) or 0), 5, 0 )
	Sheet.Button:SetText( "" )
	Sheet.Button:SetTall( 30 )
	local changeAlpha = 0
	Sheet.Button.Paint = function( self2, w, h )
		local backColor = (isfunction( color ) and color()) or color

		if( self2:IsDown() or self2.m_bSelected ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 50 )
		elseif( self2:IsHovered() ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 10 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 50 )
		end

		surface.SetAlphaMultiplier( changeAlpha/255 )
			draw.RoundedBox( 5, 0, 0, w, h, backColor or BRICKS_SERVER.Func.GetTheme( 4 ) )
		surface.SetAlphaMultiplier( 1 )

		draw.SimpleText( label, "BRICKS_SERVER_Font20", 10, h/2, (backColor or BRICKS_SERVER.Func.GetTheme( 5 )), 0, TEXT_ALIGN_CENTER )
	end

	Sheet.Button.DoClick = function()
		if( not Sheet.Button.m_bSelected ) then
			changeAlpha = 0
		end

		self:SetActiveButton( Sheet.Button )

		if( self.OnSheetChange ) then
			self.OnSheetChange( label )
		end
	end

	Sheet.Button.label = label

	Sheet.Panel = panel
	Sheet.Panel:SetParent( self.Content )
	Sheet.Panel:SetVisible( false )

	if( onLoad ) then
		Sheet.Button.loaded = false
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

function PANEL:FinishAddingSheets()
	for k, v in pairs( BRICKS_SERVER.DLCMODULES ) do
		if( self.Categories[v.Name] ) then continue end
		
		self.Categories[v.Name] = vgui.Create( "bricks_server_navcategorycollapse", self.Navigation )
		self.Categories[v.Name]:Dock( TOP )
		self.Categories[v.Name]:SetLabel( v.Name )
		self.Categories[v.Name]:SetBackColor( v.Color )
		self.Categories[v.Name]:SetExpanded( false )

		local hasDLC = false
		for key, val in pairs( v.Modules ) do
			if( BRICKS_SERVER.Modules[val] ) then
				hasDLC = true
				break
			end
		end

		if( not hasDLC ) then
			self.Categories[v.Name].Header.DoClick = function()
				gui.OpenURL( v.Link )
			end
		end
	end

	if( self.OnNavCollapse ) then
		for k, v in pairs( self.Categories ) do
			v.OnNavCollapse = self.OnNavCollapse
		end
	end
end

function PANEL:RefreshSheetButtons()
	if( not IsValid( self.searchBar ) ) then return end

	for k, v in pairs( self.Items ) do
		if( self.searchBar:GetValue() != "" and not string.find( string.lower( v.Button.label ), string.lower( self.searchBar:GetValue() ) ) ) then
			v.Button:SetTall( 0 )
		else
			v.Button:SetTall( 30 )
		end
	end
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
		self.ActiveButton:SetSelected( false )
		self.ActiveButton:SetToggle( false )
	end

	self.ActiveButton = active
	active.Target:SetVisible( true )
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

function PANEL:ClearSheets()
	self.Items = {}
	self.Navigation:Clear()
	self.Content:Clear()
end

derma.DefineControl( "bricks_server_colsheet_left", "", PANEL, "Panel" )
