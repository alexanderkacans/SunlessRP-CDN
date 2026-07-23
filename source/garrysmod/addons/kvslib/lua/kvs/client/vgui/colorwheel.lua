local PANEL = {}

KVS:AccessorFunc( PANEL, 'm_pickerPos', 'PickerPos' ) -- Need timer !
KVS:AccessorFunc( PANEL, 'm_color', 'Color' )
KVS:AccessorFunc( PANEL, 'm_darkness', 'Darkness', FORCE_NUMBER )
KVS:AccessorFunc( PANEL, 'm_alpha', 'Alpha', FORCE_NUMBER )
KVS:AccessorFunc( PANEL, 'm_editing', 'Editing', FORCE_BOOL )
KVS:AccessorFunc( PANEL, 'm_handleRadius', 'HandleRadius', FORCE_NUMBER )
KVS:AccessorFunc( PANEL, 'm_borderSize', 'BorderSize', FORCE_NUMBER )
KVS:AccessorFunc( PANEL, 'm_borderColor', 'BorderColor' )

local colorwheelMat = Material( 'materials/kvs-lib/colorwheel.png', 'smooth noclamp alphatest' )
local config = KVS.GetConfig or { }

function PANEL:Init( )
    KVS:OverrideMeta( self, 'SetSize', function( w, h )
        self.m_handleRadius = w * 0.02
        return false, w, w
    end )

    self:SetBorderSize( 3 )
    self:SetBorderColor( config( 'vgui.color.light_black' ) or Color( 255, 255, 255 ) )

    self:SetHandleRadius( 0 )
    self:SetColor( Color( 255, 255, 255 ) )
    self:SetDarkness( 0 )
    self:SetAlpha( 255 )
    self:SetSize( 200 )

    self.TOOLTIP = self:AddTooltip( )
end

function PANEL:IsHovered( )
    local x, y = self:LocalToScreen( )
    local w = self:GetWide( ) / 2
    return math.Distance( x + w, y + self:GetTall( ) / 2, gui.MouseX( ), gui.MouseY( ) ) <= w - self.m_handleRadius
end

function PANEL:PerformLayout( w, h )
    if ( w ~= h ) then
        self:SetSize( w )
    end
end

function PANEL:OnSizeChanged( w, h )
    self:SetColor( self.m_color )
end

function PANEL:SetPickerPos( pos )
    local x = math.Clamp( pos.x, 0, self:GetWide( ) - self.m_handleRadius )
    local y = math.Clamp( pos.y, 0, self:GetTall( ) - self.m_handleRadius )
    self.m_pickerPos = Vector( x, y )
end

function PANEL:SetColor( color )
    local hue, saturation, value = ColorToHSV( color )
    local w, h = self:GetSize( )
    local x = w / 2 + ( math.cos( math.rad( hue ) ) * w * saturation / 2 )
    local y = h / 2 + ( math.sin( math.rad( hue ) ) * h * saturation / 2 )
    self.m_color = color
    self.m_darkness = 1- value
    self.m_alpha = color.a
    self:SetPickerPos( Vector( x, y ) )
end

function PANEL:GetColor( fullcolor )
    if true then return self.m_color end
    if ( fullcolor == true ) then return self.m_color end
    local darkness = ( 1 - self.m_darkness )
    return Color( self.m_color.r * darkness, self.m_color.g * darkness, self.m_color.b * darkness, self.m_alpha )
end

function PANEL:Paint( w, h )
    draw.RoundedBox( w, 0, 0, w, h, self.m_borderColor )

    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.SetMaterial( colorwheelMat )
    surface.DrawTexturedRect( self.m_borderSize, self.m_borderSize, w - self.m_borderSize * 2, h - self.m_borderSize * 2 )

    draw.RoundedBox( w, self.m_borderSize, self.m_borderSize, w - self.m_borderSize * 2, h - self.m_borderSize * 2, Color( 0, 0, 0, 255 * self.m_darkness ) )

    local handleColor = KVS:GetColorFromContrast( self.m_color )
    surface.SetDrawColor( 0, 0, 0 , 255 )
    surface.DrawCircle( self.m_pickerPos.x, self.m_pickerPos.y, self.m_handleRadius, handleColor.r, handleColor.g, handleColor.b )
end

function PANEL:OnValueChanged( color )
end

function PANEL:Think( )
    if ( self:GetEditing( ) && self:IsHovered( ) ) then
        local cx, cy = self:CursorPos( )
        local w, h = self:GetSize( )

        self:SetPickerPos( Vector( cx, cy ) )

        self:SetCursor( 'blank' )

        local ang = math.atan2( cy - h / 2, cx - w / 2 )
        local dist = math.Distance( w / 2, h / 2, cx, cy ) / w

        ang = ang + math.pi
        ang = -ang

        self.m_color = HSVToColor( math.deg( ang ) > 0 and math.deg( ang ) or math.abs( math.deg( ang ) - 180 ), dist * 2, 1 - self.m_darkness )

        self.TOOLTIP:SetText( string.format( 'rgb( %s )', string.FromColor( self.m_color ) ) )
        self.TOOLTIP:SetBackgroundColor( self:GetColor( true ) )

        self:OnValueChanged( self:GetColor( ) )
    else
        self:SetCursor( 'arrow' )
    end
end

function PANEL:OnMousePressed( keyCode )
    if ( self:IsHovered( ) && keyCode == MOUSE_LEFT ) then
        self:SetEditing( true )
        self:MouseCapture( true )
    end
end

function PANEL:OnMouseReleased( keyCode )
    if ( keyCode == MOUSE_LEFT ) then
        self:SetEditing( false )
        self:MouseCapture( false )
    end
end

derma.DefineControl( 'KVS.ColorWheel', '', PANEL, 'DPanel' )
