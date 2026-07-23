local PANEL = {}

local surface = surface
local draw = draw
local vgui = vgui
local font = KVS.GetFont
local config = KVS.GetConfig

function PANEL:Init( )
	KVS:MakeChainableMethod( self, { 'SetPos', 'SetSize', 'Center', 'Dock', 'SetTall', 'SetWide', 'DockMargin', 'DockPadding' } )

	self.Outlined = false
	self.Color = config( 'vgui.color.primary' )
	self.AutoSize = false
	self.BorderRounded = { true, true, true, true }
	self.BorderRadius = 5
	self.NoAnimation = false

	self:SetCursor( 'hand' )
	self:SetTall( 40 )
	self:SetMouseInputEnabled( true )
	self:SetColor( config( 'vgui.color.primary' ) )
	self:DockPadding( 5, 5, 5, 5 )

	self.Icon = vgui.Create( 'DLabel', self )
	self.Icon:Dock( LEFT )
	self.Icon:SetContentAlignment( 5 )
	self.Icon:SetText( '' )
	self.Icon:SetVisible( false )

	self.Label = vgui.Create( 'DLabel', self )
	self.Label:Dock( FILL )
	self.Label:SetContentAlignment( 5 )
	self.Label:SetTextColor( KVS:GetColorFromContrast( self.Color ) )
	self.Label:SetFont( font( 'Vegur Bold', 15 ) )
	self.Label:SetText( '' )
end

function PANEL:SetFont( font_name )
	self.Label:SetFont( font_name )
	self:InvalidateLayout( true )
	return self
end

function PANEL:SetNoAnimation( animation )
	self.NoAnimation = animation
	return self
end

function PANEL:PerformLayout( )
	if self.Label:GetText( ) ~= nil and self.Label:GetText( ) ~= '' then
		local icon_wide = 20
		if self.Icon:IsVisible( ) then
			icon_wide = icon_wide + self.Icon:GetWide( )
		else
			icon_wide = 0
		end
		if self.AutoSize then
			self:SetWide( KVS:GetSizeFromFont( self.Label:GetFont( ), self.Label:GetText( ) ) + icon_wide + ScreenScale( 5 ))
		end
	end

	self.Icon:SizeToContents( )

	if self.PostPerformLayout then
		self:PostPerformLayout( )
	end
end

function PANEL:SetAutoSize( bool )
	self.AutoSize = bool
	self:InvalidateLayout( true )
	return self
end

function PANEL:WithIcon( font_name, unicode )
	self.Icon:SetFont( font_name )
	self.Icon:SetText( utf8.char( unicode ) )
	self.Icon:SetVisible( true )
	self:InvalidateLayout( true )
	return self
end

function PANEL:SetText( text, bPreventUpper )
	local _text = text
	if not bPreventUpper then
		_text = string.upper( text )
	end 
	self.Text = _text
	self.Label:SetText( _text )
	self:InvalidateLayout( true )
	return self
end

function PANEL:GetText( )
	return self.Text
end

function PANEL:SetBorderRadius( radius )
	self.BorderRadius = radius
	return self
end

function PANEL:SetColor( color )
	self.DefaultColor = color
	self.ActiveColor = KVS:GetDarkenColor( color, 0.2 )
	self.HoveredColor = KVS:GetLightenColor( color, 0.2 )
	self.Color = color

	self.DefaultLabelColor = KVS:GetColorFromContrast( self.Color )
	self.ActiveLabelColor = KVS:GetDarkenColor( self.DefaultLabelColor, 0.2 )
	self.HoveredLabelColor = KVS:GetLightenColor( self.DefaultLabelColor, 0.2 )

	if self.Label then
		self.Label:SetTextColor( self.DefaultLabelColor )
	end

	if self.Icon and self.Icon:IsVisible() then
		self.Icon:SetTextColor( self.DefaultLabelColor )
	end
	return self
end

function PANEL:SetDock( docking )
	self:Dock( docking )
	return self
end

function PANEL:SetPadding( left, top, right, bottom )
	self:DockPadding( left or 0, top or 0, right or 0, bottom or 0 )
	return self
end

function PANEL:SetMargin( left, top, right, bottom )
	self:DockMargin( left or 0, top or 0, right or 0, bottom or 0 )
	return self
end

function PANEL:OnCursorEntered()
	if self.NoAnimation then
		self:SetCursor( '' )
		return
	end

	if (self.Disabled) then
		self:SetCursor( 'no' )
		return
	end
	self:SetCursor( 'hand' )
end

function PANEL:OnCursorExited()
	self.IsPressed = false
	if self.NoAnimation then
		self:SetCursor( '' )
		return
	end

	if (self.Disabled) then
		self:SetCursor( 'no' )
		return
	end
	self:SetCursor( 'hand' )
end

function PANEL:OnMousePressed()
	self.IsPressed = true
	if self.Disabled then return end
end

function PANEL:OnMouseReleased( )
	self.IsPressed = false
	if self.Disabled then return end
	if self.DoClick then
		self:DoClick( )
	end
end

function PANEL:ApplyColor( )
	if self.Disabled and not self.NoAnimation then
		self.Color = self.ActiveColor
		self.Label:SetTextColor( self.ActiveLabelColor )
		self.Icon:SetTextColor( self.ActiveLabelColor )
		return
	end
	if self:IsHovered() and not self.NoAnimation then
		if self.IsPressed then
			self.Color = self.ActiveColor
			self.Label:SetTextColor( self.ActiveLabelColor )
			self.Icon:SetTextColor( self.ActiveLabelColor )
		else
			self.Color = self.HoveredColor
			self.Label:SetTextColor( self.HoveredLabelColor )
			self.Icon:SetTextColor( self.HoveredLabelColor )
		end
	else
		self.Color = self.DefaultColor
		self.Label:SetTextColor( self.DefaultLabelColor )
		self.Icon:SetTextColor( self.DefaultLabelColor )
	end
end

local texOutlinedCorner = surface.GetTextureID( 'vgui/kvs/corner_rounded_16' )

function PANEL:Paint( w, h )
	self:ApplyColor( )
	if self.Outlined and not self.NoAnimation then
		local x = 0
		local y = 0
		local bordersize = 8
		surface.SetDrawColor( self.Color )

		surface.SetTexture( texOutlinedCorner )
		surface.DrawTexturedRectRotated( x + bordersize / 2 , y + bordersize / 2, bordersize, bordersize, 0 )
		surface.DrawTexturedRectRotated( x + w - bordersize / 2 , y + bordersize / 2, bordersize, bordersize, 270 )
		surface.DrawTexturedRectRotated( x + w - bordersize / 2 , y + h - bordersize / 2, bordersize, bordersize, 180 )
		surface.DrawTexturedRectRotated( x + bordersize / 2 , y + h - bordersize / 2, bordersize, bordersize, 90 )

		surface.DrawLine( x + bordersize, y, x + w - bordersize, y )
		surface.DrawLine( x + bordersize, y + h - 1, x + w - bordersize, y + h - 1 )
		surface.DrawLine( x, y + bordersize, x, y + h - bordersize )
		surface.DrawLine( x + w - 1, y + bordersize, x + w - 1, y + h - bordersize )

	else
		draw.RoundedBoxEx( self.BorderRadius, 0, 0, w, h, self.Color, unpack( self.BorderRounded ) )
	end
end

function PANEL:SetBorder( left, top, right, bottom )
	self.BorderRounded = { left, top, right, bottom }
	return self
end

function PANEL:SetDisabled( disabled )
	self.Disabled = disabled
	if disabled then
		self:SetCursor( 'no' )
	else
		self:SetCursor( 'hand' )
	end
	return self
end

function PANEL:GetDisabled( )
	return self.Disabled
end

function PANEL:SetOutlined( outlined )
	self.Outlined = outlined
	return self
end

derma.DefineControl('KVS.Button', nil, PANEL, 'DPanel')