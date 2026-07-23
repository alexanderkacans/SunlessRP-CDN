local PANEL = {}

local config = KVS.GetConfig

KVS:AccessorFunc( PANEL, 'm_value', 'Value', FORCE_NUMBER )
KVS:AccessorFunc( PANEL, 'm_defaultValue', 'DefaultValue', FORCE_NUMBER )
KVS:AccessorFunc( PANEL, 'm_minValue', 'Min', FORCE_NUMBER )
KVS:AccessorFunc( PANEL, 'm_maxValue', 'Max', FORCE_NUMBER )
KVS:AccessorFunc( PANEL, 'm_backgroundColor', 'BackgroundColor' )
KVS:AccessorFunc( PANEL, 'm_decimals', 'Decimals', FORCE_NUMBER )

function PANEL:Init( )
	self:SetBackgroundColor( Color( 0, 0, 0, 0 ) )
	self:SetMin( 0 )
	self:SetMax( 100 )
	self:SetDefaultValue( self.m_minValue )
	self:SetValue( self.m_defaultValue )
	self:SetDecimals( 1 )
	self:AddTooltip( self:GetValue() ):SetMode( 'fixed_y' ):SetOffset( Vector( 0, -4 ) )
end

function PANEL:GetRange( )
	return self.m_maxValue - self.m_minValue
end

function PANEL:IsPointerHovered( )
	local x, y = self:LocalToScreen( )
	local h = self:GetTall( )
	local pointer = Vector( x + self:GetPointerPos( ) + self:GetPointerSize( ) / 2, y + h / 2, 0 )
	local cursor = Vector( gui.MouseX( ), gui.MouseY( ), 0 )

	return KVS:IsPointInCircle( cursor, pointer, self:GetPointerSize( ) / 2 )
end

function PANEL:IsSlidebarHovered( )
	local x, y = self:CursorPos( )
	local w = self:GetSlideBarSize( )
	local h = self:GetTall( )
	local pointerSize = self:GetPointerSize( )

	return x > pointerSize / 2 and x < w + pointerSize and y > h / 2 - h / 4 and y < h / 2 + h / 4
end

function PANEL:IsHovered( )
	return self:IsSlidebarHovered( ) or self:IsPointerHovered( )
end

function PANEL:GetSlideBarPos( )
	local w, h = self:GetSize( )
	local slibebar_w, slidebar_h = self:GetSlideBarSize( )
	return w / 2 - slibebar_w / 2, h / 2 - slidebar_h / 2
end

function PANEL:GetSlideBarSize( )
	return self:GetWide() - self:GetPointerSize(), self:GetTall( ) / 2
end

function PANEL:GetPointerSize( )
	return self:GetTall( )
end

function PANEL:GetPointerPos( )
	return ( self.m_value - self:GetMin() ) * self:GetSlideBarSize() / ( self:GetRange() )
end

function PANEL:DrawSlideBar( x, y, w, h )
	draw.RoundedBox( h / 2, x, y, w, h, Color( 44, 44, 44 ) )
	draw.RoundedBox( h / 2, x, y, w * ( self.m_value - self:GetMin() ) / self:GetRange(), h, config('vgui.color.primary') )
end

function PANEL:DrawPointer( )
	local pointerSize = self:GetPointerSize( )
	draw.RoundedBox( self:GetPointerSize( ), math.max( self:GetPointerPos( ) - self:GetPointerSize( ) / 2, 0 ), 0 , pointerSize, pointerSize, config('vgui.color.primary')  )
end

function PANEL:Paint( w, h )
	draw.RoundedBox( w * 0.025, 0, 0, w, h, self.m_backgroundColor )
	local slidebar_x, slidebar_y = self:GetSlideBarPos( )
	local slidebar_w, slidebar_h = self:GetSlideBarSize( )
	self:DrawSlideBar( slidebar_x, slidebar_y, slidebar_w, slidebar_h)
	self:DrawPointer( )
end

function PANEL:SetValue( value )
	self.m_value = value
	self:OnValueChanged( value )
end

function PANEL:OnValueChange( value )
end

function PANEL:OnValueChanged( value )
end

function PANEL:OnCursorMoved( x, y )
	if ( not input.IsMouseDown( MOUSE_LEFT ) ) then return end

	local max_x = self:GetWide() - self:GetPointerSize()
	x = math.min( x, max_x )
	x = math.max( x, 0 )

	local perc = ( x - ( self:GetPointerSize() - self:GetPointerSize() ) / 2 ) / max_x
	local value =  math.Clamp( self:GetRange() * perc + self:GetMin(), self:GetMin(), self:GetMax() )

	value = math.Round( value, self.m_decimals )

	if ( self:OnValueChange( value ) == true ) then return end
	self:SetValue( value )
	self:OnValueChanged( value )
	self:SetTooltipText( value )
end

function PANEL:OnMousePressed( keyCode )
	if ( not self:IsHovered( ) ) then return end

	self:MouseCapture( true )
	self:OnCursorMoved( self:CursorPos( ) )
end

function PANEL:OnMouseReleased( keyCode )
	if ( not self:IsHovered( ) ) then return end

	self:MouseCapture( false )
	self:OnCursorMoved( self:CursorPos( ) )
end

derma.DefineControl( 'KVS.Slider', '', table.Copy( PANEL ), 'Panel' )
