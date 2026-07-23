local PANEL = {}

local vgui = vgui

function PANEL:Init( )
	self:SetCursor( 'hand' )

	self._Label = vgui.Create( 'DLabel', self )
	self._Label:SetSize( 18, 18 )
	self:SetSize( 18, 18 )
end

function PANEL:Paint()
	if self:IsHovered( ) then
		if not self._IsHovered then
			self._IsHovered = true
			self._Label:SetFont( self.HoverIcon.Font )
			self._Label:SetTextColor( self.HoverIcon.Color )
			self._Label:SetText( utf8.char( self.HoverIcon.Unicode ) )
		end
	else
		if self._IsHovered then
			self._IsHovered = nil
			self._Label:SetFont( self.DefaultIcon.Font )
			self._Label:SetTextColor( self.DefaultIcon.Color )
			self._Label:SetText( utf8.char( self.DefaultIcon.Unicode ) )
		end
	end
end

function PANEL:SetIconSize( size )
	self:SetSize( size, size )
	self._Label:SetSize( size, size )
	return self
end

function PANEL:SetAlignement( position )
	self.Alignement = position
	self:InvalidateLayout( true )
	return self
end

function PANEL:SetIcon( font_name, unicode, color )
	self._Label:SetText( utf8.char( unicode ) )
	self._Label:SetFont( font_name )
	self._Label:SetTextColor( color )
	self.DefaultIcon = { Font = font_name, Unicode = unicode, Color = color }
	self:SetHoverIcon( font_name, unicode, color )
	return self
end

function PANEL:SetHoverIcon( font_name, unicode, color )
	self.HoverIcon = { Font = font_name, Unicode = unicode, Color = color }
	return self
end

function PANEL:DoClick()
end

function PANEL:OnMouseReleased( )
	self:DoClick( )
end

function PANEL:PerformLayout( )
	if self.Alignement and self.Alignement == 5 then
		self._Label:Center( )
	end
	self._Label:SetContentAlignment( self.Alignement or 5 )
end

derma.DefineControl( 'KVS.ButtonIcon', nil, PANEL, 'DPanel' )