
local PANEL = {}

AccessorFunc( PANEL, "m_fDefaultValue", "DefaultValue" )

function PANEL:Init()
	self.TextArea = self:Add( "DTextEntry" )
	self.TextArea:Dock( RIGHT )
	self.TextArea:DockMargin( 20, 0, 0, 0 )
	self.TextArea:SetPaintBackground( false )
	self.TextArea:SetWide( 45 )
	self.TextArea:SetNumeric( true )
	self.TextArea:SetTextColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
	self.TextArea:SetFont( "BRICKS_SERVER_Font17" )
	self.TextArea.OnChange = function( textarea, val ) self:SetValue( self.TextArea:GetText() ) end

	self.Slider = self:Add( "bricks_server_dslider", self )
	self.Slider:SetLockY( 0.5 )
	self.Slider.TranslateValues = function( slider, x, y ) return self:TranslateSliderValues( x, y ) end
	self.Slider:Dock( FILL )
	self.Slider:SetHeight( 16 )
	self.Slider.Knob.OnMousePressed = function( panel, mcode )
		if ( mcode == MOUSE_MIDDLE ) then
			self:ResetToDefaultValue()
			return
		end
		self.Slider:OnMousePressed( mcode )
	end

	self:SetTall( 32 )

	self:SetMin( 0 )
	self:SetMax( 1 )
	self:SetValue( 1 )
	self.Slider:SetSlideX( 0 )
end

function PANEL:SetMinMax( min, max )
	self:UpdateNotches()
end

function PANEL:GetMin()
	return self.min or 0
end

function PANEL:GetMax()
	return self.max or 1
end

function PANEL:GetRange()
	return self:GetMax() - self:GetMin()
end

function PANEL:ResetToDefaultValue()
	if ( !self:GetDefaultValue() ) then return end
	self:SetValue( self:GetDefaultValue() )
end

function PANEL:SetMin( min )

	if ( !min ) then min = 0 end

	self.min = tonumber( min )
	self:UpdateNotches()

end

function PANEL:SetMax( max )

	if ( !max ) then max = 0 end

	self.max = tonumber( max )
	self:UpdateNotches()

end

function PANEL:SetValue( val )

	val = math.Clamp( tonumber( val ) || 0, self:GetMin(), self:GetMax() )

	if ( self:GetValue() == val ) then return end

	self.value = val

	self:ValueChanged( self:GetValue() ) -- In most cases this will cause double execution of OnValueChanged

end

function PANEL:GetFloatValue()
	return self.value or 0
end

function PANEL:GetValue()
	return self.value or 0
end

--
-- Are we currently changing the value?
--
function PANEL:IsEditing()

	return self.TextArea:IsEditing() || self.Slider:IsEditing()

end

function PANEL:IsHovered()

	return self.TextArea:IsHovered() || self.Slider:IsHovered() || vgui.GetHoveredPanel() == self

end

function PANEL:PerformLayout()
	self.Slider:PerformLayout()
end

function PANEL:ValueChanged( val )

	val = math.Clamp( tonumber( val ) || 0, self:GetMin(), self:GetMax() )

	self.Slider:SetSlideX( self.value/self.max )

	self:OnValueChanged( val )
	self.TextArea:SetText( math.floor( val ) )
end

function PANEL:OnValueChanged( val )

	-- For override

end

function PANEL:TranslateSliderValues( x, y )

	self:SetValue( self:GetMin() + ( x * self:GetRange() ) )

	return (self:GetValue()-self:GetMin())/self:GetRange(), y

end

function PANEL:GetTextArea()

	return self.TextArea

end

function PANEL:UpdateNotches()

	local range = self:GetRange()
	self.Slider:SetNotches( nil )

	if ( range < self:GetWide() / 4 ) then
		return self.Slider:SetNotches( range )
	else
		self.Slider:SetNotches( self:GetWide() / 4 )
	end

end

function PANEL:SetEnabled( b )
	self.Slider:SetEnabled( b )
	FindMetaTable( "Panel" ).SetEnabled( self, b ) -- There has to be a better way!
end

derma.DefineControl( "bricks_server_dnumslider", "Menu Option Line", table.Copy( PANEL ), "Panel" )