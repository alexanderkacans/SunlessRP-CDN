local PANEL = {}

local font = KVS.GetFont
local config = KVS.GetConfig

function PANEL:Init()
	KVS:MakeChainableMethod( self, { 'SetPos', 'SetSize', 'DockMargin', 'DockPadding', 'Dock', 'SetTall', 'SetWide', 'ChooseOption', 'ChooseOptionID', 'SetValue', 'AddOption' } )

	self.ChoiceIcons = { }
	self.Spacers = { }
	self.BorderRounded = { true, true, true, true }

	self.BackgroundColor = config( 'vgui.color.light_black' )

	self.DropButton.Paint = function( panel, w, h ) end

	self:SetContentAlignment( 4 )
	self:SetTextInset( 8, 0 )
	self:SetIsMenu( true )
	self:SetSortItems( true )

	self:SetTall( 35 )
	self:SetFont( font( 'Vegur', 19 ) )

	self.Arrow = vgui.Create( 'KVS.ButtonIcon', self )
	self.Arrow:Dock( RIGHT )
	self.Arrow:SetIcon( font( 'FAS', 18, 'extended' ), 0xf078, KVS:GetColorFromContrast( self.BackgroundColor ) )
	self.Arrow:SetMouseInputEnabled( false )
	self.Arrow:SetAlignement( 5 )
	self.Arrow:DockMargin( 0, 0, 15, 0 )
end

function PANEL:SetBorder( left, top, right, bottom )
	self.BorderRounded = { left, top, right, bottom }
	return self
end

function PANEL:Paint( w, h )
	if IsValid( self.Menu ) and self.Menu:IsVisible( ) then
		draw.RoundedBoxEx( 5, 0, 0, w, h, self.BackgroundColor, self.BorderRounded[ 1 ], self.BorderRounded[ 2 ], false, false )
	else
		draw.RoundedBoxEx( 5, 0, 0, w, h, self.BackgroundColor, unpack( self.BorderRounded ) )
	end

	if not self.selected and self.Placeholder then
		if self:IsHovered() and ( not IsValid( self.Menu ) or not self.Menu:IsVisible( ) ) then
			draw.SimpleText( self.Placeholder, self:GetFont( ), 15, h / 2, self:GetHoveredColor( ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		else
			draw.SimpleText( self.Placeholder, self:GetFont( ), 15, h / 2, KVS:GetColorFromContrast( self.BackgroundColor ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
	elseif self:IsHovered( ) then
		self:SetColor( self:GetHoveredColor( ) )
	end

	self.Arrow:SetIcon( font( 'FAS', 18, 'extended' ), 0xf078, self:IsHovered() and self:GetHoveredColor( ) or KVS:GetColorFromContrast( self.BackgroundColor ) )
end

function PANEL:OpenMenu( pControlOpener )

	if ( pControlOpener and pControlOpener == self.TextEntry ) then
		return
	end

	-- Don't do anything if there aren't any options..
	if ( #self.Choices == 0 ) then return end

	-- If the menu still exists and hasn't been deleted
	-- then just close it and don't open a new one.
	if ( IsValid( self.Menu ) ) then
		self.Menu:Remove()
		self.Menu = nil
	end

	self.Menu = vgui.Create( 'KVS.ComboBoxMenu', self )

	if ( self:GetSortItems() ) then
		local sorted = {}
		for k, v in pairs( self.Choices ) do
			local val = tostring( v ) --tonumber( v ) || v -- This would make nicer number sorting, but SortedPairsByMemberValue doesn't seem to like number-string mixing
			if ( string.len( val ) > 1 and not tonumber( val ) and val:StartWith( '#' ) ) then val = language.GetPhrase( val:sub( 2 ) ) end
			table.insert( sorted, { id = k, data = v, label = val } )
		end
		for k, v in SortedPairsByMemberValue( sorted, 'label' ) do
			local option = self.Menu:AddOption( v.data, function() self:ChooseOption( v.data, v.id ) end )
			if ( self.ChoiceIcons[ v.id ] ) then
				option:SetIcon( self.ChoiceIcons[ v.id ] )
			end
		end
	else
		for k, v in pairs( self.Choices ) do
			local option = self.Menu:AddOption( v, function() self:ChooseOption( v, k ) end )
			if ( self.ChoiceIcons[ k ] ) then
				option:SetIcon( self.ChoiceIcons[ k ] )
			end
		end
	end

	local x, y = self:LocalToScreen( 0, self:GetTall() )

	self.Menu:SetMinimumWidth( self:GetWide() )
	self.Menu:Open( x, y, false, self )
end


function PANEL:PerformLayout( )
	self:SetColor( KVS:GetColorFromContrast( self.BackgroundColor ) )
end

function PANEL:SetDock( docking )
	self:Dock( docking )
	return self
end

function PANEL:SetBackgroundColor( color )
	self.BackgroundColor = color
	return self
end

function PANEL:SetHoveredColor( color )
	self.HoveredColor = color
	return self
end

function PANEL:GetHoveredColor( )
	if self.HoveredColor then
		return self.HoveredColor
	else
		return KVS:GetDarkenColor( KVS:GetColorFromContrast( self.BackgroundColor ), 0.4 )
	end
end

function PANEL:SetPlaceholder( placeholder )
	self.Placeholder = placeholder
	return self
end

derma.DefineControl( 'KVS.ComboBox', nil, PANEL, 'DComboBox' )